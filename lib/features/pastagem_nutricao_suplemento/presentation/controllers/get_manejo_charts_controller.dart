import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/entities/manejo.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/usecases/get_manejo_charts_usecase.dart';
import 'package:flutter/foundation.dart';

class GetManejoChartsController extends ChangeNotifier {
  GetManejoChartsController(this._getChartsUsecase);

  final GetManejoChartsUsecase _getChartsUsecase;

  bool _isLoading = false;
  String? _errorMessage;
  ManejoChartsEntity? _charts;
  DateTime _selectedMonth = DateTime.now();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ManejoChartsEntity? get charts => _charts;
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
        ManejoChartsFilterEntity(appUsersId: user.id, mesAno: mesAno),
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
