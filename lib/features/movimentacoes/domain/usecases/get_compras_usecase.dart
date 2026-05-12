import 'package:costeira/features/movimentacoes/domain/entities/compras_list_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/movimentacao_filter_entity.dart';
import 'package:costeira/features/movimentacoes/domain/repository/movimentacoes_datasource.dart';

class GetComprasUsecase {
  const GetComprasUsecase(this._datasource);

  final MovimentacoesDatasource _datasource;

  Future<ComprasListEntity> call(MovimentacaoFilterEntity filter) async {
    final result = await _datasource.getMovimentacoes(filter);
    return ComprasListEntity(rows: result.rows, data: result.compras);
  }
}
