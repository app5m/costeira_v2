import 'package:costeira/features/usuarios/domain/entities/sub_usuario_entity.dart';
import 'package:costeira/features/usuarios/domain/repository/usuarios_datasource.dart';

class GetSubUsuariosUsecase {
  const GetSubUsuariosUsecase(this._datasource);

  final UsuariosDatasource _datasource;

  Future<List<SubUsuarioEntity>> call(int ownerUserId) {
    return _datasource.listUsuarios(ownerUserId);
  }
}
