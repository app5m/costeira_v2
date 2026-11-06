import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/core/storage/sub_user_payload.dart';
import 'package:costeira/features/climate_and_rain/domain/entities/delete_climate_entity.dart';

class DeleteClimateRequestModel {
  const DeleteClimateRequestModel._(this.data);

  final Map<String, dynamic> data;

  factory DeleteClimateRequestModel.fromEntity(DeleteClimateEntity climate) {
    return DeleteClimateRequestModel._(withSubUser({
      'token': WSConstantes.token,
      'app_users_id': climate.appUsersId,
      'app_fazendas_id': climate.appFazendasId,
      'id': climate.id,
    }));
  }
}