import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/core/offline/cache/form_dependencies_cache_service.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/features/animals/domain/entities/animal_lot_entity.dart';
import 'package:costeira/features/animals/domain/entities/animal_lots_filter_entity.dart';
import 'package:costeira/features/animals/domain/usecases/get_animal_lots_usecase.dart';
import 'package:costeira/features/fazendas/domain/usecases/resolve_current_farm_id.dart';
import 'package:costeira/features/insumos/domain/entities/insumos.dart';
import 'package:costeira/features/insumos/domain/usecases/get_insumos_tipo_usecase.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/entities/suplemento.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/usecases/create_suplemento_usecase.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/usecases/update_suplemento_usecase.dart';
import 'package:costeira/features/potreiros/domain/entities/potreiros_filter_entity.dart';
import 'package:costeira/features/potreiros/domain/entities/potreiro_entity.dart';
import 'package:costeira/features/potreiros/domain/usecases/get_potreiros_usecase.dart';
import 'package:flutter/material.dart';

class SuplementoFormController extends ChangeNotifier {
  SuplementoFormController(
    this._createSuplementoUsecase,
    this._updateSuplementoUsecase,
    this._getPotreirosUsecase,
    this._getAnimalLotsUsecase,
    this._getInsumosTipoUsecase,
    this._formDependenciesCacheService,
    this._resolveCurrentFarmId,
  ) {
    dataController.addListener(notifyListeners);
    quantidadeController.addListener(notifyListeners);
  }

  final CreateSuplementoUsecase _createSuplementoUsecase;
  final UpdateSuplementoUsecase _updateSuplementoUsecase;
  final GetPotreirosUsecase _getPotreirosUsecase;
  final GetAnimalLotsUsecase _getAnimalLotsUsecase;
  final GetInsumosTipoUsecase _getInsumosTipoUsecase;
  final FormDependenciesCacheService _formDependenciesCacheService;
  final ResolveCurrentFarmId _resolveCurrentFarmId;

