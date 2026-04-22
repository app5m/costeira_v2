import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/features/potreiros/domain/entities/potreiro_charts_filter_entity.dart';

class PotreiroChartsFilterRequestModel {
  const PotreiroChartsFilterRequestModel._(this.data);

  final Map<String, dynamic> data;

  factory PotreiroChartsFilterRequestModel.fromEntity(
    PotreiroChartsFilterEntity filter,
  ) {
    return PotreiroChartsFilterRequestModel._({
      'token': WSConstantes.token,
      'app_users_id': filter.appUsersId,
    });
  }
}
