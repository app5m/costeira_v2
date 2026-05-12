import 'package:costeira/features/movimentacoes/domain/entities/compra_entity.dart';

class MovimentacoesListEntity {
  const MovimentacoesListEntity({
    required this.rows,
    required this.compras,
    this.vendas = const [],
    this.mortes = const [],
  });

  final int rows;
  final List<CompraEntity> compras;
  final List<dynamic> vendas;
  final List<dynamic> mortes;
}
