import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/features/animals/domain/entities/animal_entity.dart';
import 'package:costeira/features/animals/domain/entities/animals_filter_entity.dart';
import 'package:costeira/features/animals/presentation/controllers/delete_animal_controller.dart';
import 'package:costeira/features/animals/presentation/controllers/list_animals_controller.dart';
import 'package:costeira/features/animals/presentation/page_controllers/page_action_result.dart';
import 'package:costeira/features/animals/presentation/widgets/animal_filter_sheet.dart';
import 'package:flutter/foundation.dart';

class AnimalListPageController extends ChangeNotifier {
  AnimalListPageController(this._listController, this._deleteController) {
    _listController.addListener(notifyListeners);
    _deleteController.addListener(notifyListeners);
  }

  final ListAnimalsController _listController;
  final DeleteAnimalController _deleteController;

  ListAnimalsController get listController => _listController;
  DeleteAnimalController get deleteController => _deleteController;
  List<AnimalEntity> get animals => _listController.animals;
  bool get isLoading => _listController.isLoading;
  String? get errorMessage => _listController.errorMessage;
  AnimalsFilterEntity? get currentFilter => _listController.currentFilter;
  bool get isDeleting => _deleteController.isLoading;

  Future<PageActionResult?> loadInitialData() async {
    AppLogger.info('ANIMAIS LIST PAGE CONTROLLER: CARREGANDO ANIMAIS');
    try {
      if (_listController.currentFilter == null) {
        await _listController.load();
      } else {
        await _listController.reload();
      }
      AppLogger.success('ANIMAIS LIST PAGE CONTROLLER: ANIMAIS CARREGADOS');
      return null;
    } catch (_) {
      AppLogger.error('ANIMAIS LIST PAGE CONTROLLER: ERRO AO CARREGAR ANIMAIS');
      return PageActionResult(
        isSuccess: false,
        message:
            _listController.errorMessage ??
            'Nao foi possivel carregar os animais.',
      );
    }
  }

  Future<PageActionResult> applyFilters(AnimalFilterSheetResult result) async {
    if (result.shouldClear) {
      AppLogger.warning('ANIMAIS LIST PAGE CONTROLLER: LIMPANDO FILTROS');
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

    AppLogger.info('ANIMAIS LIST PAGE CONTROLLER: APLICANDO FILTROS');
    try {
      await _listController.load(
        appAnimaisCategoriasId: result.appAnimaisCategoriasId,
        appAnimaisSubcategoriasId: result.appAnimaisSubcategoriasId,
        utBasesRaciaisId: result.utBasesRaciaisId,
        brinco: result.brinco,
      );
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

  Future<PageActionResult> deleteAnimal(AnimalEntity animal) async {
    AppLogger.warning(
      'ANIMAIS LIST PAGE CONTROLLER: EXECUTANDO EXCLUSAO ID=${animal.id}',
    );
    try {
      final result = await _deleteController.delete(animal.id);
      if (result == null) {
        return const PageActionResult(
          isSuccess: false,
          message: 'Nao foi possivel excluir o animal.',
        );
      }

      _listController.removeAnimalById(animal.id);
      return PageActionResult(isSuccess: true, message: result.message);
    } catch (_) {
      AppLogger.error('ANIMAIS LIST PAGE CONTROLLER: ERRO AO EXCLUIR ANIMAL');
      return PageActionResult(
        isSuccess: false,
        message:
            _deleteController.errorMessage ??
            'Nao foi possivel excluir o animal.',
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
          result?['message']?.toString() ?? 'Animal atualizado com sucesso.',
    );
  }

  bool hasActiveFilters() {
    final filter = currentFilter;
    if (filter == null) {
      return false;
    }

    return filter.id != null ||
        filter.appAnimaisCategoriasId != null ||
        filter.appAnimaisSubcategoriasId != null ||
        filter.utBasesRaciaisId != null ||
        (filter.brinco?.trim().isNotEmpty ?? false);
  }

  String buildSummary(AnimalEntity animal) {
    final parts = <String?>[
      animal.categoria?.nome.trim(),
      animal.peso != null ? '${animal.peso} kg' : null,
      animal.baseRacial?.nome.trim(),
    ].whereType<String>().where((item) => item.isNotEmpty).toList();

    return parts.isEmpty ? 'Sem detalhes informados' : parts.join(' - ');
  }

  @override
  void dispose() {
    _listController.removeListener(notifyListeners);
    _deleteController.removeListener(notifyListeners);
    super.dispose();
  }
}
