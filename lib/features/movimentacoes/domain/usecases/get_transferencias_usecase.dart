import 'package:costeira/features/movimentacoes/domain/entities/movimentacao_filter_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/transferencias_list_entity.dart';
import 'package:costeira/features/movimentacoes/domain/repository/movimentacoes_datasource.dart';

class GetTransferenciasUsecase {
  const GetTransferenciasUsecase(this._datasource);

  final MovimentacoesDatasource _datasource;

  Future<TransferenciasListEntity> call(MovimentacaoFilterEntity filter) async {
    final result = await _datasource.getMovimentacoes(filter);
    return TransferenciasListEntity(
      rows: result.rows,
      data: result.transferencias,
    );
  }
}
