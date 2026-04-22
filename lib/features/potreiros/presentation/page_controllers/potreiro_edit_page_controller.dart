import 'package:costeira/features/potreiros/domain/entities/potreiro_entity.dart';
import 'package:costeira/features/potreiros/domain/entities/potreiro_upsert_entity.dart';
import 'package:costeira/features/potreiros/presentation/controllers/edit_potreiro_controller.dart';
import 'package:costeira/features/potreiros/presentation/page_controllers/page_action_result.dart';
import 'package:flutter/material.dart';

class PotreiroEditPageController extends ChangeNotifier {
  PotreiroEditPageController(this._controller) {
    _controller.addListener(notifyListeners);
    for (final item in _controllers) {
      item.addListener(notifyListeners);
    }
  }

  static const List<String> statusOptions = ['PECUARIA', 'LAVOURA'];
  static const List<String> acessoOptions = ['BOM', 'MEDIO', 'RUIM'];

  final EditPotreiroController _controller;
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController areaTotalController = TextEditingController();
  final TextEditingController areaUtilController = TextEditingController();
  final TextEditingController tipoForragemController = TextEditingController();
  final TextEditingController lotacaoMediaController = TextEditingController();
  final TextEditingController obsController = TextEditingController();

  PotreiroEntity? _potreiro;
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
  bool get hasChanges {
    final potreiro = _potreiro;
    if (potreiro == null) {
      return false;
    }

    return nomeController.text.trim() != potreiro.nome.trim() ||
        _normalizedDecimalValue(areaTotalController.text) !=
            _normalizedDoubleValue(potreiro.areaTotal) ||
        _normalizedDecimalValue(areaUtilController.text) !=
            _normalizedDoubleValue(potreiro.areaUtil) ||
        _normalizedValue(tipoForragemController.text) !=
            _normalizedValue(potreiro.tipoForragem) ||
        _normalizedDecimalValue(lotacaoMediaController.text) !=
            _normalizedDoubleValue(potreiro.lotacaoMedia) ||
        _normalizedValue(obsController.text) !=
            _normalizedValue(potreiro.obs) ||
        selectedStatusAtual != potreiro.statusAtual ||
        selectedAcessoAgua != potreiro.acessoAgua ||
        selectedAcessoSombra != potreiro.acessoSombra;
  }

  void init(PotreiroEntity potreiro) {
    _potreiro = potreiro;
    _controller.setInitialPotreiro(potreiro);
    nomeController.text = potreiro.nome;
    areaTotalController.text = _formatDecimal(potreiro.areaTotal);
    areaUtilController.text = _formatDecimal(potreiro.areaUtil);
    tipoForragemController.text = potreiro.tipoForragem ?? '';
    lotacaoMediaController.text = _formatDecimal(potreiro.lotacaoMedia);
    obsController.text = potreiro.obs ?? '';
    selectedStatusAtual = potreiro.statusAtual;
    selectedAcessoAgua = potreiro.acessoAgua;
    selectedAcessoSombra = potreiro.acessoSombra;
  }

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
    final potreiro = _potreiro;
    if (potreiro == null) {
      return const PageActionResult(
        isSuccess: false,
        message: 'Potreiro não encontrado para edição.',
      );
    }

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
          id: potreiro.id,
          appUsersId: potreiro.appUsersId,
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
          message: 'Não foi possível atualizar o potreiro.',
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
            _controller.errorMessage ??
            'Não foi possível atualizar o potreiro.',
      );
    }
  }

  String _formatDecimal(double? value) {
    if (value == null) {
      return '';
    }
    return value.toStringAsFixed(2);
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

  String? _normalizedValue(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }

  String? _normalizedDecimalValue(String? value) {
    final normalized = _normalizeDecimal(value ?? '');
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return normalized;
  }

  String? _normalizedDoubleValue(double? value) {
    if (value == null) {
      return null;
    }
    return value.toStringAsFixed(2);
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
