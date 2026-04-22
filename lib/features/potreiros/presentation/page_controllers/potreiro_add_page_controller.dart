import 'package:costeira/features/potreiros/domain/entities/potreiro_upsert_entity.dart';
import 'package:costeira/features/potreiros/presentation/controllers/add_potreiro_controller.dart';
import 'package:costeira/features/potreiros/presentation/page_controllers/page_action_result.dart';
import 'package:flutter/material.dart';

class PotreiroAddPageController extends ChangeNotifier {
  PotreiroAddPageController(this._controller) {
    _controller.addListener(notifyListeners);
    for (final item in _controllers) {
      item.addListener(notifyListeners);
    }
  }

  static const List<String> statusOptions = ['PECUARIA', 'LAVOURA'];
  static const List<String> acessoOptions = ['BOM', 'MEDIO', 'RUIM'];

  final AddPotreiroController _controller;
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController areaTotalController = TextEditingController();
  final TextEditingController areaUtilController = TextEditingController();
  final TextEditingController tipoForragemController = TextEditingController();
  final TextEditingController lotacaoMediaController = TextEditingController();
  final TextEditingController obsController = TextEditingController();

  String? selectedStatusAtual;
  String? selectedAcessoAgua;
  String? selectedAcessoSombra;

  List<TextEditingController> get _controllers => [
    nomeController,
    areaTotalController,
    areaUtilController,
    tipoForragemController,
    lotacaoMediaController,
    obsController,
  ];

  bool get isLoading => _controller.isLoading;
  bool get isFormValid =>
      nomeController.text.trim().isNotEmpty &&
      areaTotalController.text.trim().isNotEmpty &&
      (selectedStatusAtual?.trim().isNotEmpty ?? false);

  void onStatusAtualChanged(String? value) {
    selectedStatusAtual = value;
    notifyListeners();
  }

  void onAcessoAguaChanged(String? value) {
    selectedAcessoAgua = value;
    notifyListeners();
  }

  void onAcessoSombraChanged(String? value) {
    selectedAcessoSombra = value;
    notifyListeners();
  }

  Future<PageActionResult> submit() async {
    final nome = nomeController.text.trim();
    if (nome.isEmpty) {
      return const PageActionResult(
        isSuccess: false,
        message: 'Informe o nome do potreiro.',
      );
    }

    try {
      final result = await _controller.submit(
        PotreiroUpsertEntity(
          nome: nome,
          areaTotal: _normalizeDecimal(areaTotalController.text),
          areaUtil: _normalizeDecimal(areaUtilController.text),
          statusAtual: selectedStatusAtual,
          tipoForragem: _emptyToNull(tipoForragemController.text),
          acessoAgua: selectedAcessoAgua,
          acessoSombra: selectedAcessoSombra,
          lotacaoMedia: _normalizeDecimal(lotacaoMediaController.text),
          obs: _emptyToNull(obsController.text),
        ),
      );

      if (result == null) {
        return const PageActionResult(
          isSuccess: false,
          message: 'Não foi possível salvar o potreiro.',
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
            _controller.errorMessage ?? 'Não foi possível salvar o potreiro.',
      );
    }
  }

  String? _normalizeDecimal(String value) {
    final trimmed = value.trim().replaceAll(',', '.').replaceAll('ha', '');
    if (trimmed.isEmpty) {
      return null;
    }

    final parsed = double.tryParse(trimmed);
    if (parsed == null) {
      return null;
    }

    return parsed.toStringAsFixed(2);
  }

  String? _emptyToNull(String value) {
    final trimmed = value.trim();
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
