import 'package:costeira/features/animals/domain/entities/animal_reference_entity.dart';

class AnimalCategoryEntity extends AnimalReferenceEntity {
  const AnimalCategoryEntity({
    required super.id,
    required super.nome,
    required this.sexo,
  });

  final int sexo;
}
