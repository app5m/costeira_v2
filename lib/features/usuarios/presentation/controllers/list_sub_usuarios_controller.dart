import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/features/usuarios/domain/entities/sub_usuario_entity.dart';
import 'package:costeira/features/usuarios/domain/usecases/get_sub_usuarios_usecase.dart';
import 'package:flutter/foundation.dart';

class ListSubUsuariosController extends ChangeNotifier {
  ListSubUsuariosController(this._getSubUsuariosUsecase);

  final GetSubUsuariosUsecase _getSubUsuariosUsecase;

  bool _isLoading = false;
  String? _errorMessage;
  List<SubUsuarioEntity> _usuarios = const [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<SubUsuarioEntity> get usuarios => _usuarios;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await SessionStorage.getUserSession();
      if (user == null) {
        throw ApiException('Usuario nao autenticado.');
      }
      _usuarios = await _getSubUsuariosUsecase(user.id);
    } on ApiException catch (error) {
      _errorMessage = error.message;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
