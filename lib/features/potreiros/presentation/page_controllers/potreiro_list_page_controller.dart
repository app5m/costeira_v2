import 'package:costeira/features/potreiros/domain/entities/potreiro_entity.dart';
import 'package:costeira/features/potreiros/presentation/controllers/delete_potreiro_controller.dart';
import 'package:costeira/features/potreiros/presentation/controllers/list_potreiros_controller.dart';
import 'package:costeira/features/potreiros/presentation/page_controllers/page_action_result.dart';
import 'package:costeira/features/potreiros/presentation/widgets/potreiro_filter_sheet.dart';
import 'package:flutter/foundation.dart';

class PotreiroListPageController extends ChangeNotifier {
  PotreiroListPageController(this._listController, this._deleteController) {
    _listController.addListener(notifyListeners);
    _deleteController.addListener(notifyListeners);
  }

  final ListPotreirosController _listController;
  final DeletePotreiroController _deleteController;

  List<PotreiroEntity> get potreiros => _listController.potreiros;
  bool get isLoading => _listController.isLoading;
  String? get errorMessage => _listController.errorMessage;
  String? get currentStatusFilter => _listController.currentFilter?.statusAtual;
  bool get isDeleting => _deleteController.isLoading;

  Future<PageActionResult?> loadInitialData() async {
    try {
      if (_listController.currentFilter == null) {
        await _listController.load();
      } else {
        await _listController.reload();
      }
      return null;
    } catch (_) {
      return PageActionResult(
        isSuccess: false,
        message:
            _listController.errorMessage ??
            'Não foi possível carregar os potreiros.',
      );
    }
  }

  Future<PageActionResult> applyFilters(
    PotreiroFilterSheetResult result,
  ) async {
    try {
      await _listController.load(
        statusAtual: result.shouldClear ? null : result.statusAtual,
      );
      return PageActionResult(
        isSuccess: true,
        message: result.shouldClear
            ? 'Filtros removidos com sucesso.'
            : 'Filtros aplicados com sucesso.',
      );
    } catch (_) {
      return PageActionResult(
        isSuccess: false,
        message:
            _listController.errorMessage ??
            'Não foi possível aplicar os filtros.',
      );
    }
  }

  Future<PageActionResult> deletePotreiro(PotreiroEntity potreiro) async {
    try {
      final result = await _deleteController.delete(potreiro.id);
      if (result == null) {
        return const PageActionResult(
          isSuccess: false,
          message: 'Não foi possível excluir o potreiro.',
        );
      }

      _listController.removeById(potreiro.id);
      return PageActionResult(isSuccess: true, message: result.message);
    } catch (_) {
      return PageActionResult(
        isSuccess: false,
        message:
            _deleteController.errorMessage ??
            'Não foi possível excluir o potreiro.',
      );
    }
  }

  Future<PageActionResult?> handleEditResult(
    Map<String, dynamic>? result,
  ) async {
    if (result?['success'] != true) {
      return null;
    }

    final reloadResult = await loadInitialData();
    if (reloadResult != null && !reloadResult.isSuccess) {
      return reloadResult;
    }

    return PageActionResult(
      isSuccess: true,
      message:
          result?['message']?.toString() ?? 'Potreiro atualizado com sucesso.',
    );
  }

  bool hasActiveFilters() => (currentStatusFilter?.trim().isNotEmpty ?? false);

  @override
  void dispose() {
    _listController.removeListener(notifyListeners);
    _deleteController.removeListener(notifyListeners);
    super.dispose();
  }
}
