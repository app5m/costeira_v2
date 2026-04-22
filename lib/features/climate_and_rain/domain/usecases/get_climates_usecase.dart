import 'package:costeira/features/climate_and_rain/domain/entities/climate_filter_entity.dart';
import 'package:costeira/features/climate_and_rain/domain/entities/climate_list_entity.dart';
import 'package:costeira/features/climate_and_rain/domain/repository/climate_datasource.dart';

class GetClimatesUsecase {
  const GetClimatesUsecase(this._datasource);

  final ClimateDatasource _datasource;

  Future<ClimateListEntity> call(ClimateFilterEntity filter) {
    return _datasource.getClimates(filter);
  }
}
