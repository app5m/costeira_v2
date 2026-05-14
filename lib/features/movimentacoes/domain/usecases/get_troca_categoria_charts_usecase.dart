import 'package:costeira/features/movimentacoes/domain/entities/movimentacao_charts_filter_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/troca_categoria_charts_entity.dart';
import 'package:costeira/features/movimentacoes/domain/repository/movimentacoes_datasource.dart';

class GetTrocaCategoriaChartsUsecase {
  const GetTrocaCategoriaChartsUsecase(this._datasource);

  final MovimentacoesDatasource _datasource;

  Future<TrocaCategoriaChartsEntity> call(
    MovimentacaoChartsFilterEntity filter,
  ) {
    return _datasource.getTrocaCategoriaCharts(filter);
  }
}
