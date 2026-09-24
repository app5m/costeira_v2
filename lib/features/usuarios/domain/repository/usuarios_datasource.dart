import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/features/usuarios/domain/entities/sub_usuario_entity.dart';
import 'package:costeira/features/usuarios/domain/entities/sub_usuario_upsert_entity.dart';
import 'package:costeira/features/usuarios/domain/entities/usuario_permissao_entity.dart';

abstract class UsuariosDatasource {
  Future<List<SubUsuarioEntity>> listUsuarios(int ownerUserId);

  Future<List<UsuarioPermissaoEntity>> listPermissoes();

  Future<ApiMessage> saveUsuario(SubUsuarioUpsertEntity usuario);
}
