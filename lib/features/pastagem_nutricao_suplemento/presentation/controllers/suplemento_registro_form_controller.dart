import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/entities/suplemento.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/usecases/create_suplemento_registro_usecase.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/usecases/update_suplemento_registro_usecase.dart';
import 'package:flutter/material.dart';

class SuplementoRegistroFormController extends ChangeNotifier {
  SuplementoRegistroFormController(
    this._createRegistroUsecase,
    this._updateRegistroUsecase,
  ) {
    dataController.addListener(notifyListeners);
    quantidadeController.addListener(notifyListeners);
  }

  final CreateSuplementoRegistroUsecase _createRegistroUsecase;
  final UpdateSuplementoRegistroUsecase _updateRegistroUsecase;

  final dataController = TextEditingController();
  final quantidadeController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  int? _currentUserId;
  int _selectedTipo = 1;
  Suplemento? _suplemento;
  SuplementoRegistro? _editingRegistro;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get selectedTipo => _selectedTipo;
  bool get isEditing => _editingRegistro != null;

  bool get isFormValid =>
      _suplemento != null &&
      dataController.text.trim().isNotEmpty &&
      _parseDecimal(quantidadeController.text) != null;

  Future<void> init({
    required Suplemento suplemento,
    SuplementoRegistro? registro,
  }) async {
    _suplemento = suplemento;
    _editingRegistro = registro;
    if (registro != null) {
      _selectedTipo = registro.tipo.id == 2 ? 2 : 1;
      dataController.text = _dateOnly(registro.dataRestabastecimento);
      quantidadeController.text = _formatDecimal(registro.quantidade);
    }

    final user = await SessionStorage.getUserSession();
    _currentUserId = user?.id;
    if (_currentUserId == null) {
      _errorMessage = 'Usuario nao autenticado.';
    }
    notifyListeners();
  }

  void onTipoChanged(int? value) {
    if (value == null) return;
    _selectedTipo = value;
    notifyListeners();
  }

  void incrementQuantidade() {
    final value = _parseDecimal(quantidadeController.text) ?? 0;
    quantidadeController.text = _formatDecimal(value + 1);
  }

  void decrementQuantidade() {
    final value = _parseDecimal(quantidadeController.text) ?? 0;
    quantidadeController.text = _formatDecimal(value <= 1 ? 0 : value - 1);
  }

  Future<ApiMessage?> submit() async {
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

      final entity = SuplementoRegistroUpsertEntity(
        id: _editingRegistro?.id,
        appUsersId: _currentUserId,
        appSuplementacaoId: _suplemento!.id,
        tipo: _selectedTipo,
        dataRestabastecimento: dataController.text.trim(),
        quantidade: _parseDecimal(quantidadeController.text)!,
      );

      return isEditing
          ? _updateRegistroUsecase(entity)
          : _createRegistroUsecase(entity);
    } on ApiException catch (error) {
      _errorMessage = error.message;
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  String _dateOnly(String? value) {
    if (value == null || value.isEmpty) return '';
    return value.split(' ').first;
  }

  double? _parseDecimal(String value) {
    final normalized = value.trim().replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(normalized);
  }

  String _formatDecimal(double? value) {
    if (value == null) return '';
    if (value % 1 == 0) return value.toInt().toString();
    return value.toStringAsFixed(2).replaceAll('.', ',');
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    dataController.dispose();
    quantidadeController.dispose();
    super.dispose();
  }
}
