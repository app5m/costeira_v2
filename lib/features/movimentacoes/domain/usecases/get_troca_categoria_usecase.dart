import 'package:costeira/features/movimentacoes/domain/entities/movimentacao_filter_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/troca_categoria_list_entity.dart';
import 'package:costeira/features/movimentacoes/domain/repository/movimentacoes_datasource.dart';

class GetTrocaCategoriaUsecase {
  const GetTrocaCategoriaUsecase(this._datasource);

  final MovimentacoesDatasource _datasource;

  Future<TrocaCategoriaListEntity> call(MovimentacaoFilterEntity filter) async {
    final result = await _datasource.getMovimentacoes(filter);
    return TrocaCategoriaListEntity(
      rows: result.rows,
      data: result.trocaCategoria,
    );
  }
}
