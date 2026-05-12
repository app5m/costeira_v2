import 'package:costeira/features/movimentacoes/domain/entities/compra_entity.dart';

class ComprasListEntity {
  const ComprasListEntity({required this.rows, required this.data});

  final int rows;
  final List<CompraEntity> data;
}
