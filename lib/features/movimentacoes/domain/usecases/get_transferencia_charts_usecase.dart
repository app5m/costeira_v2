import 'package:costeira/features/movimentacoes/domain/entities/movimentacao_charts_filter_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/transferencia_charts_entity.dart';
import 'package:costeira/features/movimentacoes/domain/repository/movimentacoes_datasource.dart';

class GetTransferenciaChartsUsecase {
  const GetTransferenciaChartsUsecase(this._datasource);

  final MovimentacoesDatasource _datasource;

  Future<TransferenciaChartsEntity> call(
    MovimentacaoChartsFilterEntity filter,
  ) {
    return _datasource.getTransferenciaCharts(filter);
  }
}
