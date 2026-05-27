import 'package:costeira/features/movimentacoes/domain/entities/transferencia_entity.dart';
import 'package:costeira/features/movimentacoes/transferencias/presentation/controllers/delete_transferencia_controller.dart';
import 'package:costeira/features/movimentacoes/transferencias/presentation/controllers/list_transferencias_controller.dart';
import 'package:flutter/foundation.dart';

class TransferenciasListPageController extends ChangeNotifier {
  TransferenciasListPageController(
    this._listController,
    this._deleteController,
  ) {
    _listController.addListener(notifyListeners);
    _deleteController.addListener(notifyListeners);
  }

  final ListTransferenciasController _listController;
  final DeleteTransferenciaController _deleteController;

  List<TransferenciaEntity> get transferencias =>
      _listController.transferencias;
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
          'Nao foi possivel carregar as transferencias.';
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

  Future<String?> deleteTransferencia(TransferenciaEntity transferencia) async {
    try {
      final result = await _deleteController.delete(transferencia.id);
      if (result == null || !result.isSuccess) {
        return result?.message ?? 'Nao foi possivel excluir a transferencia.';
      }

      await loadInitialData();
      return null;
    } catch (_) {
      return _deleteController.errorMessage ??
          'Nao foi possivel excluir a transferencia.';
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
