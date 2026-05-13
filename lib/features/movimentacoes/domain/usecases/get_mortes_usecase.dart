import 'package:costeira/features/movimentacoes/domain/entities/mortes_list_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/movimentacao_filter_entity.dart';
import 'package:costeira/features/movimentacoes/domain/repository/movimentacoes_datasource.dart';

class GetMortesUsecase {
  const GetMortesUsecase(this._datasource);

  final MovimentacoesDatasource _datasource;

  Future<MortesListEntity> call(MovimentacaoFilterEntity filter) async {
    final result = await _datasource.getMovimentacoes(filter);
    return MortesListEntity(rows: result.rows, data: result.mortes);
  }
}
