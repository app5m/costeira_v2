import 'package:costeira/features/climate_and_rain/domain/entities/climate_list_entity.dart';
import 'package:costeira/features/climate_and_rain/infra/models/climate_model.dart';

class ClimateListResponseModel extends ClimateListEntity {
  const ClimateListResponseModel({required super.rows, required super.data});

  factory ClimateListResponseModel.fromJson(Map<String, dynamic> json) {
    final items = (json['data'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((item) => ClimateModel.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);

    return ClimateListResponseModel(
      rows: int.tryParse(json['rows']?.toString() ?? '') ?? items.length,
      data: items,
    );
  }
}
