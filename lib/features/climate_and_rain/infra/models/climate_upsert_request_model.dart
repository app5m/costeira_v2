import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/features/climate_and_rain/domain/entities/climate_upsert_entity.dart';

class ClimateUpsertRequestModel {
  const ClimateUpsertRequestModel._(this.data);

  final Map<String, dynamic> data;

  factory ClimateUpsertRequestModel.create(ClimateUpsertEntity climate) {
    return ClimateUpsertRequestModel._({
      'token': WSConstantes.token,
      'app_users_id': climate.appUsersId,
      'quantidade': climate.quantidade,
      'data_in': climate.dataIn,
      'data_out': climate.dataOut,
    });
  }

  factory ClimateUpsertRequestModel.update(ClimateUpsertEntity climate) {
    return ClimateUpsertRequestModel._({
      'token': WSConstantes.token,
      'app_users_id': climate.appUsersId,
      'id': climate.id,
      'quantidade': climate.quantidade,
      'data_in': climate.dataIn,
      'data_out': climate.dataOut,
    });
  }
}
