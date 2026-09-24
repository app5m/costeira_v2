import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/features/usuarios/domain/entities/sub_usuario_upsert_entity.dart';
import 'package:costeira/features/usuarios/domain/repository/usuarios_datasource.dart';

class SaveSubUsuarioUsecase {
  const SaveSubUsuarioUsecase(this._datasource);

  final UsuariosDatasource _datasource;

  Future<ApiMessage> call(SubUsuarioUpsertEntity usuario) {
    return _datasource.saveUsuario(usuario);
  }
}
