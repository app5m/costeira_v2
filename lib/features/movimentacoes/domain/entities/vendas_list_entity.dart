import 'package:costeira/features/movimentacoes/vendas/domain/entities/venda_entity.dart';

class VendasListEntity {
  const VendasListEntity({required this.rows, required this.data});

  final int rows;
  final List<VendaEntity> data;
}
