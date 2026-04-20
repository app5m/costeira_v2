import 'package:costeira/features/animals/domain/entities/animal_entity.dart';

class AnimalsListEntity {
  const AnimalsListEntity({required this.rows, required this.data});

  final int rows;
  final List<AnimalEntity> data;
}
