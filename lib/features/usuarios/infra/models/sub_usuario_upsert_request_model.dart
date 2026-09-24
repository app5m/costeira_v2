import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/features/usuarios/domain/entities/sub_usuario_upsert_entity.dart';

class SubUsuarioUpsertRequestModel {
  const SubUsuarioUpsertRequestModel._(this.data);

  final Map<String, dynamic> data;

  factory SubUsuarioUpsertRequestModel.fromEntity(
    SubUsuarioUpsertEntity usuario,
  ) {
    return SubUsuarioUpsertRequestModel._({
      'token': WSConstantes.token,
      'id_vinculo_usuario': usuario.ownerUserId,
      'id_vinculo_fazenda': usuario.farmIds,
      'nome': usuario.nome,
      'email': usuario.email,
      'celular': usuario.celular,
      'permissoes': usuario.permissionIds,
      if (usuario.id != null) 'id': usuario.id,
    });
  }
}
