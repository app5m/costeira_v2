import 'package:costeira/features/movimentacoes/domain/entities/compra_charts_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/movimentacao_charts_filter_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/movimentacao_filter_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/movimentacoes_list_entity.dart';

abstract interface class MovimentacoesDatasource {
  Future<MovimentacoesListEntity> getMovimentacoes(
    MovimentacaoFilterEntity filter,
  );
  Future<CompraChartsEntity> getCompraCharts(
    MovimentacaoChartsFilterEntity filter,
  );
}
