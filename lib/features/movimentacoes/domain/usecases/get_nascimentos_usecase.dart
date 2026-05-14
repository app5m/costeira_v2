import 'package:costeira/features/movimentacoes/domain/entities/movimentacao_filter_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/nascimentos_list_entity.dart';
import 'package:costeira/features/movimentacoes/domain/repository/movimentacoes_datasource.dart';

class GetNascimentosUsecase {
  const GetNascimentosUsecase(this._datasource);

  final MovimentacoesDatasource _datasource;

  Future<NascimentosListEntity> call(MovimentacaoFilterEntity filter) async {
    final result = await _datasource.getMovimentacoes(filter);
    return NascimentosListEntity(rows: result.rows, data: result.nascimentos);
  }
}
