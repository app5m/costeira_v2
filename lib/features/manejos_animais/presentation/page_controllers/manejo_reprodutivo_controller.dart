import 'dart:async';

import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/common/get_list/domain/entities/get_list_entity.dart';
import 'package:costeira/core/common/get_list/domain/entities/list_item_entity.dart';
import 'package:costeira/core/common/get_list/presentation/controllers/get_list_controller.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/features/animals/domain/entities/animal_entity.dart';
import 'package:costeira/features/animals/domain/entities/animal_lot_entity.dart';
import 'package:costeira/features/animals/domain/entities/animals_filter_entity.dart';
import 'package:costeira/features/animals/domain/usecases/get_animals_usecase.dart';
import 'package:costeira/features/animals/presentation/controllers/list_animal_lots_controller.dart';
import 'package:costeira/features/fazendas/domain/usecases/resolve_current_farm_id.dart';
import 'package:costeira/features/manejos_animais/domain/entities/manejo_animal_lista.dart';
import 'package:costeira/features/manejos_animais/domain/usecases/adicionar_manejo_animal_usecase.dart';
import 'package:costeira/features/manejos_animais/domain/usecases/listar_manejos_animais_usecase.dart';
import 'package:costeira/features/potreiros/domain/entities/potreiro_entity.dart';
import 'package:costeira/features/potreiros/presentation/controllers/list_potreiros_controller.dart';
import 'package:flutter/material.dart';

enum ManejoReprodutivoPainel { nenhum, entrada, retirada, iatf, diagnostico, aborto }

const _meses = [
  'Janeiro',
  'Fevereiro',
  'Março',
  'Abril',
  'Maio',
  'Junho',
  'Julho',
  'Agosto',
  'Setembro',
  'Outubro',
  'Novembro',
  'Dezembro',
];

String mesPrevistoParto(DateTime data, {required bool tardia}) {
  final soma = tardia ? 7 : 8;
  final indice = data.month - 1 + soma;
  final ano = data.year + indice ~/ 12;
  return '${_meses[indice % 12]} de $ano';
}

class ManejoReprodutivoController extends ChangeNotifier {
  ManejoReprodutivoController(
    this._lots,
    this._potreiros,
    this._getAnimals,
    this._getList,
    this._adicionar,
    this._listar,
    this._resolveFarm,
  ) {
    brinco.addListener(_onBrinco);
    dias.addListener(notifyListeners);
    quantidade.addListener(notifyListeners);
    motivo.addListener(notifyListeners);
  }

  final ListAnimalLotsController _lots;
  final ListPotreirosController _potreiros;
  final GetAnimalsUsecase _getAnimals;
  final GetListController _getList;
  final AdicionarManejoAnimalUsecase _adicionar;
  final ListarManejosAnimaisUsecase _listar;
  final ResolveCurrentFarmId _resolveFarm;

  final data = TextEditingController();
  final brinco = TextEditingController();
  final dias = TextEditingController(text: '90');
  final semen = TextEditingController();
  final responsavel = TextEditingController();
  final quantidade = TextEditingController();
  final motivo = TextEditingController();

  bool loading = true;
  bool saving = false;
  bool buscando = false;
  bool carregandoEstacoes = false;
  String? error;
  ManejoReprodutivoPainel painel = ManejoReprodutivoPainel.nenhum;
  int? loteId;
  int? racaId;
  int? touroId;
  int? animalId;
  int? etapaId;
  int? resultadoId;
  int? classificacao;
  List<ListItemEntity> racas = const [];
  List<ManejoCategoriaLista> categorias = const [];
  List<AnimalEntity> touros = const [];
  List<ManejoAnimalListaItem> estacoes = const [];

  Timer? _busca;
  int _buscaToken = 0;
  int _estacaoToken = 0;
  bool _silencio = false;

  /// Entrada de touro: apenas lotes exclusivos de fêmeas (sexo = 2).
  List<AnimalLotEntity> get lotesFemea =>
      _lots.lots.where((lote) => lote.isFemea).toList(growable: false);

  AnimalLotEntity? get loteSelecionado =>
      lotesFemea.where((lote) => lote.id == loteId).firstOrNull;

  List<PotreiroEntity> get piquetes => _potreiros.potreiros;

  List<ListItemEntity> get etapasIatf => tiposDe(10);

  List<ListItemEntity> get resultadosDiagnostico => tiposDe(11);

