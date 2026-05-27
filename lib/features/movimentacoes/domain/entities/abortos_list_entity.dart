import 'package:costeira/features/movimentacoes/domain/entities/aborto_entity.dart';

class AbortosListEntity {
  const AbortosListEntity({required this.rows, required this.data});

  final int rows;
  final List<AbortoEntity> data;
}
