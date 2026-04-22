import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/features/climate_and_rain/domain/entities/delete_climate_entity.dart';

class DeleteClimateRequestModel {
  const DeleteClimateRequestModel._(this.data);

  final Map<String, dynamic> data;

  factory DeleteClimateRequestModel.fromEntity(DeleteClimateEntity climate) {
    return DeleteClimateRequestModel._({
      'token': WSConstantes.token,
      'app_users_id': climate.appUsersId,
      'id': climate.id,
    });
  }
}
