import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/common/get_list/domain/entities/get_list_entity.dart';
import 'package:costeira/core/common/get_list/domain/entities/list_category_entity.dart';
import 'package:costeira/core/common/get_list/domain/entities/list_item_entity.dart';
import 'package:costeira/core/common/get_list/domain/entities/list_subcategory_entity.dart';
import 'package:costeira/core/common/get_list/presentation/controllers/get_list_controller.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/features/animals/domain/entities/animal_entity.dart';
import 'package:costeira/features/animals/domain/entities/animal_lot_entity.dart';
import 'package:costeira/features/animals/domain/entities/animals_filter_entity.dart';
import 'package:costeira/features/animals/domain/usecases/get_animals_usecase.dart';
import 'package:costeira/features/animals/presentation/controllers/list_animal_lots_controller.dart';
import 'package:costeira/features/fazendas/domain/usecases/resolve_current_farm_id.dart';
import 'package:costeira/features/insumos/domain/entities/insumos.dart';
import 'package:costeira/features/insumos/domain/usecases/get_insumos_usecase.dart';
import 'package:costeira/features/manejos_animais/presentation/controllers/adicionar_manejo_animal_controller.dart';
import 'package:costeira/features/potreiros/domain/entities/potreiro_entity.dart';
import 'package:costeira/features/potreiros/presentation/controllers/list_potreiros_controller.dart';
import 'package:flutter/material.dart';

enum ManejoEscopo { lote, parcial }

enum ManejoPainel { nenhum, pesagem, sanitario, nutricao, veterinario, identificacao, trocaCategoria, movimentacao }

enum ManejoDestino { piquete, lote }

enum ManejoIdentificacaoModo { nova, troca }

class ManejoSessaoAcao {
  const ManejoSessaoAcao({
    required this.titulo,
    required this.detalhe,
    required this.fields,
  });

  final String titulo;
  final String detalhe;
  final Map<String, dynamic> fields;
}

class PesagemLinha {
  const PesagemLinha({
    required this.animal,
    required this.pesoAtual,
    this.ganho,
    this.gmd,
  });

  final AnimalEntity animal;
  final double pesoAtual;
  final double? ganho;
  final double? gmd;
}

class ManejoAnimalSessaoController extends ChangeNotifier {
  ManejoAnimalSessaoController(
    this._getAnimals,
    this._getInsumos,
    this._lots,
    this._potreiros,
    this._getList,
    this._adicionar,
    this._resolveFarm,
  );

  final GetAnimalsUsecase _getAnimals;
  final GetInsumosUsecase _getInsumos;
  final ListAnimalLotsController _lots;
  final ListPotreirosController _potreiros;
  final GetListController _getList;
  final AdicionarManejoAnimalController _adicionar;
  final ResolveCurrentFarmId _resolveFarm;

  final data = TextEditingController();
  final obs = TextEditingController();
  final dose = TextEditingController();
  final responsavel = TextEditingController();
  final novoBrinco = TextEditingController();
  final motivoTroca = TextEditingController();
  final pesos = <int, TextEditingController>{};

  bool loading = true;
  bool sessionOn = false;
  bool saving = false;
  String? error;
  String? formError;

  int? categoriaId;
  int? faseId;
  int? piqueteId;
  int? loteId;
  final selectedStatuses = <String>{};

  List<AnimalEntity> animais = const [];
  List<InsumoEntity> insumos = const [];
  List<ListCategoryEntity> categorias = const [];
  List<ManejoCategoriaLista> manejos = const [];

  ManejoPainel painel = ManejoPainel.nenhum;
  ManejoEscopo escopo = ManejoEscopo.lote;
  final selecionados = <int>{};
  int? score;
  int? insumoId;
  int? tipoId;
  bool usarProduto = false;
  ManejoIdentificacaoModo identificacaoModo = ManejoIdentificacaoModo.nova;
  int? animalTrocaId;
  int? novaCategoriaId;
  int? novaFaseId;
  ManejoDestino destino = ManejoDestino.piquete;
  int? piqueteDestinoId;
  int? loteDestinoId;

  final acoes = <ManejoSessaoAcao>[];

  List<AnimalLotEntity> get lotes => _lots.lots;
  List<PotreiroEntity> get piquetes => _potreiros.potreiros;