  bool get resultadoPrenha {
    final nome = resultadosDiagnostico
        .where((item) => item.id == resultadoId)
        .map((item) => item.nome)
        .firstOrNull;
    return nome != null && nome.toLowerCase().contains('prenh');
  }

  String? get mesPrevisto {
    if (!resultadoPrenha || classificacao == null) {
      return null;
    }
    return mesPrevistoParto(dataAtual, tardia: classificacao == 2);
  }

  bool get podeRegistrarEntrada {
    final duracao = int.tryParse(dias.text.trim()) ?? 0;
    return !saving && touroId != null && loteId != null && duracao > 0 && data.text.isNotEmpty;
  }

  bool get podeRegistrarIatf =>
      !saving && loteId != null && etapaId != null && data.text.isNotEmpty;

  bool get podeRegistrarDiagnostico {
    return !saving &&
        loteId != null &&
        resultadoId != null &&
        classificacao != null &&
        data.text.isNotEmpty &&
        quantidadeValida;
  }

  bool get podeRegistrarAborto {
    final brincoOk = brinco.text.trim().isEmpty || animalId != null;
    return !saving &&
        loteId != null &&
        data.text.isNotEmpty &&
        motivo.text.trim().isNotEmpty &&
        brincoOk;
  }

  bool get quantidadeValida {
    final lote = loteSelecionado;
    final qtd = int.tryParse(quantidade.text.trim());
    if (lote == null || qtd == null) {
      return false;
    }
    return qtd >= 1 && qtd <= lote.animalsCount;
  }

  List<ListItemEntity> tiposDe(int categoriaId) {
    final vistos = <int>{};
    final itens = <ListItemEntity>[];
    for (final categoria in categorias.where((item) => item.id == categoriaId)) {
      for (final tipo in categoria.tipos) {
        if (vistos.add(tipo.id)) {
          itens.add(tipo);
        }
      }
    }
    return itens;
  }

