import 'package:costeira/features/movimentacoes/domain/entities/abigeatos_list_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/movimentacao_filter_entity.dart';
import 'package:costeira/features/movimentacoes/domain/repository/movimentacoes_datasource.dart';

class GetAbigeatosUsecase {
  const GetAbigeatosUsecase(this._datasource);

  final MovimentacoesDatasource _datasource;

  Future<AbigeatosListEntity> call(MovimentacaoFilterEntity filter) async {
    final result = await _datasource.getMovimentacoes(filter);
    return AbigeatosListEntity(rows: result.rows, data: result.abigeatos);
  }
}
