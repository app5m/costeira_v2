import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/entities/manejo.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/entities/manejo_filter.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/usecases/create_manejo_usecase.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/usecases/get_tipos_manejo_usecase.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/usecases/update_manejo_usecase.dart';
import 'package:costeira/features/potreiros/domain/entities/potreiros_filter_entity.dart';
import 'package:costeira/features/potreiros/domain/entities/potreiro_entity.dart';
import 'package:costeira/features/potreiros/domain/usecases/get_potreiros_usecase.dart';
import 'package:flutter/material.dart';

class ManejoFormController extends ChangeNotifier {
  ManejoFormController(
    this._createManejoUsecase,
    this._updateManejoUsecase,
    this._getPotreirosUsecase,
    this._getTiposManejoUsecase,
  ) {
    dataController.addListener(notifyListeners);
    quantidadeController.addListener(notifyListeners);
  }

  final CreateManejoUsecase _createManejoUsecase;
  final UpdateManejoUsecase _updateManejoUsecase;
  final GetPotreirosUsecase _getPotreirosUsecase;
  final GetTiposManejoUsecase _getTiposManejoUsecase;

  final dataController = TextEditingController();
  final quantidadeController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  int? _currentUserId;
  int? _selectedPotreiroId;
  String? _selectedTipoManejoId;
  Manejo? _editingManejo;
  List<PotreiroEntity> _potreiros = const [];
  List<TipoManejo> _tiposManejo = const [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int? get selectedPotreiroId => _selectedPotreiroId;
  String? get selectedTipoManejoId => _selectedTipoManejoId;
  List<PotreiroEntity> get potreiros => _potreiros;
  List<TipoManejo> get tiposManejo => _tiposManejo;
  bool get isEditing => _editingManejo != null;

  TipoManejo? get selectedTipoManejo {
    final selectedId = _selectedTipoManejoId;
    if (selectedId == null) return null;
    return _tiposManejo.where((item) => item.id == selectedId).firstOrNull;
  }

  String get quantidadeUnidade {
    final unidade = selectedTipoManejo?.unidade.trim();
    if (unidade == null || unidade.isEmpty) {
      return _editingManejo?.unidade?.nome.trim() ?? '';
    }
    return unidade;
  }

  bool get isFormValid =>
      _selectedPotreiroId != null &&
      _selectedTipoManejoId != null &&
      dataController.text.trim().isNotEmpty &&
      _parseDecimal(quantidadeController.text) != null;

  bool get hasChanges {
    final manejo = _editingManejo;
    if (manejo == null) return true;

    final tipoNome = selectedTipoManejo?.nome.trim() ?? manejo.tipoManejo;
    final quantidade = _parseDecimal(quantidadeController.text);

    return _selectedPotreiroId != manejo.appPotreirosId ||
        tipoNome != manejo.tipoManejo.trim() ||
        dataController.text.trim() != _dateOnly(manejo.dataManejo) ||
        quantidade != manejo.quantidade;
  }

  bool get canSubmit => !isLoading && isFormValid && (!isEditing || hasChanges);

  Future<void> init({Manejo? manejo}) async {
    _editingManejo = manejo;
    if (manejo != null) {
      _selectedPotreiroId = manejo.appPotreirosId;
      dataController.text = _dateOnly(manejo.dataManejo);
      quantidadeController.text = _formatDecimal(manejo.quantidade);
    }

    _setLoading(true);
    _errorMessage = null;

    try {
      final user = await SessionStorage.getUserSession();
      _currentUserId = user?.id;
      if (_currentUserId == null) {
        throw ApiException('Usuario nao autenticado.');
      }

      final results = await Future.wait([
        _getPotreirosUsecase(
          PotreirosFilterEntity(appUsersId: _currentUserId!),
        ),
        _getTiposManejoUsecase(ManejoFilterEntity(appUsersId: _currentUserId!)),
      ]);

      _potreiros = (results[0] as dynamic).data as List<PotreiroEntity>;
      _tiposManejo = results[1] as List<TipoManejo>;
      _selectedTipoManejoId = _resolveTipoManejoId(manejo);
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } finally {
      _setLoading(false);
    }
  }

  void onPotreiroChanged(int? value) {
    _selectedPotreiroId = value;
    notifyListeners();
  }

  void onTipoManejoChanged(String? value) {
    _selectedTipoManejoId = value;
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
    if (!canSubmit) {
      _errorMessage = isEditing && !hasChanges
          ? 'Altere algum campo para atualizar.'
          : 'Preencha os campos obrigatorios.';
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

      final tipoManejo = selectedTipoManejo;
      if (tipoManejo == null) {
        throw ApiException('Selecione o tipo de manejo.');
      }

      final entity = ManejoUpsertEntity(
        id: _editingManejo?.id,
        appUsersId: _currentUserId,
        appPotreirosId: _selectedPotreiroId!,
        tipoManejo: tipoManejo.nome,
        dataManejo: dataController.text.trim(),
        quantidade: _parseDecimal(quantidadeController.text)!,
      );

      return isEditing
          ? _updateManejoUsecase(entity)
          : _createManejoUsecase(entity);
    } on ApiException catch (error) {
      _errorMessage = error.message;
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  String tipoManejoLabel(TipoManejo tipo) {
    final unidade = tipo.unidade.trim();
    return unidade.isEmpty ? tipo.nome : '${tipo.nome} - $unidade';
  }

  String? _resolveTipoManejoId(Manejo? manejo) {
    if (manejo == null) return null;
    final tipo = manejo.tipoManejo.trim().toLowerCase();
    final found = _tiposManejo.where((item) {
      return item.nome.trim().toLowerCase() == tipo ||
          item.id.trim().toLowerCase() == tipo;
    }).firstOrNull;
    return found?.id;
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
