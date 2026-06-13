import 'package:costeira/features/movimentacoes/domain/entities/nascimento_entity.dart';
import 'package:costeira/features/movimentacoes/nascimento/presentation/controllers/delete_nascimento_controller.dart';
import 'package:costeira/features/movimentacoes/nascimento/presentation/controllers/list_nascimentos_controller.dart';
import 'package:flutter/foundation.dart';

class NascimentosListPageController extends ChangeNotifier {
  NascimentosListPageController(this._listController, this._deleteController) {
    _listController.addListener(notifyListeners);
    _deleteController.addListener(notifyListeners);
  }

  final ListNascimentosController _listController;
  final DeleteNascimentoController _deleteController;

  List<NascimentoEntity> get nascimentos => _listController.nascimentos;
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
          'Nao foi possivel carregar os nascimentos.';
    }
  }

  Future<String?> deleteNascimento(NascimentoEntity nascimento) async {
    try {
      final result = await _deleteController.delete(nascimento.id);
      if (result == null || !result.isSuccess) {
        return result?.message ?? 'Nao foi possivel excluir o nascimento.';
      }

      _listController.removeById(nascimento.id);
      await loadInitialData();
      return null;
    } catch (_) {
      return _deleteController.errorMessage ??
          'Nao foi possivel excluir o nascimento.';
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
