import 'package:costeira/features/movimentacoes/domain/entities/movimentacao_charts_filter_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/nascimento_charts_entity.dart';
import 'package:costeira/features/movimentacoes/domain/repository/movimentacoes_datasource.dart';

class GetNascimentoChartsUsecase {
  const GetNascimentoChartsUsecase(this._datasource);

  final MovimentacoesDatasource _datasource;

  Future<NascimentoChartsEntity> call(MovimentacaoChartsFilterEntity filter) {
    return _datasource.getNascimentoCharts(filter);
  }
}