  List<ListSubcategoryEntity> get fases =>
      categorias.where((item) => item.id == categoriaId).firstOrNull?.subcategorias ??
      const [];

  List<ListSubcategoryEntity> get fasesNovas =>
      categorias.where((item) => item.id == novaCategoriaId).firstOrNull?.subcategorias ??
      const [];

  List<String> get statusOpcoes {
    final nomes = animais
        .map((animal) => animal.status?.trim())
        .whereType<String>()
        .where((item) => item.isNotEmpty)
        .toSet()
        .toList();
    nomes.sort();
    return nomes;
  }

  List<AnimalEntity> get grupo {
    if (selectedStatuses.isEmpty) {
      return animais;
    }
    return animais.where((animal) {
      final status = animal.status?.trim().toLowerCase();
      return selectedStatuses.any((item) => item.toLowerCase() == status);
    }).toList(growable: false);
  }

  List<AnimalEntity> get escopoAnimais {
    if (escopo == ManejoEscopo.lote) {
      return grupo;
    }
    return grupo
        .where((animal) => selecionados.contains(animal.id))
        .toList(growable: false);
  }

  String get categoriaNome => _nome(categorias, categoriaId);
  String get faseNome => _nome(fases, faseId);
  String get piqueteNome =>
      piquetes.where((item) => item.id == piqueteId).map((item) => item.nome).firstOrNull ??
      '';
  String get loteNome =>
      lotes.where((item) => item.id == loteId).map((item) => item.nome).firstOrNull ?? '';