  final dataController = TextEditingController();
  final quantidadeController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  int? _currentUserId;
  int? _selectedPotreiroId;
  int? _selectedLoteId;
  int? _selectedProdutoId;
  Suplemento? _editingSuplemento;
  List<PotreiroEntity> _potreiros = const [];
  List<AnimalLotEntity> _lotes = const [];
  List<InsumoTipoEntity> _produtos = const [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int? get selectedPotreiroId => _selectedPotreiroId;
  int? get selectedLoteId => _selectedLoteId;
  int? get selectedProdutoId => _selectedProdutoId;
  List<PotreiroEntity> get potreiros => _potreiros;
  List<AnimalLotEntity> get lotes => _lotes;
  List<AnimalLotEntity> get lotesDisponiveis {
    if (_selectedPotreiroId == null) {
      return const [];
    }

    final vinculados = _lotes
        .where((lote) => lote.appPotreirosId == _selectedPotreiroId)
        .toList(growable: false);

    return vinculados.isEmpty ? _lotes : vinculados;
  }

  List<InsumoTipoEntity> get produtos => _produtos;
  bool get isEditing => _editingSuplemento != null;

  bool get isFormValid =>
      _selectedPotreiroId != null &&
      _selectedLoteId != null &&
      _selectedProdutoId != null &&
      dataController.text.trim().isNotEmpty &&
      _parseDecimal(quantidadeController.text) != null;

  Future<void> init({Suplemento? suplemento}) async {
    _editingSuplemento = suplemento;
    if (suplemento != null) {
      _selectedPotreiroId = suplemento.appPotreirosId;
      _selectedLoteId = suplemento.appAnimaisLotesId;
      _selectedProdutoId = suplemento.appEstoquesInsumosId;
      dataController.text = _dateOnly(suplemento.dataPostagem);
      quantidadeController.text = _formatDecimal(suplemento.quantidadeAtual);
    }

    _setLoading(true);
    _errorMessage = null;

    try {
      final user = await SessionStorage.getUserSession();
      _currentUserId = user?.id;
      if (_currentUserId == null) {
        throw ApiException('Usuario nao autenticado.');
      }

      await _formDependenciesCacheService.preloadSuplementoFormDependencies();
      final farmId = await _resolveCurrentFarmId(userId: _currentUserId);
      await _loadPotreiros(_currentUserId!, farmId);
      await _loadLotes(_currentUserId!, farmId);
      await _loadProdutos(_currentUserId!);
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadPotreiros(int userId, int? farmId) async {
    try {
      final result = await _getPotreirosUsecase(
        PotreirosFilterEntity(appUsersId: userId, appFazendasId: farmId),
      );
      _potreiros = result.data;
    } on ApiException catch (error) {
      AppLogger.warning(
        'SUPLEMENTO FORM CONTROLLER: falha ao carregar potreiros MSG=${error.message}',
      );
      if (_potreiros.isEmpty) rethrow;
    }
  }

  Future<void> _loadLotes(int userId, int? farmId) async {
    try {
      final result = await _getAnimalLotsUsecase(
        AnimalLotsFilterEntity(appUsersId: userId, appFazendasId: farmId),
      );
      _lotes = result.data;
    } on ApiException catch (error) {
      AppLogger.warning(
        'SUPLEMENTO FORM CONTROLLER: falha ao carregar lotes MSG=${error.message}',
      );
      if (_lotes.isEmpty) rethrow;
    }
  }

  Future<void> _loadProdutos(int userId) async {
    ApiException? lastError;
    for (final tipo in const ['suplementos', 'suplemento']) {
      try {
        final result = await _getInsumosTipoUsecase(
          InsumosTipoFilterEntity(appUsersId: userId, tipo: tipo),
        );
        AppLogger.info(
          'SUPLEMENTO FORM CONTROLLER: produtos tipo=$tipo carregados=${result.data.length}',
        );
        if (result.data.isNotEmpty || tipo == 'suplemento') {
          _produtos = result.data;
          return;
        }
      } on ApiException catch (error) {
        lastError = error;
        AppLogger.warning(
          'SUPLEMENTO FORM CONTROLLER: falha ao carregar produtos tipo=$tipo MSG=${error.message}',
        );
      }
    }

    if (_produtos.isNotEmpty) {
      return;
    }

    throw lastError ??
        ApiException('Sem conexao e sem dados salvos para suplementos.');
  }

  void onPotreiroChanged(int? value) {
    _selectedPotreiroId = value;
    final selectedLote = _lotes.where((lote) => lote.id == _selectedLoteId);
    if (selectedLote.isNotEmpty &&
        selectedLote.first.appPotreirosId != null &&
        selectedLote.first.appPotreirosId != value) {
      _selectedLoteId = null;
    }
    if (value == null) {
      _selectedLoteId = null;
    }
    notifyListeners();
  }

  void onLoteChanged(int? value) {
    _selectedLoteId = value;
    notifyListeners();
  }

  void onProdutoChanged(int? value) {
    _selectedProdutoId = value;
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

      final entity = SuplementoUpsertEntity(
        id: _editingSuplemento?.id,
        appUsersId: _currentUserId,
        appPotreirosId: _selectedPotreiroId!,
        appAnimaisLotesId: _selectedLoteId!,
        appEstoquesInsumosId: _selectedProdutoId!,
        dataPostagem: dataController.text.trim(),
        quantidade: _parseDecimal(quantidadeController.text)!,
      );

      return isEditing
          ? _updateSuplementoUsecase(entity)
          : _createSuplementoUsecase(entity);
    } on ApiException catch (error) {
      _errorMessage = error.message;
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  String produtoLabel(InsumoTipoEntity produto) {
    final qtd = produto.qtdTotal;
    final unidade = produto.unidade?.nome.trim();
    if (qtd == null) return produto.nome;
    final qtdText = _formatDecimal(qtd);
    return unidade == null || unidade.isEmpty
        ? '${produto.nome} - $qtdText'
        : '${produto.nome} - $qtdText $unidade';
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
