import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/features/movimentacoes/vendas/domain/entities/delete_venda_entity.dart';
import 'package:costeira/features/movimentacoes/vendas/domain/repository/vendas_datasource.dart';

class DeleteVendaUsecase {
  const DeleteVendaUsecase(this._datasource);

  final VendasDatasource _datasource;

  Future<ApiMessage> call(DeleteVendaEntity venda) {
    return _datasource.deleteVenda(venda);
  }
}
