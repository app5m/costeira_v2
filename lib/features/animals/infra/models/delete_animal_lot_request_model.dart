import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/features/animals/domain/entities/delete_animal_lot_entity.dart';

class DeleteAnimalLotRequestModel {
  const DeleteAnimalLotRequestModel._(this.data);

  final Map<String, dynamic> data;

  factory DeleteAnimalLotRequestModel.fromEntity(DeleteAnimalLotEntity lot) {
    return DeleteAnimalLotRequestModel._({
      'token': WSConstantes.token,
      'app_users_id': lot.appUsersId,
      'id': lot.id,
    });
  }
}
