import 'package:costeira/features/movimentacoes/domain/entities/abigeato_charts_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/movimentacao_charts_filter_entity.dart';
import 'package:costeira/features/movimentacoes/domain/repository/movimentacoes_datasource.dart';

class GetAbigeatoChartsUsecase {
  const GetAbigeatoChartsUsecase(this._datasource);

  final MovimentacoesDatasource _datasource;

  Future<AbigeatoChartsEntity> call(MovimentacaoChartsFilterEntity filter) {
    return _datasource.getAbigeatoCharts(filter);
  }
}
