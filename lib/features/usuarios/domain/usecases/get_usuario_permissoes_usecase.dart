import 'package:costeira/features/usuarios/domain/entities/usuario_permissao_entity.dart';
import 'package:costeira/features/usuarios/domain/repository/usuarios_datasource.dart';

class GetUsuarioPermissoesUsecase {
  const GetUsuarioPermissoesUsecase(this._datasource);

  final UsuariosDatasource _datasource;

  Future<List<UsuarioPermissaoEntity>> call() {
    return _datasource.listPermissoes();
  }
}
