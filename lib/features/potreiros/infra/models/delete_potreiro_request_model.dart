import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/features/potreiros/domain/entities/delete_potreiro_entity.dart';

class DeletePotreiroRequestModel {
  const DeletePotreiroRequestModel._(this.data);

  final Map<String, dynamic> data;

  factory DeletePotreiroRequestModel.fromEntity(DeletePotreiroEntity entity) {
    return DeletePotreiroRequestModel._({
      'token': WSConstantes.token,
      'app_users_id': entity.appUsersId,
      'id': entity.id,
    });
  }
}
