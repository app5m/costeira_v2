import 'package:costeira/features/movimentacoes/domain/entities/movimentacao_filter_entity.dart';
import 'package:costeira/features/movimentacoes/domain/repository/movimentacoes_datasource.dart';
import 'package:costeira/features/movimentacoes/transferencias/domain/entities/transferencia_fazenda_list_item.dart';

class TransferenciasFazendaBuckets {
  const TransferenciasFazendaBuckets({
    required this.recebidas,
    required this.enviadas,
  });

  final List<TransferenciaFazendaListItem> recebidas;
  final List<TransferenciaFazendaListItem> enviadas;
}

class GetTransferenciasFazendaUsecase {
  const GetTransferenciasFazendaUsecase(this._datasource);

  final MovimentacoesDatasource _datasource;

  Future<TransferenciasFazendaBuckets> call(
    MovimentacaoFilterEntity filter,
  ) async {
    final result = await _datasource.getMovimentacoes(filter);
    return TransferenciasFazendaBuckets(
      recebidas: result.transferenciasRecebidas,
      enviadas: result.transferenciasEnviadas,
    );
  }
}
