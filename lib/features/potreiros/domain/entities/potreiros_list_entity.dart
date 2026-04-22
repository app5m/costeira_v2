import 'package:costeira/features/potreiros/domain/entities/potreiro_entity.dart';

class PotreirosListEntity {
  const PotreirosListEntity({required this.rows, required this.data});

  final int rows;
  final List<PotreiroEntity> data;
}
