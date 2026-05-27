import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/features/movimentacoes/domain/entities/movimentacao_charts_filter_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/transferencia_charts_entity.dart';
import 'package:costeira/features/movimentacoes/domain/usecases/get_transferencia_charts_usecase.dart';
import 'package:flutter/foundation.dart';

class GetTransferenciaChartsController extends ChangeNotifier {
  GetTransferenciaChartsController(this._getTransferenciaChartsUsecase);

  final GetTransferenciaChartsUsecase _getTransferenciaChartsUsecase;

  bool _isLoading = false;
  String? _errorMessage;
  TransferenciaChartsEntity? _charts;
  DateTime _month = DateTime.now();
  int _reloadVersion = 0;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  TransferenciaChartsEntity? get charts => _charts;
  DateTime get month => _month;

  Future<void> load({DateTime? month}) async {
    final requestVersion = ++_reloadVersion;
    final nextMonth = month ?? _month;
    _setLoading(true);
    _errorMessage = null;

    try {
      final user = await SessionStorage.getUserSession();
      if (user == null) {
        throw ApiException('Usuario nao autenticado para carregar graficos.');
      }

      final result = await _getTransferenciaChartsUsecase(
        MovimentacaoChartsFilterEntity(appUsersId: user.id, month: nextMonth),
      );

      if (requestVersion != _reloadVersion) {
        return;
      }

      _month = nextMonth;
      _charts = result;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      rethrow;
    } finally {
      if (requestVersion == _reloadVersion) {
        _setLoading(false);
      }
    }
  }

  Future<void> previousMonth() async {
    if (_isLoading) return;
    await load(month: DateTime(_month.year, _month.month - 1));
  }

  Future<void> nextMonth() async {
    if (_isLoading) return;
    await load(month: DateTime(_month.year, _month.month + 1));
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
