import 'package:costeira/features/movimentacoes/domain/entities/troca_categoria_entity.dart';
import 'package:costeira/features/movimentacoes/troca_categoria/presentation/controllers/delete_troca_categoria_controller.dart';
import 'package:costeira/features/movimentacoes/troca_categoria/presentation/controllers/list_troca_categoria_controller.dart';
import 'package:flutter/foundation.dart';

class TrocaCategoriaListPageController extends ChangeNotifier {
  TrocaCategoriaListPageController(
    this._listController,
    this._deleteController,
  ) {
    _listController.addListener(notifyListeners);
    _deleteController.addListener(notifyListeners);
  }

  final ListTrocaCategoriaController _listController;
  final DeleteTrocaCategoriaController _deleteController;

  List<TrocaCategoriaEntity> get trocas => _listController.trocas;
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
          'Nao foi possivel carregar as trocas de categoria.';
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

  Future<String?> deleteTroca(TrocaCategoriaEntity troca) async {
    try {
      final result = await _deleteController.delete(troca.id);
      if (result == null || !result.isSuccess) {
        return result?.message ?? 'Nao foi possivel excluir a troca.';
      }

      _listController.removeById(troca.id);
      await loadInitialData();
      return null;
    } catch (_) {
      return _deleteController.errorMessage ??
          'Nao foi possivel excluir a troca.';
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
