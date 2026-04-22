import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/features/animals/domain/entities/animal_lot_entity.dart';
import 'package:costeira/features/animals/domain/entities/animal_lot_upsert_entity.dart';
import 'package:costeira/features/animals/presentation/controllers/edit_animal_lot_controller.dart';
import 'package:costeira/features/animals/presentation/page_controllers/page_action_result.dart';
import 'package:flutter/material.dart';

class EditLotePageController extends ChangeNotifier {
  EditLotePageController(this._controller) {
    _controller.addListener(notifyListeners);
    nomeController.addListener(notifyListeners);
  }

  final EditAnimalLotController _controller;
  final TextEditingController nomeController = TextEditingController();
  AnimalLotEntity? _lot;

  bool get isLoading => _controller.isLoading;

  void init(AnimalLotEntity lot) {
    AppLogger.info('LOTES EDIT PAGE CONTROLLER: INIT ID=${lot.id}');
    _lot = lot;
    _controller.setInitialLot(lot);
    nomeController.text = lot.nome;
  }

  Future<PageActionResult> submit() async {
    final lot = _lot;
    if (lot == null) {
      return const PageActionResult(
        isSuccess: false,
        message: 'Lote nao encontrado para edicao.',
      );
    }

    final nome = nomeController.text.trim();
    if (nome.isEmpty) {
      return const PageActionResult(
        isSuccess: false,
        message: 'Informe o nome do lote.',
      );
    }

    try {
      final result = await _controller.submit(
        AnimalLotUpsertEntity(
          id: lot.id,
          appUsersId: lot.appUsersId,
          nome: nome,
        ),
      );
      if (result == null) {
        return const PageActionResult(
          isSuccess: false,
          message: 'Nao foi possivel atualizar o lote.',
        );
      }

      return PageActionResult(
        isSuccess: result.isSuccess,
        message: result.message,
      );
    } catch (_) {
      return PageActionResult(
        isSuccess: false,
        message:
            _controller.errorMessage ?? 'Nao foi possivel atualizar o lote.',
      );
    }
  }

  @override
  void dispose() {
    AppLogger.info('LOTES EDIT PAGE CONTROLLER: DISPOSE');
    _controller.removeListener(notifyListeners);
    nomeController.removeListener(notifyListeners);
    nomeController.dispose();
    super.dispose();
  }
}
