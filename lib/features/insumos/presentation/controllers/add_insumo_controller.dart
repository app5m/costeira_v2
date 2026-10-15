import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/common/get_list/domain/entities/get_list_params_entity.dart';
import 'package:costeira/core/common/get_list/domain/entities/list_category_entity.dart';
import 'package:costeira/core/common/get_list/domain/entities/list_item_entity.dart';
import 'package:costeira/core/common/get_list/domain/entities/list_subcategory_entity.dart';
import 'package:costeira/core/common/get_list/domain/usecases/get_list_usecase.dart';
import 'package:costeira/core/input_formatters/brazilian_currency_input_formatter.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/core/storage/sub_user_payload.dart';
import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/features/fazendas/domain/usecases/resolve_current_farm_id.dart';
import 'package:costeira/features/insumos/domain/entities/insumos.dart';
import 'package:costeira/features/insumos/domain/usecases/create_insumo_registro_usecase.dart';
import 'package:costeira/features/insumos/domain/usecases/create_insumo_usecase.dart';
import 'package:costeira/features/insumos/domain/usecases/update_insumo_usecase.dart';
import 'package:flutter/material.dart';

class AddInsumoController extends ChangeNotifier {
  AddInsumoController(
    this._createInsumoUsecase,
    this._createRegistroUsecase,
    this._getListUsecase,
    this._updateInsumoUsecase,
    this._resolveCurrentFarmId,
  ) {
    nomeController.addListener(notifyListeners);
    valorUnidadeController.addListener(notifyListeners);
    qtdTotalController.addListener(notifyListeners);
    obsController.addListener(notifyListeners);
    dataValidadeController.addListener(notifyListeners);
  }

  final CreateInsumoUsecase _createInsumoUsecase;
  final CreateInsumoRegistroUsecase _createRegistroUsecase;
  final GetListUsecase _getListUsecase;
  final UpdateInsumoUsecase _updateInsumoUsecase;
  final ResolveCurrentFarmId _resolveCurrentFarmId;

  final nomeController = TextEditingController();
  final valorUnidadeController = TextEditingController();
  final qtdTotalController = TextEditingController();
  final obsController = TextEditingController();
  final dataValidadeController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  int? _currentUserId;
  int? _farmId;
  InsumoEntity? _editingInsumo;
  int? _categoriaId;
  int? _subcategoriaId;
  int? _selectedUnidadeId;
  List<ListCategoryEntity> _categorias = const [];
  List<ListItemEntity> _unidades = const [];

  bool get isLoading => _isLoading;
  bool get isEditing => _editingInsumo != null;
  String? get errorMessage => _errorMessage;
  int? get categoriaId => _categoriaId;
  int? get subcategoriaId => _subcategoriaId;
  int? get selectedUnidadeId => _selectedUnidadeId;
  List<ListCategoryEntity> get categorias => _categorias;
  List<ListItemEntity> get unidades => _unidades;
  List<ListSubcategoryEntity> get subcategorias {
    final id = _categoriaId;
    if (id == null) {
      return const [];
    }
    for (final categoria in _categorias) {
      if (categoria.id == id) {
        return categoria.subcategorias;
      }
    }
    return const [];
  }

