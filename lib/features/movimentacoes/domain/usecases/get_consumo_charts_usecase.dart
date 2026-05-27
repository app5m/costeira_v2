import 'package:costeira/features/movimentacoes/domain/entities/consumo_charts_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/movimentacao_charts_filter_entity.dart';
import 'package:costeira/features/movimentacoes/domain/repository/movimentacoes_datasource.dart';

class GetConsumoChartsUsecase {
  const GetConsumoChartsUsecase(this._datasource);

  final MovimentacoesDatasource _datasource;

  Future<ConsumoChartsEntity> call(MovimentacaoChartsFilterEntity filter) {
    return _datasource.getConsumoCharts(filter);
  }
}
