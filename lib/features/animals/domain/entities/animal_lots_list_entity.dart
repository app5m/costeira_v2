import 'package:costeira/features/animals/domain/entities/animal_lot_entity.dart';

class AnimalLotsListEntity {
  const AnimalLotsListEntity({required this.rows, required this.data});

  final int rows;
  final List<AnimalLotEntity> data;
}
