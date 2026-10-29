import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/core/storage/sub_user_payload.dart';
import 'package:costeira/features/tasks/domain/entities/delete_task_responsavel_entity.dart';

class DeleteTaskResponsavelRequestDto {
  const DeleteTaskResponsavelRequestDto._(this.data);

  final Map<String, dynamic> data;

  factory DeleteTaskResponsavelRequestDto.fromEntity(
    DeleteTaskResponsavelEntity responsavel,
  ) {
    return DeleteTaskResponsavelRequestDto._(withSubUser({
      'token': WSConstantes.token,
      'app_users_id': responsavel.appUsersId,
      'app_fazendas_id': responsavel.appFazendasId,
      'id': responsavel.id,
    }));
  }
}
