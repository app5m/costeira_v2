import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/features/insumos/domain/entities/insumos.dart';
import 'package:costeira/features/insumos/domain/usecases/create_insumo_usecase.dart';
import 'package:costeira/features/insumos/domain/usecases/get_insumos_usecase.dart';
import 'package:costeira/features/insumos/domain/usecases/update_insumo_usecase.dart';
import 'package:flutter/material.dart';

class AddInsumoController extends ChangeNotifier {
  AddInsumoController(
    this._createInsumoUsecase,
    this._getInsumosUsecase,
    this._updateInsumoUsecase,
  ) {
    nomeController.addListener(notifyListeners);
    valorUnidadeController.addListener(notifyListeners);
    qtdTotalController.addListener(notifyListeners);
    obsController.addListener(notifyListeners);
    dataValidadeController.addListener(notifyListeners);
  }

  final CreateInsumoUsecase _createInsumoUsecase;
  final GetInsumosUsecase _getInsumosUsecase;
  final UpdateInsumoUsecase _updateInsumoUsecase;

  final nomeController = TextEditingController();
  final valorUnidadeController = TextEditingController();
  final qtdTotalController = TextEditingController();
  final obsController = TextEditingController();
  final dataValidadeController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  int? _currentUserId;
  InsumoEntity? _editingInsumo;
  String? _selectedTipoInsumo;
  int? _selectedUnidadeId;
  int? _selectedSuplementoId;
  List<InsumoReferenceEntity> _tipoInsumos = const [];
  List<InsumoReferenceEntity> _unidades = const [];
  List<InsumoReferenceEntity> _suplementos = const [];

  bool get isLoading => _isLoading;
  bool get isEditing => _editingInsumo != null;
  String? get errorMessage => _errorMessage;
  String? get selectedTipoInsumo => _selectedTipoInsumo;
  int? get selectedUnidadeId => _selectedUnidadeId;
  int? get selectedSuplementoId => _selectedSuplementoId;
  List<InsumoReferenceEntity> get tipoInsumos => _tipoInsumos;
  List<InsumoReferenceEntity> get unidades => _unidades;
  List<InsumoReferenceEntity> get suplementos => _suplementos;
  bool get shouldShowSuplemento => _selectedTipoInsumo == 'suplementos';

  bool get isFormValid {
    return (_selectedTipoInsumo?.trim().isNotEmpty ?? false) &&
        nomeController.text.trim().isNotEmpty &&
        _selectedUnidadeId != null &&
        _parseDecimal(valorUnidadeController.text) != null &&
        _parseDecimal(qtdTotalController.text) != null;
  }

  Future<void> init({InsumoEntity? insumo}) async {
    AppLogger.info('INSUMOS ADD CONTROLLER: INICIANDO');
    _editingInsumo = insumo;
    _clearForm();
    if (insumo != null) {
      _fillForm(insumo);
    }
    _setLoading(true);
    _errorMessage = null;

    try {
      final user = await SessionStorage.getUserSession();
      _currentUserId = user?.id;
      if (_currentUserId == null) {
        throw ApiException('Usuario nao autenticado.');
      }

      final result = await _getInsumosUsecase(
        InsumosFilterEntity(appUsersId: _currentUserId!),
      );
      _tipoInsumos = result.tipoInsumos;
      _unidades = result.unidades;
      _suplementos = result.suplementos;
      AppLogger.success('INSUMOS ADD CONTROLLER: OPCOES CARREGADAS');
    } on ApiException catch (error) {
      _errorMessage = error.message;
      AppLogger.error(
        'INSUMOS ADD CONTROLLER: ERRO AO CARREGAR OPCOES MSG=${error.message}',
      );
    } finally {
      _setLoading(false);
    }
  }

  void onTipoChanged(String? value) {
    _selectedTipoInsumo = value;
    if (!shouldShowSuplemento) {
      _selectedSuplementoId = null;
    }
    notifyListeners();
  }

  void onUnidadeChanged(int? value) {
    _selectedUnidadeId = value;
    notifyListeners();
  }

  void onSuplementoChanged(int? value) {
    _selectedSuplementoId = value;
    notifyListeners();
  }

  Future<ApiMessage?> submit() async {
    AppLogger.info('INSUMOS ADD CONTROLLER: INICIANDO SUBMIT');
    if (!isFormValid) {
      _errorMessage = 'Preencha os campos obrigatorios.';
      notifyListeners();
      return null;
    }

    _setLoading(true);
    _errorMessage = null;

    try {
      _currentUserId ??= (await SessionStorage.getUserSession())?.id;
      if (_currentUserId == null) {
        throw ApiException('Usuario nao autenticado.');
      }

      final insumo = InsumoUpsertEntity(
        id: _editingInsumo?.id,
        appUsersId: _currentUserId,
        tipoInsumo: _selectedTipoInsumo!,
        appEstoquesInsumosSuplementosId: _selectedSuplementoId,
        nome: nomeController.text.trim(),
        appEstoquesInsumosUnidadesId: _selectedUnidadeId!,
        valorUnidade: valorUnidadeController.text.trim(),
        qtdTotal: _parseDecimal(qtdTotalController.text)!,
        obs: _emptyToNull(obsController.text),
        dataValidade: _emptyToNull(dataValidadeController.text),
      );

      final result = isEditing
          ? await _updateInsumoUsecase(insumo)
          : await _createInsumoUsecase(insumo);
      AppLogger.success(
        'INSUMOS ADD CONTROLLER: INSUMO SALVO STATUS=${result.status} MSG=${result.message}',
      );
      return result;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      AppLogger.error(
        'INSUMOS ADD CONTROLLER: ERRO AO SALVAR MSG=${error.message}',
      );
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  String? _emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  double? _parseDecimal(String value) {
    final normalized = value.trim().replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(normalized);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearForm() {
    _selectedTipoInsumo = null;
    _selectedUnidadeId = null;
    _selectedSuplementoId = null;
    nomeController.clear();
    valorUnidadeController.clear();
    qtdTotalController.clear();
    obsController.clear();
    dataValidadeController.clear();
  }

  void _fillForm(InsumoEntity insumo) {
    _selectedTipoInsumo = insumo.tipoInsumo;
    _selectedUnidadeId = insumo.appEstoquesInsumosUnidadesId;
    _selectedSuplementoId = insumo.appEstoquesInsumosSuplementosId;
    nomeController.text = insumo.nome;
    valorUnidadeController.text =
        _formatDecimal(insumo.valorUnidadeRaw) ??
        _formatDisplayValue(insumo.valorUnidade);
    qtdTotalController.text = _formatDecimal(insumo.qtdTotal) ?? '';
    obsController.text = insumo.obs ?? '';
    dataValidadeController.text = insumo.dataValidade ?? '';
  }

  String? _formatDecimal(double? value) {
    if (value == null) {
      return null;
    }
    if (value % 1 == 0) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(2).replaceAll('.', ',');
  }

  String _formatDisplayValue(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return '';
    }
    return text.replaceAll(RegExp(r'[^0-9,.]'), '').replaceAll('.', ',');
  }

  @override
  void dispose() {
    nomeController.dispose();
    valorUnidadeController.dispose();
    qtdTotalController.dispose();
    obsController.dispose();
    dataValidadeController.dispose();
    super.dispose();
  }
}
