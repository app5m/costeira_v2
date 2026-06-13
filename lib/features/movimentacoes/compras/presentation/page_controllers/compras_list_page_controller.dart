import 'package:costeira/features/movimentacoes/compras/presentation/controllers/list_compras_controller.dart';
import 'package:costeira/features/movimentacoes/compras/presentation/controllers/delete_compra_controller.dart';
import 'package:costeira/features/movimentacoes/domain/entities/compra_entity.dart';
import 'package:flutter/foundation.dart';

class ComprasListPageController extends ChangeNotifier {
  ComprasListPageController(this._listController, this._deleteController) {
    _listController.addListener(notifyListeners);
    _deleteController.addListener(notifyListeners);
  }

  final ListComprasController _listController;
  final DeleteCompraController _deleteController;

  List<CompraEntity> get compras => _listController.compras;
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
          'Nao foi possivel carregar as compras.';
    }
  }

  Future<String?> deleteCompra(CompraEntity compra) async {
    try {
      final result = await _deleteController.delete(compra.id);
      if (result == null || !result.isSuccess) {
        return result?.message ?? 'Nao foi possivel excluir a compra.';
      }

      _listController.removeById(compra.id);
      await loadInitialData();
      return null;
    } catch (_) {
      return _deleteController.errorMessage ??
          'Nao foi possivel excluir a compra.';
    }
  }

  Future<CompraEntity> findCompraDetails(CompraEntity compra) async {
    try {
      return await _listController.findById(compra.id) ?? compra;
    } catch (_) {
      return compra;
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
