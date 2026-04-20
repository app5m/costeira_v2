import 'package:costeira/features/animals/domain/entities/animal_category_entity.dart';

class AnimalCategoryModel extends AnimalCategoryEntity {
  const AnimalCategoryModel({
    required super.id,
    required super.nome,
    required super.sexo,
  });

  factory AnimalCategoryModel.fromJson(Map<String, dynamic> json) {
    return AnimalCategoryModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      nome: json['nome']?.toString().trim() ?? '',
      sexo: int.tryParse(json['sexo']?.toString() ?? '') ?? 0,
    );
  }
}
