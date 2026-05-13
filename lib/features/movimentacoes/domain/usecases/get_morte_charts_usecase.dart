import 'package:costeira/features/movimentacoes/domain/entities/morte_charts_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/movimentacao_charts_filter_entity.dart';
import 'package:costeira/features/movimentacoes/domain/repository/movimentacoes_datasource.dart';

class GetMorteChartsUsecase {
  const GetMorteChartsUsecase(this._datasource);

  final MovimentacoesDatasource _datasource;

  Future<MorteChartsEntity> call(MovimentacaoChartsFilterEntity filter) {
    return _datasource.getMorteCharts(filter);
  }
}
