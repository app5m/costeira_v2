import 'package:costeira/features/movimentacoes/domain/entities/consumos_list_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/movimentacao_filter_entity.dart';
import 'package:costeira/features/movimentacoes/domain/repository/movimentacoes_datasource.dart';

class GetConsumosUsecase {
  const GetConsumosUsecase(this._datasource);

  final MovimentacoesDatasource _datasource;

  Future<ConsumosListEntity> call(MovimentacaoFilterEntity filter) async {
    final result = await _datasource.getMovimentacoes(filter);
    return ConsumosListEntity(rows: result.rows, data: result.consumos);
  }
}
