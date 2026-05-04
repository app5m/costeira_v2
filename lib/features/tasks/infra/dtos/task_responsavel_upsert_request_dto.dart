import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/features/tasks/domain/entities/task_responsavel_upsert_entity.dart';

class TaskResponsavelUpsertRequestDto {
  const TaskResponsavelUpsertRequestDto._(this.data);

  final Map<String, dynamic> data;

  factory TaskResponsavelUpsertRequestDto.fromEntity(
    TaskResponsavelUpsertEntity responsavel,
  ) {
    return TaskResponsavelUpsertRequestDto._({
      'token': WSConstantes.token,
      'app_users_id': responsavel.appUsersId,
      if (responsavel.id != null) 'id': responsavel.id,
      'nome': responsavel.nome,
      'email': responsavel.email,
      'celular': responsavel.celular,
    });
  }
}
