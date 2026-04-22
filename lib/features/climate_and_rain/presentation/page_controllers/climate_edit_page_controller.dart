import 'package:costeira/features/climate_and_rain/domain/entities/climate_entity.dart';
import 'package:costeira/features/climate_and_rain/domain/entities/climate_upsert_entity.dart';
import 'package:costeira/features/climate_and_rain/presentation/controllers/edit_climate_controller.dart';
import 'package:costeira/features/climate_and_rain/presentation/page_controllers/page_action_result.dart';
import 'package:flutter/material.dart';

class ClimateEditPageController extends ChangeNotifier {
  ClimateEditPageController(this._controller) {
    _controller.addListener(notifyListeners);
    for (final item in _controllers) {
      item.addListener(notifyListeners);
    }
  }

  final EditClimateController _controller;
  final TextEditingController quantidadeController = TextEditingController();
  final TextEditingController dataInController = TextEditingController();
  final TextEditingController dataOutController = TextEditingController();

  ClimateEntity? _currentClimate;

  List<TextEditingController> get _controllers => [
    quantidadeController,
    dataInController,
    dataOutController,
  ];

  bool get isLoading => _controller.isLoading;
  ClimateEntity? get currentClimate => _currentClimate;
  bool get isFormValid =>
      _normalizeQuantidade(quantidadeController.text) != null &&
      dataInController.text.trim().isNotEmpty &&
      dataOutController.text.trim().isNotEmpty;

  void init(ClimateEntity climate) {
    _currentClimate ??= climate;
    _controller.setCurrentClimate(climate);
    quantidadeController.text = _initialQuantidade(climate.quantidade);
    dataInController.text = climate.dataIn;
    dataOutController.text = climate.dataOut;
  }

  void setDataIn(String value) {
    dataInController.text = value;
    notifyListeners();
  }

  void setDataOut(String value) {
    dataOutController.text = value;
    notifyListeners();
  }

  bool get hasChanges {
    final current = _currentClimate;
    if (current == null) {
      return false;
    }

    return _normalizeQuantidade(quantidadeController.text) !=
            _normalizeQuantidade(_initialQuantidade(current.quantidade)) ||
        dataInController.text.trim() != current.dataIn ||
        dataOutController.text.trim() != current.dataOut;
  }

  Future<PageActionResult> submit() async {
    final current = _currentClimate;
    if (current == null) {
      return const PageActionResult(
        isSuccess: false,
        message: 'Clima nao encontrado para edicao.',
      );
    }

    final quantidade = _normalizeQuantidade(quantidadeController.text);
    if (quantidade == null) {
      return const PageActionResult(
        isSuccess: false,
        message: 'Informe a quantidade de chuva.',
      );
    }

    final dataIn = dataInController.text.trim();
    if (dataIn.isEmpty) {
      return const PageActionResult(
        isSuccess: false,
        message: 'Informe a data inicial.',
      );
    }

    final dataOut = dataOutController.text.trim();
    if (dataOut.isEmpty) {
      return const PageActionResult(
        isSuccess: false,
        message: 'Informe a data final.',
      );
    }

    try {
      final result = await _controller.submit(
        ClimateUpsertEntity(
          id: current.id,
          appUsersId: current.appUsersId,
          quantidade: quantidade,
          dataIn: dataIn,
          dataOut: dataOut,
        ),
      );

      if (result == null) {
        return const PageActionResult(
          isSuccess: false,
          message: 'Nao foi possivel atualizar o clima.',
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
            _controller.errorMessage ?? 'Nao foi possivel atualizar o clima.',
      );
    }
  }

  String? _normalizeQuantidade(String value) {
    final trimmed = value.trim().replaceAll(',', '.').replaceAll('mm', '');
    return trimmed.isEmpty ? null : trimmed;
  }

  String _initialQuantidade(double value) {
    return value == value.truncateToDouble()
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _controller.removeListener(notifyListeners);
    for (final item in _controllers) {
      item.removeListener(notifyListeners);
      item.dispose();
    }
    super.dispose();
  }
}
