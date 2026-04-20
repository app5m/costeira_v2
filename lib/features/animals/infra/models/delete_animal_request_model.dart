import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/features/animals/domain/entities/delete_animal_entity.dart';

class DeleteAnimalRequestModel {
  const DeleteAnimalRequestModel._(this.data);

  final Map<String, dynamic> data;

  factory DeleteAnimalRequestModel.fromEntity(DeleteAnimalEntity entity) {
    return DeleteAnimalRequestModel._({
      'token': WSConstantes.token,
      'app_users_id': entity.appUsersId,
      'id': entity.id,
    });
  }
}
