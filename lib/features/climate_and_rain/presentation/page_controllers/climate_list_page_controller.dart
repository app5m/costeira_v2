import 'package:costeira/features/climate_and_rain/domain/entities/climate_entity.dart';
import 'package:costeira/features/climate_and_rain/presentation/controllers/delete_climate_controller.dart';
import 'package:costeira/features/climate_and_rain/presentation/controllers/list_climates_controller.dart';
import 'package:costeira/features/climate_and_rain/presentation/page_controllers/page_action_result.dart';
import 'package:costeira/features/climate_and_rain/presentation/widgets/climate_filter_sheet.dart';
import 'package:flutter/foundation.dart';

class ClimateListPageController extends ChangeNotifier {
  ClimateListPageController(this._listController, this._deleteController) {
    _listController.addListener(notifyListeners);
    _deleteController.addListener(notifyListeners);
  }

  final ListClimatesController _listController;
  final DeleteClimateController _deleteController;

  List<ClimateEntity> get climates => _listController.climates;
  bool get isLoading => _listController.isLoading;
  String? get errorMessage => _listController.errorMessage;
  String? get currentDataInFilter => _listController.currentFilter?.dataIn;
  String? get currentDataOutFilter => _listController.currentFilter?.dataOut;
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
            'Nao foi possivel carregar os registros de chuva.',
      );
    }
  }

  Future<PageActionResult> applyFilters(ClimateFilterSheetResult result) async {
    try {
      await _listController.load(
        dataIn: result.shouldClear ? null : result.dataIn,
        dataOut: result.shouldClear ? null : result.dataOut,
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
            'Nao foi possivel aplicar os filtros.',
      );
    }
  }

  Future<PageActionResult> deleteClimate(ClimateEntity climate) async {
    try {
      final result = await _deleteController.delete(climate.id);
      if (result == null) {
        return const PageActionResult(
          isSuccess: false,
          message: 'Nao foi possivel excluir o registro de chuva.',
        );
      }

      _listController.removeById(climate.id);
      return PageActionResult(isSuccess: true, message: result.message);
    } catch (_) {
      return PageActionResult(
        isSuccess: false,
        message:
            _deleteController.errorMessage ??
            'Nao foi possivel excluir o registro de chuva.',
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
          result?['message']?.toString() ?? 'Clima atualizado com sucesso.',
    );
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
