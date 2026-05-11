import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/features/sanitarios/domain/entities/sanitario.dart';
import 'package:costeira/features/sanitarios/domain/usecases/get_sanitario_charts_usecase.dart';
import 'package:flutter/foundation.dart';

class GetSanitarioChartsController extends ChangeNotifier {
  GetSanitarioChartsController(this._getChartsUsecase);

  final GetSanitarioChartsUsecase _getChartsUsecase;

  bool _isLoading = false;
  String? _errorMessage;
  SanitarioChartsEntity? _charts;
  DateTime _selectedMonth = DateTime.now();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  SanitarioChartsEntity? get charts => _charts;
  DateTime get selectedMonth => _selectedMonth;
  String get mesAno =>
      '${_selectedMonth.month.toString().padLeft(2, '0')}/${_selectedMonth.year}';

  Future<void> load() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final user = await SessionStorage.getUserSession();
      if (user == null) {
        throw ApiException('Usuario nao autenticado.');
      }

      _charts = await _getChartsUsecase(
        SanitarioChartsFilterEntity(appUsersId: user.id, mesAno: mesAno),
      );
    } on ApiException catch (error) {
      _errorMessage = error.message;
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> previousMonth() async {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    notifyListeners();
    await load();
  }

  Future<void> nextMonth() async {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    notifyListeners();
    await load();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
