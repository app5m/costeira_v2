import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/common/get_list/domain/entities/get_list_entity.dart';
import 'package:costeira/core/common/get_list/domain/entities/list_category_entity.dart';
import 'package:costeira/core/common/get_list/domain/entities/list_item_entity.dart';
import 'package:costeira/core/common/get_list/presentation/controllers/get_list_controller.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/features/animals/domain/entities/animal_lot_entity.dart';
import 'package:costeira/features/animals/presentation/controllers/list_animal_lots_controller.dart';
import 'package:costeira/features/fazendas/domain/usecases/resolve_current_farm_id.dart';
import 'package:costeira/features/insumos/domain/entities/insumos.dart';
import 'package:costeira/features/insumos/domain/usecases/get_insumos_usecase.dart';
import 'package:costeira/features/manejos_animais/domain/entities/manejo_animal_lista.dart';
import 'package:costeira/features/manejos_animais/domain/manejo_atualizacao.dart';
import 'package:costeira/features/manejos_animais/domain/usecases/adicionar_manejo_animal_usecase.dart';
import 'package:costeira/features/potreiros/domain/entities/potreiro_entity.dart';
import 'package:costeira/features/potreiros/presentation/controllers/list_potreiros_controller.dart';
import 'package:flutter/material.dart';

class ManejoEditarController extends ChangeNotifier {
  ManejoEditarController({
    required this.item,
    required AdicionarManejoAnimalUsecase adicionar,
    required GetListController getList,
    required ListAnimalLotsController lots,
    required ListPotreirosController potreiros,
    required GetInsumosUsecase getInsumos,
    required ResolveCurrentFarmId resolveFarm,
  }) : _adicionar = adicionar,
       _getList = getList,
       _lots = lots,
       _potreiros = potreiros,
       _getInsumos = getInsumos,
       _resolveFarm = resolveFarm {
    for (final campo in [obs, score, dosagem, responsavel, novoBrinco, motivo, duracao, semen, quantidade]) {
      campo.addListener(notifyListeners);
    }
  }

  final ManejoAnimalListaItem item;
  final AdicionarManejoAnimalUsecase _adicionar;
  final GetListController _getList;
  final ListAnimalLotsController _lots;
  final ListPotreirosController _potreiros;
  final GetInsumosUsecase _getInsumos;
  final ResolveCurrentFarmId _resolveFarm;

  final data = TextEditingController();
  final obs = TextEditingController();
  final score = TextEditingController();
  final dosagem = TextEditingController();
  final responsavel = TextEditingController();
  final novoBrinco = TextEditingController();
  final motivo = TextEditingController();
  final duracao = TextEditingController();
  final semen = TextEditingController();
  final quantidade = TextEditingController();

  bool loading = true;
  bool saving = false;
  String? error;
  int? tipoId;
  int? tipoDosagem;
  int? loteId;
  int? piqueteId;
  int? categoriaAnimalId;
  int? faseId;
  int? racaId;
  int? classificacao;
  int? estoqueId;
  bool trocaBrinco = false;
  bool usarProduto = false;
  bool destinoPiquete = false;
  List<ListItemEntity> tipos = const [];
  List<ListItemEntity> racas = const [];
  List<ListCategoryEntity> categoriasAnimais = const [];
  List<InsumoEntity> insumos = const [];

  int? get categoria => item.idCategoria;

  List<AnimalLotEntity> get lotes => _lots.lots;

  List<PotreiroEntity> get piquetes => _potreiros.potreiros;

  List<ListItemEntity> get fases =>
      categoriasAnimais
          .where((item) => item.id == categoriaAnimalId)
          .map((item) => item.subcategorias)
          .firstOrNull ??
      const [];

  bool get podeSalvar {
    if (saving || item.id == null || data.text.trim().isEmpty) {
      return false;
    }
    return switch (categoria) {
      2 || 3 => dosagem.text.trim().isNotEmpty,
      4 || 5 || 10 || 11 || 14 => tipoId != null,
      6 => categoriaAnimalId != null && faseId != null && loteId != null,
      7 => destinoPiquete ? piqueteId != null : loteId != null,
      8 => loteId != null && (int.tryParse(duracao.text.trim()) ?? 0) > 0,
      13 => motivo.text.trim().isNotEmpty && loteId != null,
      _ => true,
    } &&
        (categoria != 5 || !trocaBrinco || novoBrinco.text.trim().isNotEmpty) &&
        (categoria != 11 || classificacao != null) &&
        (categoria != 14 || piqueteId != null) &&
        (categoria != 14 ||
            !usarProduto ||
            (estoqueId != null && (num.tryParse(quantidade.text.trim().replaceAll(',', '.')) ?? 0) >= 1));
  }

