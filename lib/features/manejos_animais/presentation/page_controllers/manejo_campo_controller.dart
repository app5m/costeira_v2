import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/common/get_list/domain/entities/list_item_entity.dart';
import 'package:costeira/core/common/get_list/presentation/controllers/get_list_controller.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/features/fazendas/domain/usecases/resolve_current_farm_id.dart';
import 'package:costeira/features/insumos/domain/entities/insumos.dart';
import 'package:costeira/features/insumos/domain/usecases/get_insumos_usecase.dart';
import 'package:costeira/features/manejos_animais/domain/usecases/adicionar_manejo_animal_usecase.dart';
import 'package:costeira/features/potreiros/domain/entities/potreiro_entity.dart';
import 'package:costeira/features/potreiros/presentation/controllers/list_potreiros_controller.dart';
import 'package:flutter/material.dart';

enum ManejoCampoDosagem { hectare, area }

class ManejoCampoController extends ChangeNotifier {
  ManejoCampoController(
    this._potreiros,
    this._getList,
    this._getInsumos,
    this._adicionar,
    this._resolveFarm,
  ) {
    quantidade.addListener(notifyListeners);
  }

  final ListPotreirosController _potreiros;
  final GetListController _getList;
  final GetInsumosUsecase _getInsumos;
  final AdicionarManejoAnimalUsecase _adicionar;
  final ResolveCurrentFarmId _resolveFarm;

  final data = TextEditingController();
  final obs = TextEditingController();
  final quantidade = TextEditingController();

  bool loading = true;
  bool saving = false;
  bool usarProduto = false;
  String? error;
  int? piqueteId;
  int? tipoId;
  int? insumoId;
  ManejoCampoDosagem dosagem = ManejoCampoDosagem.hectare;
  List<ListItemEntity> tipos = const [];
  List<InsumoEntity> insumos = const [];

  List<PotreiroEntity> get piquetes => _potreiros.potreiros;

  PotreiroEntity? get piquete => piquetes.where((item) => item.id == piqueteId).firstOrNull;

  double? get area => piquete?.areaUtil ?? piquete?.areaTotal;

  InsumoEntity? get insumo => insumos.where((item) => item.id == insumoId).firstOrNull;

  double get quantidadeInformada => _numero(quantidade.text);

  double get quantidadeTotal {
    if (dosagem == ManejoCampoDosagem.area) {
      return quantidadeInformada;
    }
    return quantidadeInformada * (area ?? 0);
  }

  int get quantidadeInteira => quantidadeTotal.round();

  bool get saldoInsuficiente {
    final saldo = insumo?.qtdTotal;
    if (!usarProduto || saldo == null || quantidade.text.trim().isEmpty) {
      return false;
    }
    return quantidadeInteira > saldo;
  }

  bool get podeRegistrar {
    if (saving || piqueteId == null || tipoId == null) {
      return false;
    }
    if (!usarProduto) {
      return true;
    }
    if (insumoId == null || quantidadeInformada <= 0 || quantidadeInteira < 1 || saldoInsuficiente) {
      return false;
    }
    if (dosagem == ManejoCampoDosagem.hectare && (area ?? 0) <= 0) {
      return false;
    }
    return true;
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
      final farmId = await _resolveFarm(userId: user.id);
      await _potreiros.load();
      final macho = await _getList.load(1);
      final femea = await _getList.load(2);
      final categorias = [
        ...?macho?.manejosCategorias,
        ...?femea?.manejosCategorias,
      ];
      tipos = categorias.where((item) => item.id == 14).map((item) => item.tipos).firstOrNull ??
          const [];
      if (farmId != null) {
        final lista = await _getInsumos(
          InsumosFilterEntity(appUsersId: user.id, appFazendasId: farmId),
        );
        insumos = lista.lista;
      }
    } on ApiException catch (e) {
      error = e.message;
    } catch (_) {
      error = 'Nao foi possivel carregar o manejo de campo.';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void setPiquete(int? id) {
    piqueteId = id;
    notifyListeners();
  }

  void setTipo(int? id) {
    tipoId = id;
    notifyListeners();
  }

  void setInsumo(int? id) {
    insumoId = id;
    notifyListeners();
  }

  void setUsarProduto(bool value) {
    usarProduto = value;
    notifyListeners();
  }

  void setDosagem(ManejoCampoDosagem value) {
    dosagem = value;
    notifyListeners();
  }

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

  Future<String?> registrar() async {
    if (!podeRegistrar) {
      return 'Preencha o piquete e o tipo de manejo.';
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
        throw ApiException('Cadastre uma fazenda antes de registrar o manejo.');
      }
      // API exige tipo_dosagem (3|4) e dosagem > 0 mesmo sem produto.
      final tipoDosagem = dosagem == ManejoCampoDosagem.hectare ? 3 : 4;
      final dosagemValor = quantidadeInteira > 0 ? quantidadeInteira : 1;
      final result = await _adicionar.campo(
        appUsersId: user.id,
        appFazendasId: farmId,
        fields: {
          'id_categoria': 14,
          'id_tipo': tipoId,
          'app_potreiros_id': piqueteId,
          'data': data.text,
          'tipo_dosagem': tipoDosagem,
          'dosagem': dosagemValor,
          if (obs.text.trim().isNotEmpty) 'obs': obs.text.trim(),
          if (usarProduto) ...{
            'id_estoque': insumoId,
            'quantidade': quantidadeInteira,
          },
        },
      );
      if (!result.isSuccess) {
        return result.message;
      }
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'Nao foi possivel registrar o manejo.';
    } finally {
      saving = false;
      notifyListeners();
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  double _numero(String raw) {
    return double.tryParse(raw.trim().replaceAll(',', '.')) ?? 0;
  }

  @override
  void dispose() {
    quantidade.removeListener(notifyListeners);
    data.dispose();
    obs.dispose();
    quantidade.dispose();
    super.dispose();
  }
}
