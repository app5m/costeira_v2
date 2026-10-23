import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/core/storage/sub_user_payload.dart';
import 'package:costeira/features/tasks/domain/entities/task_responsavel_upsert_entity.dart';

class TaskResponsavelUpsertRequestDto {
  const TaskResponsavelUpsertRequestDto._(this.data);

  final Map<String, dynamic> data;

  factory TaskResponsavelUpsertRequestDto.fromEntity(
    TaskResponsavelUpsertEntity responsavel,
  ) {
    return TaskResponsavelUpsertRequestDto._(withSubUser({
      'token': WSConstantes.token,
      'app_users_id': responsavel.appUsersId,
      'app_fazendas_id': responsavel.appFazendasId,
      if (responsavel.id != null) 'id': responsavel.id,
      'nome': responsavel.nome,
      'email': responsavel.email,
      'celular': responsavel.celular,
    }));
  }
}