  bool get podeConfirmar => grupo.isNotEmpty && !loading;

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
      final farmId = await _resolveFarm(userId: user.id);
      await Future.wait([_potreiros.load(), _lots.load()]);
      final macho = await _getList.load(1);
      final femea = await _getList.load(2);
      categorias = [
        ...?macho?.animaisCategorias,
        ...?femea?.animaisCategorias,
      ];
      manejos = femea?.manejosCategorias ?? macho?.manejosCategorias ?? const [];
      final lista = await _getInsumos(
        InsumosFilterEntity(appUsersId: user.id, appFazendasId: farmId),
      );
      insumos = lista.lista;
    } on ApiException catch (e) {
      error = e.message;
    } catch (_) {
      error = 'Nao foi possivel carregar o grupo.';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> refreshAnimais() async {
    if (categoriaId == null && piqueteId == null && loteId == null) {
      animais = const [];
      notifyListeners();
      return;
    }
    loading = true;
    notifyListeners();
    try {
      final user = await SessionStorage.getUserSession();
      if (user == null) {
        throw ApiException('Usuario nao autenticado.');
      }
      final farmId = await _resolveFarm(userId: user.id);
      final result = await _getAnimals(
        AnimalsFilterEntity(
          appUsersId: user.id,
          appFazendasId: farmId,
          appAnimaisCategoriasId: categoriaId,
          appAnimaisSubcategoriasId: faseId,
          appPotreirosId: piqueteId,
          appAnimaisLotesId: loteId,
        ),
      );
      animais = result.data;
    } on ApiException catch (e) {
      error = e.message;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void setCategoria(int? id) {
    categoriaId = id;
    faseId = null;
    notifyListeners();
    refreshAnimais();
  }

  void setFase(int? id) {
    faseId = id;
    notifyListeners();
    refreshAnimais();
  }

  void setPiquete(int? id) {
    piqueteId = id;
    notifyListeners();
    refreshAnimais();
  }

  void setLote(int? id) {
    loteId = id;
    notifyListeners();
    refreshAnimais();
  }

  void toggleStatus(String status) {
    if (!selectedStatuses.add(status)) {
      selectedStatuses.remove(status);
    }
    notifyListeners();
  }

  void confirmarGrupo() {
    if (!podeConfirmar) {
      return;
    }
    sessionOn = true;
    painel = ManejoPainel.nenhum;
    notifyListeners();
  }

  void trocarGrupo() {
    sessionOn = false;
    painel = ManejoPainel.nenhum;
    notifyListeners();
  }

  void abrir(ManejoPainel value) {
    painel = painel == value ? ManejoPainel.nenhum : value;
    formError = null;
    escopo = ManejoEscopo.lote;
    selecionados.clear();
    score = null;
    insumoId = null;
    tipoId = null;
    usarProduto = false;
    identificacaoModo = ManejoIdentificacaoModo.nova;
    animalTrocaId = null;
    novaCategoriaId = null;
    novaFaseId = null;
    destino = ManejoDestino.piquete;
    piqueteDestinoId = null;
    loteDestinoId = null;
    obs.clear();
    dose.clear();
    responsavel.clear();
    novoBrinco.clear();
    motivoTroca.clear();
    _syncPesos();
    notifyListeners();
  }

  void setEscopo(ManejoEscopo value) {
    escopo = value;
    _syncPesos();
    notifyListeners();
  }

  void toggleAnimal(int id) {
    if (!selecionados.add(id)) {
      selecionados.remove(id);
    }
    _syncPesos();
    notifyListeners();
  }

  List<InsumoEntity> insumosDaCategoria(int categoriaEstoqueId) {
    return insumos
        .where((item) => item.appEstoquesInsumosCategoriasId == categoriaEstoqueId)
        .toList(growable: false);
  }

  String nomeCategoriaEstoque(int id) {
    final lista = _getList.result?.estoqueInsumosCategorias ?? const [];
    return lista.where((item) => item.id == id).map((item) => item.nome).firstOrNull ?? '';
  }

  List<ListItemEntity> tiposDe(int manejoId) {
    return manejos.where((item) => item.id == manejoId).map((item) => item.tipos).firstOrNull ??
        const [];
  }

  InsumoEntity? get insumoSelecionado {
    return insumos.where((item) => item.id == insumoId).firstOrNull;
  }

  double get dosePorAnimal => _numero(dose.text);

  double get doseTotal => dosePorAnimal * escopoAnimais.length;

  bool get saldoInsuficiente {
    final saldo = insumoSelecionado?.qtdTotal;
    if (saldo == null || dose.text.trim().isEmpty) {
      return false;
    }
    return doseTotal > saldo;
  }

  List<PesagemLinha> get linhasPesagem {
    return escopoAnimais.map((animal) {
      final atual = _numero(pesos[animal.id]?.text ?? '');
      final ultimo = animal.ultimoPeso;
      double? ganho;
      double? gmd;
      if (pesos[animal.id]?.text.trim().isNotEmpty == true &&
          ultimo != null &&
          ultimo.temPesagem) {
        ganho = atual - ultimo.peso!;
        final dias = ultimo.qtdDias ?? 0;
        if (dias > 0) {
          gmd = ganho / dias;
        }
      }
      return PesagemLinha(animal: animal, pesoAtual: atual, ganho: ganho, gmd: gmd);
    }).toList(growable: false);
  }

  void registrarPainel() {
    formError = null;
    final acao = switch (painel) {
      ManejoPainel.pesagem => _pesagem(),
      ManejoPainel.sanitario => _estoque(2, 1, 'Sanitário'),
      ManejoPainel.nutricao => _estoque(3, 2, 'Nutrição'),
      ManejoPainel.veterinario => _veterinario(),
      ManejoPainel.identificacao => _identificacao(),
      ManejoPainel.trocaCategoria => _trocaCategoria(),
      ManejoPainel.movimentacao => _movimentacao(),
      ManejoPainel.nenhum => null,
    };
    if (acao == null) {
      notifyListeners();
      return;
    }
    acoes.add(acao);
    painel = ManejoPainel.nenhum;
    notifyListeners();
  }

  Future<String?> finalizar() async {
    if (acoes.isEmpty) {
      return 'Registre ao menos uma ação.';
    }
    saving = true;
    notifyListeners();
    while (acoes.isNotEmpty) {
      final result = await _adicionar.submit(acoes.first.fields);
      if (result == null || !result.isSuccess) {
        saving = false;
        notifyListeners();
        return _adicionar.errorMessage ?? 'Nao foi possivel finalizar a sessao.';
      }
      acoes.removeAt(0);
    }
    saving = false;
    notifyListeners();
    return null;
  }

  ManejoSessaoAcao? _pesagem() {
    final preenchidas = linhasPesagem
        .where((linha) => (pesos[linha.animal.id]?.text.trim().isNotEmpty ?? false))
        .toList(growable: false);
    if (preenchidas.isEmpty) {
      formError = 'Informe o peso atual de ao menos um animal.';
      return null;
    }
    return ManejoSessaoAcao(
      titulo: 'Pesagem',
      detalhe: '${preenchidas.length} animal(is)',
      fields: {
        'id_categoria': 1,
        'data': data.text,
        if (score != null) 'score': score,
        if (obs.text.trim().isNotEmpty) 'obs': obs.text.trim(),
        'animais': preenchidas.map((linha) {
          final ultimo = linha.animal.ultimoPeso;
          return {
            'id': linha.animal.id,
            'peso_atual': linha.pesoAtual.toStringAsFixed(2),
            if (linha.ganho != null) 'ganho': _ganho(linha.ganho!),
            if (linha.gmd != null) 'gmd': '${_gmd(linha.gmd!)} kg/d',
            if (ultimo?.qtdDias != null) 'qtd_dias': ultimo!.qtdDias,
          };
        }).toList(growable: false),
      },
    );
  }

  ManejoSessaoAcao? _estoque(int categoria, int estoqueCategoria, String titulo) {
    final produtos = insumosDaCategoria(estoqueCategoria);
    if (produtos.isEmpty) {
      formError =
          'Nenhum produto cadastrado na categoria de estoque "${nomeCategoriaEstoque(estoqueCategoria)}".';
      return null;
    }
    if (escopoAnimais.isEmpty || insumoId == null || dosePorAnimal <= 0) {
      formError = 'Escolha o produto, a dose e os animais.';
      return null;
    }
    if (saldoInsuficiente) {
      formError = 'Saldo insuficiente no estoque para esta aplicação.';
      return null;
    }
    final produto = insumoSelecionado!;
    return ManejoSessaoAcao(
      titulo: titulo,
      detalhe: '${produto.nome} · ${_num(doseTotal)} ${produto.unidade?.nome ?? ''}',
      fields: {
        'id_categoria': categoria,
        'id_estoque': produto.id,
        'tipo_dosagem': 2,
        'dosagem': doseTotal,
        'data': data.text,
        if (obs.text.trim().isNotEmpty) 'obs': obs.text.trim(),
        'animais': _ids(escopoAnimais),
      },
    );
  }

  ManejoSessaoAcao? _veterinario() {
    if (tipoId == null || escopoAnimais.isEmpty) {
      formError = 'Escolha o procedimento e os animais.';
      return null;
    }
    if (usarProduto) {
      final base = _estoque(4, 1, 'Veterinário');
      if (base == null) {
        return null;
      }
      return ManejoSessaoAcao(
        titulo: 'Veterinário',
        detalhe: base.detalhe,
        fields: {
          ...base.fields,
          'id_tipo': tipoId,
          if (responsavel.text.trim().isNotEmpty) 'responsavel': responsavel.text.trim(),
        },
      );
    }
    return ManejoSessaoAcao(
      titulo: 'Veterinário',
      detalhe: tiposDe(4).where((item) => item.id == tipoId).map((item) => item.nome).firstOrNull ??
          '',
      fields: {
        'id_categoria': 4,
        'id_tipo': tipoId,
        'data': data.text,
        if (responsavel.text.trim().isNotEmpty) 'responsavel': responsavel.text.trim(),
        if (obs.text.trim().isNotEmpty) 'obs': obs.text.trim(),
        'animais': _ids(escopoAnimais),
      },
    );
  }

  ManejoSessaoAcao? _identificacao() {
    if (tipoId == null) {
      formError = 'Escolha o tipo de identificação.';
      return null;
    }
    if (identificacaoModo == ManejoIdentificacaoModo.troca) {
      if (animalTrocaId == null || novoBrinco.text.trim().isEmpty) {
        formError = 'Escolha um animal e informe o novo brinco.';
        return null;
      }
      return ManejoSessaoAcao(
        titulo: 'Troca de brinco',
        detalhe: novoBrinco.text.trim(),
        fields: {
          'id': animalTrocaId,
          'id_categoria': 5,
          'id_tipo': tipoId,
          'novo_brinco': novoBrinco.text.trim(),
          if (motivoTroca.text.trim().isNotEmpty) 'motivo_troca_brinco': motivoTroca.text.trim(),
          'data': data.text,
          'animais': [
            {'id': animalTrocaId},
          ],
        },
      );
    }
    final alvo = escopoAnimais.where((animal) {
      if (tipoId == 6) {
        return (animal.brinco ?? '').trim().isEmpty;
      }
      return true;
    }).toList(growable: false);
    if (alvo.isEmpty) {
      formError = 'Todos os animais do grupo já possuem brinco.';
      return null;
    }
    return ManejoSessaoAcao(
      titulo: 'Identificação',
      detalhe: '${alvo.length} animal(is)',
      fields: {
        'id_categoria': 5,
        'id_tipo': tipoId,
        'data': data.text,
        'animais': _ids(alvo),
      },
    );
  }

  ManejoSessaoAcao? _trocaCategoria() {
    if (novaCategoriaId == null || novaFaseId == null || escopoAnimais.isEmpty || loteId == null) {
      formError = 'Escolha a nova categoria, a fase e os animais.';
      return null;
    }
    return ManejoSessaoAcao(
      titulo: 'Troca de categoria',
      detalhe: _nome(categorias, novaCategoriaId),
      fields: {
        'id_categoria': 6,
        'app_animais_categorias_id': novaCategoriaId,
        'app_animais_subcategorias_id': novaFaseId,
        'app_animais_lotes_id': loteId,
        'data': data.text,
        'animais': _ids(escopoAnimais),
      },
    );
  }

  ManejoSessaoAcao? _movimentacao() {
    if (escopoAnimais.isEmpty) {
      formError = 'Escolha os animais.';
      return null;
    }
    if (destino == ManejoDestino.piquete && piqueteDestinoId == null) {
      formError = 'Escolha o piquete de destino.';
      return null;
    }
    if (destino == ManejoDestino.lote && loteDestinoId == null) {
      formError = 'Escolha o lote de destino.';
      return null;
    }
    final nome = destino == ManejoDestino.piquete
        ? piquetes.where((item) => item.id == piqueteDestinoId).map((item) => item.nome).firstOrNull
        : lotes.where((item) => item.id == loteDestinoId).map((item) => item.nome).firstOrNull;
    return ManejoSessaoAcao(
      titulo: 'Movimentação',
      detalhe: nome ?? '',
      fields: {
        'id_categoria': 7,
        'data': data.text,
        if (destino == ManejoDestino.piquete) 'app_potreiros_id': piqueteDestinoId,
        if (destino == ManejoDestino.lote) 'app_animais_lotes_id': loteDestinoId,
        'animais': _ids(escopoAnimais),
      },
    );
  }

  PotreiroEntity? get piqueteDestino =>
      piquetes.where((item) => item.id == piqueteDestinoId).firstOrNull;

  void _syncPesos() {
    final ids = escopoAnimais.map((animal) => animal.id).toSet();
    for (final id in pesos.keys.toList()) {
      if (!ids.contains(id)) {
        pesos.remove(id)?.dispose();
      }
    }
    for (final animal in escopoAnimais) {
      pesos.putIfAbsent(animal.id, TextEditingController.new);
    }
  }

  List<Map<String, dynamic>> _ids(List<AnimalEntity> lista) {
    return lista.map((animal) => {'id': animal.id}).toList(growable: false);
  }

  void refresh() => notifyListeners();

  void setData(DateTime value) {
    data.text = _formatDate(value);
    notifyListeners();
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

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  String _nome(List<ListItemEntity> lista, int? id) {
    return lista.where((item) => item.id == id).map((item) => item.nome).firstOrNull ?? '';
  }

  double _numero(String raw) {
    final normal = raw.trim().replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(normal) ?? double.tryParse(raw.trim()) ?? 0;
  }

  String _ganho(double value) {
    final text = value == value.roundToDouble()
        ? value.abs().toStringAsFixed(0)
        : value.abs().toStringAsFixed(1);
    return value >= 0 ? '+${text}kg' : '-${text}kg';
  }

  String _gmd(double value) {
    return value.toStringAsFixed(3).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }

  String _num(double value) {
    return value == value.roundToDouble() ? value.toStringAsFixed(0) : value.toStringAsFixed(2);
  }

  @override
  void dispose() {
    data.dispose();
    obs.dispose();
    dose.dispose();
    responsavel.dispose();
    novoBrinco.dispose();
    motivoTroca.dispose();
    for (final controller in pesos.values) {
      controller.dispose();
    }
    super.dispose();
  }
}
