import 'package:costeira/features/movimentacoes/domain/entities/aborto_charts_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/movimentacao_charts_filter_entity.dart';
import 'package:costeira/features/movimentacoes/domain/repository/movimentacoes_datasource.dart';

class GetAbortoChartsUsecase {
  const GetAbortoChartsUsecase(this._datasource);

  final MovimentacoesDatasource _datasource;

  Future<AbortoChartsEntity> call(MovimentacaoChartsFilterEntity filter) {
    return _datasource.getAbortoCharts(filter);
  }
}
