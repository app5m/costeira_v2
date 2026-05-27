import 'package:costeira/features/movimentacoes/domain/entities/aborto_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/abigeato_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/compra_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/consumo_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/morte_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/nascimento_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/troca_categoria_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/transferencia_entity.dart';
import 'package:costeira/features/movimentacoes/vendas/domain/entities/venda_entity.dart';

class MovimentacoesListEntity {
  const MovimentacoesListEntity({
    required this.rows,
    required this.compras,
    this.vendas = const [],
    this.mortes = const [],
    this.nascimentos = const [],
    this.trocaCategoria = const [],
    this.abigeatos = const [],
    this.abortos = const [],
    this.consumos = const [],
    this.transferencias = const [],
  });

  final int rows;
  final List<CompraEntity> compras;
  final List<VendaEntity> vendas;
  final List<MorteEntity> mortes;
  final List<NascimentoEntity> nascimentos;
  final List<TrocaCategoriaEntity> trocaCategoria;
  final List<AbigeatoEntity> abigeatos;
  final List<AbortoEntity> abortos;
  final List<ConsumoEntity> consumos;
  final List<TransferenciaEntity> transferencias;
}
