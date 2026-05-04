import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/features/tasks/domain/entities/task_upsert_entity.dart';

class TaskUpsertRequestDto {
  const TaskUpsertRequestDto._(this.data);

  final Map<String, dynamic> data;

  factory TaskUpsertRequestDto.fromEntity(TaskUpsertEntity task) {
    return TaskUpsertRequestDto._({
      'token': WSConstantes.token,
      'app_users_id': task.appUsersId,
      if (task.id != null) 'id': task.id,
      if (task.responsavelId != null)
        'app_tarefas_responsaveis_id': task.responsavelId,
      'tipo': task.tipo,
      'descricao': task.descricao,
      'obs': task.obs,
      'urgencia': task.urgencia,
      'datas': task.datas,
    });
  }
}
