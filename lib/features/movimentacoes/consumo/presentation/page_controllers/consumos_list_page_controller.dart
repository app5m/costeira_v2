import 'package:costeira/features/movimentacoes/consumo/presentation/controllers/delete_consumo_controller.dart';
import 'package:costeira/features/movimentacoes/consumo/presentation/controllers/list_consumos_controller.dart';
import 'package:costeira/features/movimentacoes/domain/entities/consumo_entity.dart';
import 'package:flutter/foundation.dart';

class ConsumosListPageController extends ChangeNotifier {
  ConsumosListPageController(this._listController, this._deleteController) {
    _listController.addListener(notifyListeners);
    _deleteController.addListener(notifyListeners);
  }

  final ListConsumosController _listController;
  final DeleteConsumoController _deleteController;

  List<ConsumoEntity> get consumos => _listController.consumos;
  bool get isLoading =>
      _listController.isLoading || _deleteController.isLoading;
  String? get errorMessage =>
      _listController.errorMessage ?? _deleteController.errorMessage;
  String? get currentDataInFilter => _listController.currentFilter?.dataIn;
  String? get currentDataOutFilter => _listController.currentFilter?.dataOut;

  Future<String?> loadInitialData() async {
    try {
      if (_listController.currentFilter == null) {
        await _listController.load();
      } else {
        await _listController.reload();
      }
      return null;
    } catch (_) {
      return _listController.errorMessage ??
          'Nao foi possivel carregar os consumos.';
    }
  }

  Future<String?> applyDateFilters({
    required String? dataIn,
    required String? dataOut,
  }) async {
    try {
      await _listController.load(dataIn: dataIn, dataOut: dataOut);
      return null;
    } catch (_) {
      return _listController.errorMessage ??
          'Nao foi possivel aplicar os filtros.';
    }
  }

  Future<String?> deleteConsumo(ConsumoEntity consumo) async {
    try {
      final result = await _deleteController.delete(consumo.id);
      if (result == null || !result.isSuccess) {
        return result?.message ?? 'Nao foi possivel excluir o consumo.';
      }

      _listController.removeById(consumo.id);
      await loadInitialData();
      return null;
    } catch (_) {
      return _deleteController.errorMessage ??
          'Nao foi possivel excluir o consumo.';
    }
  }

  bool hasActiveFilters() {
    return (currentDataInFilter?.trim().isNotEmpty ?? false) ||
        (currentDataOutFilter?.trim().isNotEmpty ?? false);
  }

  @override
  void dispose() {
    _listController.removeListener(notifyListeners);
    _deleteController.removeListener(notifyListeners);
    super.dispose();
  }
}
