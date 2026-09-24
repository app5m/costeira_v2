import 'package:costeira/features/usuarios/domain/repository/usuarios_datasource.dart';
import 'package:costeira/features/usuarios/domain/usecases/get_sub_usuarios_usecase.dart';
import 'package:costeira/features/usuarios/domain/usecases/get_usuario_permissoes_usecase.dart';
import 'package:costeira/features/usuarios/domain/usecases/save_sub_usuario_usecase.dart';
import 'package:costeira/features/usuarios/infra/data/usuarios_datasource_impl.dart';
import 'package:costeira/features/usuarios/presentation/controllers/list_sub_usuarios_controller.dart';
import 'package:costeira/features/usuarios/presentation/controllers/save_sub_usuario_controller.dart';
import 'package:costeira/features/usuarios/presentation/page_controllers/sub_usuario_form_page_controller.dart';
import 'package:costeira/features/usuarios/presentation/page_controllers/sub_usuarios_list_page_controller.dart';
import 'package:flutter_modular/flutter_modular.dart';

class UsuariosBinds {
  static void register(Injector i) {
    i.addLazySingleton<UsuariosDatasource>(UsuariosDatasourceImpl.new);
    i.addLazySingleton(GetSubUsuariosUsecase.new);
    i.addLazySingleton(GetUsuarioPermissoesUsecase.new);
    i.addLazySingleton(SaveSubUsuarioUsecase.new);
    i.add(ListSubUsuariosController.new);
    i.add(SaveSubUsuarioController.new);
    i.add(SubUsuariosListPageController.new);
    i.add(SubUsuarioFormPageController.new);
  }
}
