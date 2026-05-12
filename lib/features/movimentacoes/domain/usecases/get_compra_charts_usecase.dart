import 'package:costeira/features/movimentacoes/domain/entities/compra_charts_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/movimentacao_charts_filter_entity.dart';
import 'package:costeira/features/movimentacoes/domain/repository/movimentacoes_datasource.dart';

class GetCompraChartsUsecase {
  const GetCompraChartsUsecase(this._datasource);

  final MovimentacoesDatasource _datasource;

  Future<CompraChartsEntity> call(MovimentacaoChartsFilterEntity filter) {
    return _datasource.getCompraCharts(filter);
  }
}
