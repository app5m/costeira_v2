import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/features/tasks/domain/entities/task_charts_entity.dart';
import 'package:costeira/features/tasks/domain/entities/task_charts_filter_entity.dart';
import 'package:costeira/features/tasks/domain/usecases/get_task_charts_usecase.dart';
import 'package:flutter/foundation.dart';

class GetTaskChartsController extends ChangeNotifier {
  GetTaskChartsController(this._getTaskChartsUsecase);

  final GetTaskChartsUsecase _getTaskChartsUsecase;

  bool _isLoading = false;
  String? _errorMessage;
  TaskChartsEntity? _charts;
  DateTime _month = DateTime.now();
  int _reloadVersion = 0;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  TaskChartsEntity? get charts => _charts;
  DateTime get month => _month;

  Future<void> load({DateTime? month}) async {
    final requestVersion = ++_reloadVersion;
    final nextMonth = month ?? _month;

    _setLoading(true);
    _errorMessage = null;

    try {
      final user = await SessionStorage.getUserSession();
      final userId = user?.id ?? 0;
      if (userId <= 0) {
        throw ApiException('Usuario nao autenticado para carregar graficos.');
      }

      final filter = TaskChartsFilterEntity(
        appUsersId: userId,
        month: nextMonth,
      );

      final result = await _getTaskChartsUsecase(filter);
      AppLogger.info(
        'TASK CHARTS CONTROLLER: API MONTH=${_formatMonthForLog(nextMonth)} '
        'PROG=${result.programadas.quantidade} '
        'REAL=${result.realizadas.quantidade} '
        'ATR=${result.atrasadas.quantidade}',
      );

      if (requestVersion != _reloadVersion) {
        AppLogger.info(
          'TASK CHARTS CONTROLLER: IGNORANDO RESPOSTA ANTIGA '
          'MONTH=${_formatMonthForLog(nextMonth)}',
        );
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

  String _formatMonthForLog(DateTime date) {
    return '${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
