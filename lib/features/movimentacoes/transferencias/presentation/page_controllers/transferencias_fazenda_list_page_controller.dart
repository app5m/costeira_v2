import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/features/fazendas/domain/usecases/resolve_current_farm_id.dart';
import 'package:costeira/features/movimentacoes/domain/entities/movimentacao_filter_entity.dart';
import 'package:costeira/features/movimentacoes/transferencias/domain/entities/transferencia_fazenda_list_item.dart';
import 'package:costeira/features/movimentacoes/transferencias/domain/usecases/get_transferencias_fazenda_usecase.dart';
import 'package:costeira/features/movimentacoes/transferencias/presentation/controllers/aceitar_transferencia_fazenda_controller.dart';
import 'package:flutter/foundation.dart';

class TransferenciasFazendaListPageController extends ChangeNotifier {
  TransferenciasFazendaListPageController(
    this._getUsecase,
    this._aceitarController,
    this._resolveCurrentFarmId,
  ) {
    _aceitarController.addListener(notifyListeners);
  }

  static const aprovado = 1;
  static const pendente = 2;
  static const recusado = 3;

  final GetTransferenciasFazendaUsecase _getUsecase;
  final AceitarTransferenciaFazendaController _aceitarController;
  final ResolveCurrentFarmId _resolveCurrentFarmId;

  bool _isLoading = false;
  String? _errorMessage;
  String? dataIn;
  String? dataOut;
  List<TransferenciaFazendaListItem> recebidas = const [];
  List<TransferenciaFazendaListItem> enviadas = const [];

  bool get isLoading => _isLoading || _aceitarController.isLoading;
  String? get errorMessage =>
      _errorMessage ?? _aceitarController.errorMessage;
  bool get hasActiveFilters =>
      (dataIn?.isNotEmpty ?? false) || (dataOut?.isNotEmpty ?? false);

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final user = await SessionStorage.getUserSession();
      if (user == null) {
        throw ApiException('Usuario nao autenticado.');
      }
      final farmId = await _resolveCurrentFarmId(userId: user.id);
      final result = await _getUsecase(
        MovimentacaoFilterEntity(
          appUsersId: user.id,
          appFazendasId: farmId,
          dataIn: dataIn,
          dataOut: dataOut,
        ),
      );
      recebidas = result.recebidas;
      enviadas = result.enviadas;
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> applyDateFilters({String? dataIn, String? dataOut}) async {
    this.dataIn = dataIn;
    this.dataOut = dataOut;
    await load();
    return _errorMessage;
  }

  Future<String?> decidir({
    required int id,
    required int statusTransferencia,
  }) async {
    final result = await _aceitarController.submit(
      id: id,
      statusTransferencia: statusTransferencia,
    );
    if (result == null || !result.isSuccess) {
      return _aceitarController.errorMessage ??
          'Nao foi possivel atualizar a transferencia.';
    }
    await load();
    return null;
  }

  @override
  void dispose() {
    _aceitarController.removeListener(notifyListeners);
    super.dispose();
  }
}