  bool get isFormValid {
    final precisaSub = subcategorias.isNotEmpty;
    return _categoriaId != null &&
        (!precisaSub || _subcategoriaId != null) &&
        nomeController.text.trim().isNotEmpty &&
        _selectedUnidadeId != null &&
        _selectedUnidadeId! > 0 &&
        (BrazilianCurrency.parse(valorUnidadeController.text) ?? 0) > 0 &&
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
      _currentUserId = user == null ? null : sessionAccountUserId(user.id);
      if (_currentUserId == null) {
        throw ApiException('Usuario nao autenticado.');
      }
      _farmId = await _resolveCurrentFarmId(userId: _currentUserId);
      if (_farmId == null || _farmId! <= 0) {
        throw ApiException('Selecione uma fazenda antes de registrar a entrada.');
      }

      final lists = await _getListUsecase(
        GetListParamsEntity(sexo: 1, userId: _currentUserId),
      );
      _categorias = lists.estoqueInsumosCategorias;
      _unidades = lists.estoqueUnidadesMedidas;
      AppLogger.success(
        'INSUMOS ADD CONTROLLER: CAT=${_categorias.length} UN=${_unidades.length}',
      );
    } on ApiException catch (error) {
      _errorMessage = error.message;
      AppLogger.error(
        'INSUMOS ADD CONTROLLER: ERRO AO CARREGAR OPCOES MSG=${error.message}',
      );
    } finally {
      _setLoading(false);
    }
  }

  void onCategoriaChanged(int? value) {
    _categoriaId = value;
    _subcategoriaId = null;
    notifyListeners();
  }

  void onSubcategoriaChanged(int? value) {
    _subcategoriaId = value;
    notifyListeners();
  }

  void onUnidadeChanged(int? value) {
    _selectedUnidadeId = value;
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
      final session = await SessionStorage.getUserSession();
      _currentUserId ??= session == null
          ? null
          : sessionAccountUserId(session.id);
      if (_currentUserId == null) {
        throw ApiException('Usuario nao autenticado.');
      }
      _farmId ??= await _resolveCurrentFarmId(userId: _currentUserId);
      if (_farmId == null || _farmId! <= 0) {
        throw ApiException('Selecione uma fazenda antes de registrar a entrada.');
      }

      final quantidade = _parseDecimal(qtdTotalController.text)!;
      final insumo = InsumoUpsertEntity(
        id: _editingInsumo?.id,
        appUsersId: _currentUserId,
        appFazendasId: _farmId,
        tipoInsumo: (_subcategoriaId ?? _categoriaId).toString(),
        nome: nomeController.text.trim(),
        appEstoquesInsumosUnidadesId: _selectedUnidadeId!,
        appEstoquesInsumosCategoriasId: _categoriaId,
        appEstoquesInsumosSubcategoriasId: _subcategoriaId,
        valorUnidade: BrazilianCurrency.toApi(valorUnidadeController.text),
        qtdTotal: quantidade,
        obs: _emptyToNull(obsController.text),
        dataValidade: _emptyToNull(dataValidadeController.text),
      );

      if (isEditing) {
        final result = await _updateInsumoUsecase(insumo);
        AppLogger.success(
          'INSUMOS ADD CONTROLLER: INSUMO SALVO STATUS=${result.status} MSG=${result.message}',
        );
        return result;
      }

      final created = await _createInsumoUsecase(insumo);
      final insumoId = created.resourceId;
      if (insumoId == null) {
        throw ApiException(
          'Produto cadastrado sem id para registrar a entrada.',
        );
      }

      final registro = await _createRegistroUsecase(
        InsumoRegistroUpsertEntity(
          appUsersId: _currentUserId,
          appFazendasId: _farmId,
          appEstoquesInsumosId: insumoId,
          tipo: 1,
          appEstoquesInsumosUnidadesId: _selectedUnidadeId!,
          qtd: quantidade,
          obs: _emptyToNull(obsController.text),
        ),
      );
      AppLogger.success(
        'INSUMOS ADD CONTROLLER: ENTRADA SALVA STATUS=${registro.status} INSUMO=$insumoId',
      );
      return registro;
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
    _categoriaId = null;
    _subcategoriaId = null;
    _selectedUnidadeId = null;
    nomeController.clear();
    valorUnidadeController.clear();
    qtdTotalController.clear();
    obsController.clear();
    dataValidadeController.clear();
  }

  void _fillForm(InsumoEntity insumo) {
    _categoriaId = insumo.appEstoquesInsumosCategoriasId;
    _subcategoriaId = insumo.appEstoquesInsumosSubcategoriasId;
    final unidadeId = insumo.appEstoquesInsumosUnidadesId;
    _selectedUnidadeId = unidadeId > 0
        ? unidadeId
        : int.tryParse(insumo.unidade?.id?.toString() ?? '');
    nomeController.text = insumo.nome;
    valorUnidadeController.text =
        BrazilianCurrency.formatFromRaw(insumo.valorUnidade) ??
        (insumo.valorUnidadeRaw != null
            ? BrazilianCurrency.format(insumo.valorUnidadeRaw!)
            : '');
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
