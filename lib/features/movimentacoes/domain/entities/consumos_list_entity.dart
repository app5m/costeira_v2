import 'package:costeira/features/movimentacoes/domain/entities/consumo_entity.dart';

class ConsumosListEntity {
  const ConsumosListEntity({required this.rows, required this.data});

  final int rows;
  final List<ConsumoEntity> data;
}
