import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/features/dashboard/domain/entities/dashboard_entity.dart';
import 'package:costeira/features/dashboard/domain/entities/dashboard_filter_entity.dart';
import 'package:costeira/features/dashboard/domain/usecases/get_dashboard_usecase.dart';
import 'package:flutter/foundation.dart';

class GetDashboardController extends ChangeNotifier {
  GetDashboardController(this._getDashboardUsecase);

  final GetDashboardUsecase _getDashboardUsecase;

  bool _isLoading = false;
  String? _errorMessage;
  DashboardEntity? _dashboard;
  DashboardFilterEntity _filter = _initialFilter();
  int _rows = 0;
  int _reloadVersion = 0;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DashboardEntity? get dashboard => _dashboard;
  DashboardFilterEntity get filter => _filter;
  int get rows => _rows;

  Future<void> load({DashboardFilterEntity? filter}) async {
    final requestVersion = ++_reloadVersion;
    final nextFilter = filter ?? _filter;

    _setLoading(true);
    _errorMessage = null;

    try {
      final user = await SessionStorage.getUserSession();
      final userId = user?.id ?? 0;
      if (userId <= 0) {
        throw ApiException('Usuario nao autenticado para carregar dashboard.');
      }

      final requestFilter = nextFilter.copyWith(appUsersId: userId);
      final result = await _getDashboardUsecase(requestFilter);

      if (requestVersion != _reloadVersion) {
        return;
      }

      _filter = nextFilter;
      _rows = result.rows;
      _dashboard = result.firstOrEmpty;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      rethrow;
    } finally {
      if (requestVersion == _reloadVersion) {
        _setLoading(false);
      }
    }
  }

  Future<void> reload() {
    return load(filter: _filter);
  }

  Future<void> previousYear() {
    final year = _filter.dataIn.year - 1;
    return load(filter: _yearFilter(year));
  }

  Future<void> nextYear() {
    final year = _filter.dataIn.year + 1;
    return load(filter: _yearFilter(year));
  }

  Future<void> previousPeriod() {
    if (_isSingleDayFilter(_filter)) {
      return selectDay(_filter.dataIn.subtract(const Duration(days: 1)));
    }
    return previousYear();
  }

  Future<void> nextPeriod() {
    if (_isSingleDayFilter(_filter)) {
      return selectDay(_filter.dataIn.add(const Duration(days: 1)));
    }
    return nextYear();
  }

  Future<void> selectDay(DateTime date) {
    final selectedDate = DateTime(date.year, date.month, date.day);
    return load(
      filter: DashboardFilterEntity(
        dataIn: selectedDate,
        dataOut: selectedDate,
      ),
    );
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  static DashboardFilterEntity _initialFilter() {
    return _yearFilter(DateTime.now().year);
  }

  static DashboardFilterEntity _yearFilter(int year) {
    return DashboardFilterEntity(
      dataIn: DateTime(year),
      dataOut: DateTime(year, 12, 31),
    );
  }

  static bool _isSingleDayFilter(DashboardFilterEntity filter) {
    return filter.dataIn.year == filter.dataOut.year &&
        filter.dataIn.month == filter.dataOut.month &&
        filter.dataIn.day == filter.dataOut.day;
  }
}
