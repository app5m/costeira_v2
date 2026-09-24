import 'package:costeira/features/usuarios/domain/entities/sub_usuario_entity.dart';
import 'package:costeira/features/usuarios/presentation/controllers/list_sub_usuarios_controller.dart';
import 'package:costeira/features/usuarios/presentation/page_controllers/page_action_result.dart';
import 'package:flutter/material.dart';

class SubUsuariosListPageController extends ChangeNotifier {
  SubUsuariosListPageController(this._listController) {
    _listController.addListener(notifyListeners);
  }

  final ListSubUsuariosController _listController;

  List<SubUsuarioEntity> get usuarios => _listController.usuarios;
  bool get isLoading => _listController.isLoading;
  String? get errorMessage => _listController.errorMessage;

  Future<PageActionResult?> loadInitialData() async {
    try {
      await _listController.load();
      return null;
    } catch (_) {
      return PageActionResult(
        isSuccess: false,
        message: _listController.errorMessage ?? 'Nao foi possivel carregar.',
      );
    }
  }

  Future<PageActionResult?> reload() => loadInitialData();

  @override
  void dispose() {
    _listController.removeListener(notifyListeners);
    super.dispose();
  }
}
