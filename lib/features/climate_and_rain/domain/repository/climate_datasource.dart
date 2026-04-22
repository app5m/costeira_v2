import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/features/climate_and_rain/domain/entities/climate_charts_entity.dart';
import 'package:costeira/features/climate_and_rain/domain/entities/climate_charts_filter_entity.dart';
import 'package:costeira/features/climate_and_rain/domain/entities/climate_filter_entity.dart';
import 'package:costeira/features/climate_and_rain/domain/entities/climate_list_entity.dart';
import 'package:costeira/features/climate_and_rain/domain/entities/climate_upsert_entity.dart';
import 'package:costeira/features/climate_and_rain/domain/entities/delete_climate_entity.dart';

abstract interface class ClimateDatasource {
  Future<ClimateListEntity> getClimates(ClimateFilterEntity filter);
  Future<ApiMessage> createClimate(ClimateUpsertEntity climate);
  Future<ApiMessage> updateClimate(ClimateUpsertEntity climate);
  Future<ApiMessage> deleteClimate(DeleteClimateEntity climate);
  Future<ClimateChartsEntity> getClimateCharts(
    ClimateChartsFilterEntity filter,
  );
}
