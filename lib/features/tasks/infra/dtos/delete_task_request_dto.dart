import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/features/tasks/domain/entities/delete_task_entity.dart';

class DeleteTaskRequestDto {
  const DeleteTaskRequestDto._(this.data);

  final Map<String, dynamic> data;

  factory DeleteTaskRequestDto.fromEntity(DeleteTaskEntity task) {
    return DeleteTaskRequestDto._({
      'token': WSConstantes.token,
      'app_users_id': task.appUsersId,
      'id': task.id,
    });
  }
}
