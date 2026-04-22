import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/features/animals/domain/entities/animal_lot_entity.dart';
import 'package:costeira/features/animals/domain/entities/animal_lots_filter_entity.dart';
import 'package:costeira/features/animals/presentation/controllers/delete_animal_lot_controller.dart';
import 'package:costeira/features/animals/presentation/controllers/list_animal_lots_controller.dart';
import 'package:costeira/features/animals/presentation/page_controllers/page_action_result.dart';
import 'package:costeira/features/animals/presentation/widgets/animal_lot_filter_sheet.dart';
import 'package:flutter/foundation.dart';

class LotesPageController extends ChangeNotifier {
  LotesPageController(this._listController, this._deleteController) {
    _listController.addListener(notifyListeners);
    _deleteController.addListener(notifyListeners);
  }

  final ListAnimalLotsController _listController;
  final DeleteAnimalLotController _deleteController;

  List<AnimalLotEntity> get lots => _listController.lots;
  bool get isLoading => _listController.isLoading;
  String? get errorMessage => _listController.errorMessage;
  AnimalLotsFilterEntity? get currentFilter => _listController.currentFilter;
  bool get isDeleting => _deleteController.isLoading;

  Future<PageActionResult?> loadInitialData() async {
    AppLogger.info('LOTES PAGE CONTROLLER: CARREGANDO LOTES');
    try {
      if (_listController.currentFilter == null) {
        await _listController.load();
      } else {
        await _listController.reload();
      }
      return null;
    } catch (_) {
      AppLogger.error('LOTES PAGE CONTROLLER: ERRO AO CARREGAR LOTES');
      return PageActionResult(
        isSuccess: false,
        message:
            _listController.errorMessage ??
            'Nao foi possivel carregar os lotes.',
      );
    }
  }

  Future<PageActionResult> applyFilters(
    AnimalLotFilterSheetResult result,
  ) async {
    if (result.shouldClear) {
      try {
        await _listController.load();
        return const PageActionResult(
          isSuccess: true,
          message: 'Filtros removidos com sucesso.',
        );
      } catch (_) {
        return PageActionResult(
          isSuccess: false,
          message:
              _listController.errorMessage ??
              'Nao foi possivel limpar os filtros.',
        );
      }
    }

    try {
      await _listController.load(nome: result.nome);
      return const PageActionResult(
        isSuccess: true,
        message: 'Filtros aplicados com sucesso.',
      );
    } catch (_) {
      return PageActionResult(
        isSuccess: false,
        message:
            _listController.errorMessage ??
            'Nao foi possivel aplicar os filtros.',
      );
    }
  }

  Future<PageActionResult> deleteLot(AnimalLotEntity lot) async {
    try {
      final result = await _deleteController.delete(lot.id);
      if (result == null) {
        return const PageActionResult(
          isSuccess: false,
          message: 'Nao foi possivel excluir o lote.',
        );
      }

      _listController.removeLotById(lot.id);
      return PageActionResult(isSuccess: true, message: result.message);
    } catch (_) {
      return PageActionResult(
        isSuccess: false,
        message:
            _deleteController.errorMessage ??
            'Nao foi possivel excluir o lote.',
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
      message: result?['message']?.toString() ?? 'Lote atualizado com sucesso.',
    );
  }

  bool hasActiveFilters() {
    final filter = currentFilter;
    if (filter == null) {
      return false;
    }

    return filter.id != null || (filter.nome?.trim().isNotEmpty ?? false);
  }

  @override
  void dispose() {
    _listController.removeListener(notifyListeners);
    _deleteController.removeListener(notifyListeners);
    super.dispose();
  }
}
