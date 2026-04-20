import 'package:costeira/features/animals/domain/entities/animal_lots_list_entity.dart';
import 'package:costeira/features/animals/infra/models/animal_lot_model.dart';

class AnimalLotsListResponseModel extends AnimalLotsListEntity {
  const AnimalLotsListResponseModel({required super.rows, required super.data});

  factory AnimalLotsListResponseModel.fromJson(Map<String, dynamic> json) {
    final items = (json['data'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((item) => AnimalLotModel.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);

    return AnimalLotsListResponseModel(
      rows: int.tryParse(json['rows']?.toString() ?? '') ?? items.length,
      data: items,
    );
  }
}
