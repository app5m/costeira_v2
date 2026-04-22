import 'package:costeira/features/climate_and_rain/domain/entities/climate_entity.dart';

class ClimateListEntity {
  const ClimateListEntity({required this.rows, required this.data});

  final int rows;
  final List<ClimateEntity> data;
}
