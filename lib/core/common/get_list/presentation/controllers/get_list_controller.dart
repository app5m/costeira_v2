import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/common/get_list/domain/entities/get_list_entity.dart';
import 'package:costeira/core/common/get_list/domain/entities/get_list_params_entity.dart';
import 'package:costeira/core/common/get_list/domain/usecases/get_list_usecase.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:flutter/foundation.dart';

class GetListController extends ChangeNotifier {
  GetListController(this._getListUsecase);

  final GetListUsecase _getListUsecase;

  bool _isLoading = false;
  String? _errorMessage;
  GetListEntity? _result;
  int? _currentSexo;
  int? _currentUserId;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  GetListEntity? get result => _result;
  int? get currentSexo => _currentSexo;

  Future<GetListEntity?> load(int sexo, {int? userId}) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      _currentSexo = sexo;
      _currentUserId = userId ?? _currentUserId ?? await _sessionUserId();
      final response = await _getListUsecase(
        GetListParamsEntity(sexo: sexo, userId: _currentUserId),
      );
      _result = response;
      return response;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<GetListEntity?> reload() async {
    final sexo = _currentSexo;
    if (sexo == null) {
      return null;
    }
    return load(sexo, userId: _currentUserId);
  }

  void clear() {
    _errorMessage = null;
    _result = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<int?> _sessionUserId() async {
    final user = await SessionStorage.getUserSession();
    return user?.id;
  }
}
