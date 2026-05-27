import 'package:costeira/features/movimentacoes/domain/entities/abortos_list_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/movimentacao_filter_entity.dart';
import 'package:costeira/features/movimentacoes/domain/repository/movimentacoes_datasource.dart';

class GetAbortosUsecase {
  const GetAbortosUsecase(this._datasource);

  final MovimentacoesDatasource _datasource;

  Future<AbortosListEntity> call(MovimentacaoFilterEntity filter) async {
    final result = await _datasource.getMovimentacoes(filter);
    return AbortosListEntity(rows: result.rows, data: result.abortos);
  }
}
