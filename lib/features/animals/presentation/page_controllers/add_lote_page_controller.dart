import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/features/animals/domain/entities/animal_lot_upsert_entity.dart';
import 'package:costeira/features/animals/presentation/controllers/add_animal_lot_controller.dart';
import 'package:costeira/features/animals/presentation/page_controllers/page_action_result.dart';
import 'package:flutter/material.dart';

class AddLotePageController extends ChangeNotifier {
  AddLotePageController(this._controller) {
    _controller.addListener(notifyListeners);
    nomeController.addListener(notifyListeners);
  }

  final AddAnimalLotController _controller;
  final TextEditingController nomeController = TextEditingController();

  bool get isLoading => _controller.isLoading;
  bool get hasNome => nomeController.text.trim().isNotEmpty;

  Future<PageActionResult> submit() async {
    AppLogger.info('LOTES ADD PAGE CONTROLLER: VALIDANDO FORMULARIO');
    final nome = nomeController.text.trim();
    if (nome.isEmpty) {
      return const PageActionResult(
        isSuccess: false,
        message: 'Informe o nome do lote.',
      );
    }

    try {
      final result = await _controller.submit(
        AnimalLotUpsertEntity(nome: nome),
      );
      if (result == null) {
        return const PageActionResult(
          isSuccess: false,
          message: 'Nao foi possivel salvar o lote.',
        );
      }

      return PageActionResult(
        isSuccess: result.isSuccess,
        message: result.message,
      );
    } catch (_) {
      return PageActionResult(
        isSuccess: false,
        message: _controller.errorMessage ?? 'Nao foi possivel salvar o lote.',
      );
    }
  }

  @override
  void dispose() {
    AppLogger.info('LOTES ADD PAGE CONTROLLER: DISPOSE');
    _controller.removeListener(notifyListeners);
    nomeController.removeListener(notifyListeners);
    nomeController.dispose();
    super.dispose();
  }
}
