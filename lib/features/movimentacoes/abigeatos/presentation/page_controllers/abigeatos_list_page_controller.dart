import 'package:costeira/features/movimentacoes/abigeatos/presentation/controllers/delete_abigeato_controller.dart';
import 'package:costeira/features/movimentacoes/abigeatos/presentation/controllers/list_abigeatos_controller.dart';
import 'package:costeira/features/movimentacoes/domain/entities/abigeato_entity.dart';
import 'package:flutter/foundation.dart';

class AbigeatosListPageController extends ChangeNotifier {
  AbigeatosListPageController(this._listController, this._deleteController) {
    _listController.addListener(notifyListeners);
    _deleteController.addListener(notifyListeners);
  }

  final ListAbigeatosController _listController;
  final DeleteAbigeatoController _deleteController;

  List<AbigeatoEntity> get abigeatos => _listController.abigeatos;
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
          'Nao foi possivel carregar os abigeatos.';
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

  Future<String?> deleteAbigeato(AbigeatoEntity abigeato) async {
    try {
      final result = await _deleteController.delete(abigeato.id);
      if (result == null || !result.isSuccess) {
        return result?.message ?? 'Nao foi possivel excluir o abigeato.';
      }

      _listController.removeById(abigeato.id);
      await loadInitialData();
      return null;
    } catch (_) {
      return _deleteController.errorMessage ??
          'Nao foi possivel excluir o abigeato.';
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
