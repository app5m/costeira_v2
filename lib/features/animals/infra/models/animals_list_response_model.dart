import 'package:costeira/features/animals/domain/entities/animals_list_entity.dart';
import 'package:costeira/features/animals/infra/models/animal_model.dart';

class AnimalsListResponseModel extends AnimalsListEntity {
  const AnimalsListResponseModel({required super.rows, required super.data});

  factory AnimalsListResponseModel.fromJson(Map<String, dynamic> json) {
    final items = (json['data'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((item) => AnimalModel.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);

    return AnimalsListResponseModel(
      rows: int.tryParse(json['rows']?.toString() ?? '') ?? items.length,
      data: items,
    );
  }
}
