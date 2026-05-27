import 'package:costeira/features/movimentacoes/abortos/presentation/controllers/delete_aborto_controller.dart';
import 'package:costeira/features/movimentacoes/abortos/presentation/controllers/list_abortos_controller.dart';
import 'package:costeira/features/movimentacoes/domain/entities/aborto_entity.dart';
import 'package:flutter/foundation.dart';

class AbortosListPageController extends ChangeNotifier {
  AbortosListPageController(this._listController, this._deleteController) {
    _listController.addListener(notifyListeners);
    _deleteController.addListener(notifyListeners);
  }

  final ListAbortosController _listController;
  final DeleteAbortoController _deleteController;

  List<AbortoEntity> get abortos => _listController.abortos;
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
          'Nao foi possivel carregar os abortos.';
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

  Future<String?> deleteAborto(AbortoEntity aborto) async {
    try {
      final result = await _deleteController.delete(aborto.id);
      if (result == null || !result.isSuccess) {
        return result?.message ?? 'Nao foi possivel excluir o aborto.';
      }

      await loadInitialData();
      return null;
    } catch (_) {
      return _deleteController.errorMessage ??
          'Nao foi possivel excluir o aborto.';
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
