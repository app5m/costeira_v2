import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/features/climate_and_rain/domain/entities/climate_upsert_entity.dart';
import 'package:costeira/features/climate_and_rain/domain/repository/climate_datasource.dart';

class UpdateClimateUsecase {
  const UpdateClimateUsecase(this._datasource);

  final ClimateDatasource _datasource;

  Future<ApiMessage> call(ClimateUpsertEntity climate) {
    return _datasource.updateClimate(climate);
  }
}
