import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/core/storage/sub_user_payload.dart';
import 'package:costeira/features/climate_and_rain/domain/entities/climate_upsert_entity.dart';

class ClimateUpsertRequestModel {
  const ClimateUpsertRequestModel._(this.data);

  final Map<String, dynamic> data;

  factory ClimateUpsertRequestModel.create(ClimateUpsertEntity climate) {
    return ClimateUpsertRequestModel._(withSubUser({
      'token': WSConstantes.token,
      'app_users_id': climate.appUsersId,
      'app_fazendas_id': climate.appFazendasId,
      'quantidade': climate.quantidade,
      'data_in': climate.dataIn,
      'data_out': climate.dataOut,
    }));
  }

  factory ClimateUpsertRequestModel.update(ClimateUpsertEntity climate) {
    return ClimateUpsertRequestModel._(withSubUser({
      'token': WSConstantes.token,
      'app_users_id': climate.appUsersId,
      'app_fazendas_id': climate.appFazendasId,
      'id': climate.id,
      'quantidade': climate.quantidade,
      'data_in': climate.dataIn,
      'data_out': climate.dataOut,
    }));
  }
}
