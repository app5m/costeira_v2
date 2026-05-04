import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/features/tasks/domain/entities/task_status_entity.dart';

class TaskStatusRequestDto {
  const TaskStatusRequestDto._(this.data);

  final Map<String, dynamic> data;

  factory TaskStatusRequestDto.fromEntity(TaskStatusEntity task) {
    return TaskStatusRequestDto._({
      'token': WSConstantes.token,
      'app_users_id': task.appUsersId,
      'id': task.id,
    });
  }
}
