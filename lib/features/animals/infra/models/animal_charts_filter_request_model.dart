import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/features/animals/domain/entities/animal_charts_filter_entity.dart';

class AnimalChartsFilterRequestModel {
  const AnimalChartsFilterRequestModel._(this.data);

  final Map<String, dynamic> data;

  factory AnimalChartsFilterRequestModel.fromEntity(
    AnimalChartsFilterEntity filter,
  ) {
    return AnimalChartsFilterRequestModel._({
      'token': WSConstantes.token,
      'app_users_id': filter.appUsersId,
    });
  }
}
