import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/features/climate_and_rain/domain/entities/climate_charts_filter_entity.dart';

class ClimateChartsFilterRequestModel {
  const ClimateChartsFilterRequestModel._(this.data);

  final Map<String, dynamic> data;

  factory ClimateChartsFilterRequestModel.fromEntity(
    ClimateChartsFilterEntity filter,
  ) {
    return ClimateChartsFilterRequestModel._({
      'token': WSConstantes.token,
      'app_users_id': filter.appUsersId,
    });
  }
}
