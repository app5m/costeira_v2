import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/entities/suplemento.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/usecases/get_suplemento_charts_usecase.dart';
import 'package:flutter/foundation.dart';

class GetSuplementoChartsController extends ChangeNotifier {
  GetSuplementoChartsController(this._getChartsUsecase);

  final GetSuplementoChartsUsecase _getChartsUsecase;

  bool _isLoading = false;
  String? _errorMessage;
  SuplementoChartsEntity? _charts;
  DateTime _selectedMonth = DateTime.now();
  int? _idPotreiro;
  int? _idLote;
  int? _idProduto;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  SuplementoChartsEntity? get charts => _charts;
  DateTime get selectedMonth => _selectedMonth;
  String get mesAno =>
      '${_selectedMonth.month.toString().padLeft(2, '0')}/${_selectedMonth.year}';

  Future<void> load({int? idPotreiro, int? idLote, int? idProduto}) async {
    _idPotreiro = idPotreiro;
    _idLote = idLote;
    _idProduto = idProduto;
    _setLoading(true);
    _errorMessage = null;

    try {
      final user = await SessionStorage.getUserSession();
      if (user == null) {
        throw ApiException('Usuario nao autenticado.');
      }

      _charts = await _getChartsUsecase(
        SuplementoChartsFilterEntity(
          appUsersId: user.id,
          mesAno: mesAno,
          idPotreiro: _idPotreiro,
          idLote: _idLote,
          idProduto: _idProduto,
        ),
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
    await load(idPotreiro: _idPotreiro, idLote: _idLote, idProduto: _idProduto);
  }

  Future<void> nextMonth() async {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    notifyListeners();
    await load(idPotreiro: _idPotreiro, idLote: _idLote, idProduto: _idProduto);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
