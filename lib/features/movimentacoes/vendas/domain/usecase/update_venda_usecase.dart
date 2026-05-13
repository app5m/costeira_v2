import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/features/movimentacoes/vendas/domain/entities/venda_upsert_entity.dart';
import 'package:costeira/features/movimentacoes/vendas/domain/repository/vendas_datasource.dart';

class UpdateVendaUsecase {
  const UpdateVendaUsecase(this._datasource);

  final VendasDatasource _datasource;

  Future<ApiMessage> call(VendaUpsertEntity venda) {
    return _datasource.updateVenda(venda);
  }
}
