import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/features/tasks/domain/entities/delete_task_responsavel_entity.dart';

class DeleteTaskResponsavelRequestDto {
  const DeleteTaskResponsavelRequestDto._(this.data);

  final Map<String, dynamic> data;

  factory DeleteTaskResponsavelRequestDto.fromEntity(
    DeleteTaskResponsavelEntity responsavel,
  ) {
    return DeleteTaskResponsavelRequestDto._({
      'token': WSConstantes.token,
      'app_users_id': responsavel.appUsersId,
      'id': responsavel.id,
    });
  }
}
