import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/features/insumos/domain/entities/insumos.dart';
import 'package:costeira/features/insumos/domain/usecases/create_insumo_registro_usecase.dart';
import 'package:costeira/features/insumos/domain/usecases/get_insumos_tipo_usecase.dart';
import 'package:flutter/material.dart';

class AddInsumoRegistroController extends ChangeNotifier {
  AddInsumoRegistroController(
    this._createRegistroUsecase,
    this._getInsumosTipoUsecase,
  ) {
    qtdController.addListener(notifyListeners);
    obsController.addListener(notifyListeners);
  }

  final CreateInsumoRegistroUsecase _createRegistroUsecase;
  final GetInsumosTipoUsecase _getInsumosTipoUsecase;

  final qtdController = TextEditingController();
  final obsController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  int? _currentUserId;
  int? _selectedInsumoId;
  List<InsumoTipoEntity> _insumos = const [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int? get selectedInsumoId => _selectedInsumoId;
  List<InsumoTipoEntity> get insumos => _insumos;
  InsumoTipoEntity? get selectedInsumo {
    final matches = _insumos.where((insumo) => insumo.id == _selectedInsumoId);
    return matches.isEmpty ? null : matches.first;
  }

  bool get isFormValid {
    final insumo = selectedInsumo;
    return insumo != null &&
        int.tryParse(insumo.unidade?.id?.toString() ?? '') != null &&
        _parseDecimal(qtdController.text) != null;
  }

  Future<void> init() async {
    AppLogger.info('INSUMOS REGISTRO CONTROLLER: CARREGANDO INSUMOS');
    _setLoading(true);
    _errorMessage = null;

    try {
      final user = await SessionStorage.getUserSession();
      _currentUserId = user?.id;
      if (_currentUserId == null) {
        throw ApiException('Usuario nao autenticado.');
      }

      final result = await _getInsumosTipoUsecase(
        InsumosTipoFilterEntity(appUsersId: _currentUserId!),
      );
      _insumos = result.data;
      AppLogger.success(
        'INSUMOS REGISTRO CONTROLLER: ${result.rows} INSUMOS CARREGADOS',
      );
    } on ApiException catch (error) {
      _errorMessage = error.message;
      AppLogger.error(
        'INSUMOS REGISTRO CONTROLLER: ERRO AO CARREGAR MSG=${error.message}',
      );
    } finally {
      _setLoading(false);
    }
  }

  void onInsumoChanged(int? value) {
    _selectedInsumoId = value;
    notifyListeners();
  }

  Future<ApiMessage?> submit({required int tipo}) async {
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

      final insumo = selectedInsumo!;
      final unidadeId = int.parse(insumo.unidade!.id.toString());
      final result = await _createRegistroUsecase(
        InsumoRegistroUpsertEntity(
          appUsersId: _currentUserId,
          appEstoquesInsumosId: insumo.id,
          tipo: tipo,
          appEstoquesInsumosUnidadesId: unidadeId,
          qtd: _parseDecimal(qtdController.text)!,
          obs: _emptyToNull(obsController.text),
        ),
      );
      return result;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  String selectedInsumoLabel(InsumoTipoEntity insumo) {
    final unidade = insumo.unidade?.nome.trim();
    final qtd = insumo.qtdTotal;
    final formattedQtd = qtd == null
        ? null
        : qtd % 1 == 0
        ? qtd.toInt().toString()
        : qtd.toString();
    final suffix = formattedQtd == null
        ? null
        : unidade == null || unidade.isEmpty
        ? formattedQtd
        : '$formattedQtd $unidade';
    return suffix == null ? insumo.nome : '${insumo.nome} - $suffix';
  }

  String get selectedUnidadeLabel {
    final unidade = selectedInsumo?.unidade?.nome.trim();
    return unidade == null || unidade.isEmpty ? 'Selecione um insumo' : unidade;
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

  @override
  void dispose() {
    qtdController.dispose();
    obsController.dispose();
    super.dispose();
  }
}
