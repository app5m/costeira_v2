import 'package:costeira/features/movimentacoes/domain/entities/abigeato_entity.dart';

class AbigeatosListEntity {
  const AbigeatosListEntity({required this.rows, required this.data});

  final int rows;
  final List<AbigeatoEntity> data;
}
