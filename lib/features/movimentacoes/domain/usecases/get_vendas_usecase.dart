import 'package:costeira/features/movimentacoes/domain/entities/movimentacao_filter_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/vendas_list_entity.dart';
import 'package:costeira/features/movimentacoes/domain/repository/movimentacoes_datasource.dart';

class GetVendasUsecase {
  const GetVendasUsecase(this._datasource);

  final MovimentacoesDatasource _datasource;

  Future<VendasListEntity> call(MovimentacaoFilterEntity filter) async {
    final result = await _datasource.getMovimentacoes(filter);
    return VendasListEntity(rows: result.rows, data: result.vendas);
  }
}
