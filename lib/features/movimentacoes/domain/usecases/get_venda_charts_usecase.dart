import 'package:costeira/features/movimentacoes/domain/entities/movimentacao_charts_filter_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/venda_charts_entity.dart';
import 'package:costeira/features/movimentacoes/domain/repository/movimentacoes_datasource.dart';

class GetVendaChartsUsecase {
  const GetVendaChartsUsecase(this._datasource);

  final MovimentacoesDatasource _datasource;

  Future<VendaChartsEntity> call(MovimentacaoChartsFilterEntity filter) {
    return _datasource.getVendaCharts(filter);
  }
}
