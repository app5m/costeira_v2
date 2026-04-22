import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/features/climate_and_rain/domain/entities/climate_filter_entity.dart';

class ClimateFilterRequestModel {
  const ClimateFilterRequestModel._(this.data);

  final Map<String, dynamic> data;

  factory ClimateFilterRequestModel.fromEntity(ClimateFilterEntity filter) {
    return ClimateFilterRequestModel._({
      'token': WSConstantes.token,
      'app_users_id': filter.appUsersId,
      if (filter.id != null) 'id': filter.id,
      if ((filter.dataIn ?? '').trim().isNotEmpty) 'data_in': filter.dataIn,
      if ((filter.dataOut ?? '').trim().isNotEmpty) 'data_out': filter.dataOut,
    });
  }
}
