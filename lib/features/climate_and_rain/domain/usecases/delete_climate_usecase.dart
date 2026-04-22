import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/features/climate_and_rain/domain/entities/delete_climate_entity.dart';
import 'package:costeira/features/climate_and_rain/domain/repository/climate_datasource.dart';

class DeleteClimateUsecase {
  const DeleteClimateUsecase(this._datasource);

  final ClimateDatasource _datasource;

  Future<ApiMessage> call(DeleteClimateEntity climate) {
    return _datasource.deleteClimate(climate);
  }
}