  Future<void> init() async {
    data.text = _formatDate(DateTime.now());
    loading = true;
    error = null;
    notifyListeners();
    try {
      final user = await SessionStorage.getUserSession();
      if (user == null) {
        throw ApiException('Usuario nao autenticado.');
      }
      await Future.wait([_lots.load(), _potreiros.load()]);
      final macho = await _getList.load(1);
      final femea = await _getList.load(2);
      racas = macho?.animaisBasesRaciais ?? const [];
      categorias = [
        ...?macho?.manejosCategorias,
        ...?femea?.manejosCategorias,
      ];
    } on ApiException catch (e) {
      error = e.message;
    } catch (_) {
      error = 'Nao foi possivel carregar o manejo reprodutivo.';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void abrir(ManejoReprodutivoPainel value) {
    painel = value;
    loteId = null;
    racaId = null;
    touroId = null;
    animalId = null;
    etapaId = null;
    resultadoId = null;
    classificacao = null;
    touros = const [];
    estacoes = const [];
    _silencio = true;
    brinco.clear();
    semen.clear();
    responsavel.clear();
    quantidade.clear();
    motivo.clear();
    _silencio = false;
    dias.text = '90';
    notifyListeners();
    if (value == ManejoReprodutivoPainel.retirada) {
      carregarEstacoes();
    }
  }

  void setLote(int? id) {
    loteId = id;
    notifyListeners();
  }

  void setRaca(int? id) {
    racaId = id;
    notifyListeners();
  }

  void setEtapa(int? id) {
    etapaId = id;
    notifyListeners();
  }

  void setResultado(int? id) {
    resultadoId = id;
    notifyListeners();
  }

  void setClassificacao(int? id) {
    classificacao = id;
    notifyListeners();
  }

  void setData(DateTime value) {
    data.text = _formatDate(value);
    notifyListeners();
    if (painel == ManejoReprodutivoPainel.retirada) {
      carregarEstacoes();
    }
  }

  void selecionarTouro(AnimalEntity animal) {
    _busca?.cancel();
    touroId = animal.id;
    touros = [animal];
    racaId ??= animal.utBasesRaciaisId;
    _silencio = true;
    brinco.text = animal.brinco?.trim() ?? '';
    _silencio = false;
    notifyListeners();
  }

  void selecionarAnimal(AnimalEntity animal) {
    _busca?.cancel();
    animalId = animal.id;
    touros = [animal];
    _silencio = true;
    brinco.text = animal.brinco?.trim() ?? '';
    _silencio = false;
    notifyListeners();
  }

  String rotuloLote(AnimalLotEntity lote) {
    final nome = (lote.categoriaNome ?? '').trim().isEmpty ? lote.nome : lote.categoriaNome!;
    final piquete = piquetes
        .where((item) => item.id == lote.appPotreirosId)
        .map((item) => item.nome)
        .firstOrNull;
    final cab = '${lote.animalsCount} cab.';
    if (piquete == null || piquete.isEmpty) {
      return '$nome — $cab';
    }
    return '$nome — $cab — $piquete';
  }

  Future<void> carregarEstacoes() async {
    final token = ++_estacaoToken;
    carregandoEstacoes = true;
    notifyListeners();
    try {
      final user = await SessionStorage.getUserSession();
      if (user == null) {
        throw ApiException('Usuario nao autenticado.');
      }
      final farmId = await _resolveFarm(userId: user.id);
      if (farmId == null) {
        throw ApiException('Cadastre uma fazenda antes de listar as estações.');
      }
      final result = await _listar(
        appUsersId: user.id,
        appFazendasId: farmId,
        idCategoria: 8,
        estacaoAtiva: true,
        dataReferencia: data.text,
      );
      if (token != _estacaoToken) {
        return;
      }
      estacoes = result.itens;
      error = null;
    } on ApiException catch (e) {
      if (token != _estacaoToken) {
        return;
      }
      estacoes = const [];
      error = e.message;
    } catch (_) {
      if (token != _estacaoToken) {
        return;
      }
      estacoes = const [];
      error = 'Nao foi possivel listar as estações.';
    } finally {
      if (token == _estacaoToken) {
        carregandoEstacoes = false;
        notifyListeners();
      }
    }
  }

  Future<String?> registrarEntrada() async {
    if (!podeRegistrarEntrada) {
      return 'Escolha o touro, o lote e a duração.';
    }
    final erro = await _enviar(
      {
        'id_categoria': 8,
        'data': data.text,
        if (racaId != null) 'ut_bases_raciais_id': racaId,
        'app_animais_lotes_id': loteId,
        'duracao_estacao': int.parse(dias.text.trim()),
        'animais': [
          {'id': touroId},
        ],
      },
      'Nao foi possivel registrar a entrada de touro.',
    );
    if (erro == null) {
      painel = ManejoReprodutivoPainel.nenhum;
      notifyListeners();
    }
    return erro;
  }

  Future<String?> encerrarEstacao(int id) async {
    if (data.text.isEmpty) {
      return 'Escolha a data da retirada.';
    }
    final erro = await _enviar(
      {
        'id_categoria': 9,
        'id_manejo': id,
        'data': data.text,
      },
      'Nao foi possivel encerrar a estação.',
    );
    if (erro == null) {
      await carregarEstacoes();
    }
    return erro;
  }

  Future<String?> registrarIatf() async {
    if (!podeRegistrarIatf) {
      return 'Escolha o lote e a etapa.';
    }
    final semenTexto = semen.text.trim();
    final responsavelTexto = responsavel.text.trim();
    final erro = await _enviar(
      {
        'id_categoria': 10,
        'data': data.text,
        'app_animais_lotes_id': loteId,
        'id_tipo': etapaId,
        if (semenTexto.isNotEmpty) 'semen_utilizado': semenTexto,
        if (responsavelTexto.isNotEmpty) 'responsavel': responsavelTexto,
        if (_animaisLote != null) 'animais': _animaisLote,
      },
      'Nao foi possivel registrar a IATF.',
    );
    if (erro == null) {
      painel = ManejoReprodutivoPainel.nenhum;
      notifyListeners();
    }
    return erro;
  }

  Future<String?> registrarDiagnostico() async {
    if (!podeRegistrarDiagnostico) {
      return 'Preencha o lote, a quantidade e o resultado.';
    }
    final erro = await _enviar(
      {
        'id_categoria': 11,
        'id_tipo': resultadoId,
        'data': data.text,
        'app_animais_lotes_id': loteId,
        'classificacao': classificacao,
        if (_animaisLote != null) 'animais': _animaisLote,
      },
      'Nao foi possivel registrar o diagnóstico.',
    );
    if (erro == null) {
      painel = ManejoReprodutivoPainel.nenhum;
      notifyListeners();
    }
    return erro;
  }

  Future<String?> registrarAborto() async {
    if (!podeRegistrarAborto) {
      return 'Preencha o lote e o motivo.';
    }
    final erro = await _enviar(
      {
        'id_categoria': 13,
        'data': data.text,
        'motivo': motivo.text.trim(),
        'app_animais_lotes_id': loteId,
        if (animalId != null)
          'animais': [
            {'id': animalId},
          ],
      },
      'Nao foi possivel registrar o aborto.',
    );
    if (erro == null) {
      painel = ManejoReprodutivoPainel.nenhum;
      notifyListeners();
    }
    return erro;
  }

  List<Map<String, int>>? get _animaisLote {
    final ids = loteSelecionado?.animalIds ?? const <int>[];
    if (ids.isEmpty) {
      return null;
    }
    return [
      for (final id in ids) {'id': id},
    ];
  }

  Future<String?> _enviar(Map<String, dynamic> fields, String falha) async {
    saving = true;
    notifyListeners();
    try {
      final user = await SessionStorage.getUserSession();
      if (user == null) {
        throw ApiException('Usuario nao autenticado.');
      }
      final farmId = await _resolveFarm(userId: user.id);
      if (farmId == null) {
        throw ApiException('Cadastre uma fazenda antes de registrar o manejo.');
      }
      final result = await _adicionar.reprodutivo(
        appUsersId: user.id,
        appFazendasId: farmId,
        fields: fields,
      );
      if (!result.isSuccess) {
        return result.message;
      }
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return falha;
    } finally {
      saving = false;
      notifyListeners();
    }
  }

  DateTime get dataAtual {
    final parts = data.text.split('/');
    if (parts.length != 3) {
      return DateTime.now();
    }
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) {
      return DateTime.now();
    }
    return DateTime(year, month, day);
  }

  void _onBrinco() {
    if (_silencio) {
      return;
    }
    touroId = null;
    animalId = null;
    _busca?.cancel();
    final texto = brinco.text.trim();
    if (texto.isEmpty) {
      touros = const [];
      buscando = false;
      notifyListeners();
      return;
    }
    notifyListeners();
    _busca = Timer(const Duration(milliseconds: 400), () => _buscar(texto));
  }

  Future<void> _buscar(String texto) async {
    final token = ++_buscaToken;
    buscando = true;
    notifyListeners();
    try {
      final user = await SessionStorage.getUserSession();
      if (user == null) {
        throw ApiException('Usuario nao autenticado.');
      }
      final farmId = await _resolveFarm(userId: user.id);
      if (farmId == null) {
        throw ApiException('Cadastre uma fazenda antes de buscar o brinco.');
      }
      final result = await _getAnimals(
        AnimalsFilterEntity(
          appUsersId: user.id,
          appFazendasId: farmId,
          brinco: texto,
        ),
      );
      if (token != _buscaToken) {
        return;
      }
      touros = result.data;
      _autoSelecionarTouroSeUnico(texto);
    } on ApiException catch (e) {
      if (token != _buscaToken) {
        return;
      }
      touros = const [];
      error = e.message;
    } catch (_) {
      if (token != _buscaToken) {
        return;
      }
      touros = const [];
    } finally {
      if (token == _buscaToken) {
        buscando = false;
        notifyListeners();
      }
    }
  }

  void _autoSelecionarTouroSeUnico(String texto) {
    if (touros.isEmpty) {
      return;
    }
    final exato = touros.where((animal) {
      return (animal.brinco?.trim() ?? '').toLowerCase() == texto.toLowerCase();
    });
    final escolhido = exato.length == 1
        ? exato.first
        : (touros.length == 1 ? touros.first : null);
    if (escolhido == null) {
      return;
    }
    if (painel == ManejoReprodutivoPainel.aborto) {
      selecionarAnimal(escolhido);
    } else {
      selecionarTouro(escolhido);
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  @override
  void dispose() {
    _busca?.cancel();
    brinco.removeListener(_onBrinco);
    dias.removeListener(notifyListeners);
    quantidade.removeListener(notifyListeners);
    motivo.removeListener(notifyListeners);
    data.dispose();
    brinco.dispose();
    dias.dispose();
    semen.dispose();
    responsavel.dispose();
    quantidade.dispose();
    motivo.dispose();
    super.dispose();
  }
}
