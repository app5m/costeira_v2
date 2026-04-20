import 'package:costeira/features/animals/domain/entities/animal_reference_entity.dart';

class AnimalReferenceModel extends AnimalReferenceEntity {
  const AnimalReferenceModel({required super.id, required super.nome});

  factory AnimalReferenceModel.fromJson(Map<String, dynamic> json) {
    return AnimalReferenceModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      nome: json['nome']?.toString().trim() ?? '',
    );
  }
}
