import 'package:costeira/features/climate_and_rain/domain/entities/climate_charts_entity.dart';
import 'package:costeira/features/climate_and_rain/domain/entities/climate_charts_filter_entity.dart';
import 'package:costeira/features/climate_and_rain/domain/repository/climate_datasource.dart';

class GetClimateChartsUsecase {
  const GetClimateChartsUsecase(this._datasource);

  final ClimateDatasource _datasource;

  Future<ClimateChartsEntity> call(ClimateChartsFilterEntity filter) {
    return _datasource.getClimateCharts(filter);
  }
}