  Future<void> init() async {
    _preencher();
    if (!_precisaListas) {
      loading = false;
      notifyListeners();
      return;
    }
    loading = true;
    error = null;
    notifyListeners();
    try {
      if (_precisaCatalogo) {
        final macho = await _getList.load(1);
        final femea = await _getList.load(2);
        final manejos = [
          ...?macho?.manejosCategorias,
          ...?femea?.manejosCategorias,
        ];
        tipos = _tiposDe(manejos);
        racas = macho?.animaisBasesRaciais ?? const [];
        categoriasAnimais = [
          ...?macho?.animaisCategorias,
          ...?femea?.animaisCategorias,
        ];
      }
      if ({6, 7, 8, 10, 11, 13}.contains(categoria)) {
        await _lots.load();
      }
      if ({7, 14}.contains(categoria)) {
        await _potreiros.load();
      }
      if (categoria == 14) {
        final user = await SessionStorage.getUserSession();
        final farmId = user == null ? null : await _resolveFarm(userId: user.id);
        if (user != null && farmId != null) {
          final lista = await _getInsumos(
            InsumosFilterEntity(appUsersId: user.id, appFazendasId: farmId),
          );
          insumos = lista.lista;
        }
      }
    } on ApiException catch (e) {
      error = e.message;
    } catch (_) {
      error = 'Nao foi possivel carregar o manejo.';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  bool get _precisaCatalogo => {4, 5, 6, 8, 10, 11, 14}.contains(categoria);

  bool get _precisaListas => _precisaCatalogo || {7, 13}.contains(categoria);

  List<ListItemEntity> _tiposDe(List<ManejoCategoriaLista> manejos) {
    final id = switch (categoria) {
      4 => 4,
      5 => 5,
      10 => 10,
      11 => 11,
      14 => 14,
      _ => null,
    };
    if (id == null) {
      return const [];
    }
    return manejos.where((item) => item.id == id).map((item) => item.tipos).firstOrNull ?? const [];
  }

  void _preencher() {
    final json = item.dados;
    data.text = _texto(json['data']).isEmpty ? item.data : _texto(json['data']);
    obs.text = _texto(json['obs']);
    score.text = _texto(json['score']);
    dosagem.text = _texto(json['dosagem']);
    responsavel.text = _texto(json['responsavel']);
    novoBrinco.text = _texto(json['novo_brinco']);
    motivo.text = _texto(json['motivo_troca_brinco']).isNotEmpty
        ? _texto(json['motivo_troca_brinco'])
        : _texto(json['motivo']);
    duracao.text = _texto(json['duracao_estacao']).isNotEmpty
        ? _texto(json['duracao_estacao'])
        : _texto(json['duracao_touro']);
    semen.text = _texto(json['semen_utilizado']);
    quantidade.text = _texto(json['quantidade']);
    tipoId = _inteiro(json['app_manejos_tipos_id']) ?? _idMapa(json['tipo']);
    tipoDosagem = _inteiro(json['tipo_dosagem']);
    loteId = _inteiro(json['app_animais_lotes_id']) ?? _idMapa(json['lote_destino']) ?? _idMapa(json['lote']);
    piqueteId = _inteiro(json['app_potreiros_id']) ?? _idMapa(json['potreiro_destino']);
    categoriaAnimalId =
        _inteiro(json['app_animais_categorias_id']) ?? _idMapa(json['categoria_destino']);
    faseId = _inteiro(json['app_animais_subcategorias_id']) ??
        _idMapa(json['subcategoria_destino']) ??
        _idMapa(json['fase_destino']);
    racaId = _inteiro(json['ut_bases_raciais_id']);
    classificacao = _inteiro(json['classificacao']);
    estoqueId = _inteiro(json['app_estoques_insumos_id']) ?? _idMapa(json['estoque']);
    trocaBrinco = novoBrinco.text.isNotEmpty || _texto(json['motivo_troca_brinco']).isNotEmpty;
    usarProduto = estoqueId != null;
    destinoPiquete = piqueteId != null;
  }

  void setData(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    data.text = '$day/$month/${value.year}';
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

  void setTipo(int? id) {
    tipoId = id;
    notifyListeners();
  }

  void setLote(int? id) {
    loteId = id;
    notifyListeners();
  }

  void setPiquete(int? id) {
    piqueteId = id;
    notifyListeners();
  }

  void setCategoriaAnimal(int? id) {
    categoriaAnimalId = id;
    faseId = null;
    notifyListeners();
  }

  void setFase(int? id) {
    faseId = id;
    notifyListeners();
  }

  void setRaca(int? id) {
    racaId = id;
    notifyListeners();
  }

  void setClassificacao(int id) {
    classificacao = id;
    notifyListeners();
  }

  void setEstoque(int? id) {
    estoqueId = id;
    notifyListeners();
  }

  void setDestinoPiquete(bool value) {
    destinoPiquete = value;
    notifyListeners();
  }

  void setUsarProduto(bool value) {
    usarProduto = value;
    notifyListeners();
  }

  void setTipoDosagem(int value) {
    tipoDosagem = value;
    notifyListeners();
  }

  Future<String?> salvar() async {
    final id = item.id;
    final categoriaId = categoria;
    if (id == null || categoriaId == null || !podeSalvar) {
      return 'Preencha os campos do manejo.';
    }
    saving = true;
    notifyListeners();
    try {
      final user = await SessionStorage.getUserSession();
      if (user == null) {
        throw ApiException('Usuario nao autenticado.');
      }
      final farmId = await _resolveFarm(userId: user.id);
      if (farmId == null) {
        throw ApiException('Cadastre uma fazenda antes de atualizar o manejo.');
      }
      final fields = montarAtualizacaoManejo(
        ManejoEdicaoCampos(
          id: id,
          categoria: categoriaId,
          data: data.text.trim(),
          obs: obs.text,
          score: score.text,
          dosagem: dosagem.text,
          tipoDosagem: tipoDosagem,
          tipoId: tipoId,
          responsavel: responsavel.text,
          novoBrinco: novoBrinco.text,
          motivo: motivo.text,
          loteId: loteId,
          piqueteId: piqueteId,
          categoriaAnimalId: categoriaAnimalId,
          faseId: faseId,
          racaId: racaId,
          duracao: duracao.text,
          semen: semen.text,
          classificacao: classificacao,
          estoqueId: estoqueId,
          quantidade: quantidade.text,
          trocaBrinco: trocaBrinco,
          usarProduto: usarProduto,
          destinoPiquete: destinoPiquete,
        ),
      );
      final ApiMessage result;
      if (categoriaId == 14) {
        result = await _adicionar.campo(
          appUsersId: user.id,
          appFazendasId: farmId,
          fields: fields,
        );
      } else if (categoriaId >= 8) {
        result = await _adicionar.reprodutivo(
          appUsersId: user.id,
          appFazendasId: farmId,
          fields: fields,
        );
      } else {
        result = await _adicionar.call(
          appUsersId: user.id,
          appFazendasId: farmId,
          fields: fields,
        );
      }
      if (!result.isSuccess) {
        return result.message;
      }
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'Nao foi possivel atualizar o manejo.';
    } finally {
      saving = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    for (final campo in [data, obs, score, dosagem, responsavel, novoBrinco, motivo, duracao, semen, quantidade]) {
      campo.removeListener(notifyListeners);
      campo.dispose();
    }
    super.dispose();
  }
}

String _texto(dynamic valor) {
  final texto = valor?.toString().trim() ?? '';
  if (texto.isEmpty || texto == 'null') {
    return '';
  }
  return texto;
}

int? _inteiro(dynamic valor) {
  final texto = _texto(valor);
  if (texto.isEmpty) {
    return null;
  }
  return int.tryParse(texto) ?? num.tryParse(texto.replaceAll(',', '.'))?.toInt();
}

int? _idMapa(dynamic valor) {
  if (valor is Map) {
    return _inteiro(valor['id']);
  }
  return null;
}
