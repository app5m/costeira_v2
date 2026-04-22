import 'package:costeira/features/climate_and_rain/domain/entities/climate_upsert_entity.dart';
import 'package:costeira/features/climate_and_rain/presentation/controllers/add_climate_controller.dart';
import 'package:costeira/features/climate_and_rain/presentation/page_controllers/page_action_result.dart';
import 'package:flutter/material.dart';

class ClimateAddPageController extends ChangeNotifier {
  ClimateAddPageController(this._controller) {
    _controller.addListener(notifyListeners);
    for (final item in _controllers) {
      item.addListener(notifyListeners);
    }
  }

  final AddClimateController _controller;
  final TextEditingController quantidadeController = TextEditingController();
  final TextEditingController dataInController = TextEditingController();
  final TextEditingController dataOutController = TextEditingController();

  List<TextEditingController> get _controllers => [
    quantidadeController,
    dataInController,
    dataOutController,
  ];

  bool get isLoading => _controller.isLoading;
  bool get isFormValid =>
      _normalizeQuantidade(quantidadeController.text) != null &&
      dataInController.text.trim().isNotEmpty &&
      dataOutController.text.trim().isNotEmpty;

  void setDataIn(String value) {
    dataInController.text = value;
    notifyListeners();
  }

  void setDataOut(String value) {
    dataOutController.text = value;
    notifyListeners();
  }

  Future<PageActionResult> submit() async {
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
          quantidade: quantidade,
          dataIn: dataIn,
          dataOut: dataOut,
        ),
      );

      if (result == null) {
        return const PageActionResult(
          isSuccess: false,
          message: 'Nao foi possivel salvar o clima.',
        );
      }

      return PageActionResult(
        isSuccess: result.isSuccess,
        message: result.message,
      );
    } catch (_) {
      return PageActionResult(
        isSuccess: false,
        message: _controller.errorMessage ?? 'Nao foi possivel salvar o clima.',
      );
    }
  }

  String? _normalizeQuantidade(String value) {
    final trimmed = value.trim().replaceAll(',', '.').replaceAll('mm', '');
    return trimmed.isEmpty ? null : trimmed;
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
