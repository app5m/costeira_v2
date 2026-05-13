import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/features/movimentacoes/vendas/domain/entities/delete_venda_entity.dart';
import 'package:costeira/features/movimentacoes/vendas/domain/entities/venda_upsert_entity.dart';

abstract interface class VendasDatasource {
  Future<ApiMessage> createVenda(VendaUpsertEntity venda);
  Future<ApiMessage> updateVenda(VendaUpsertEntity venda);
  Future<ApiMessage> deleteVenda(DeleteVendaEntity venda);
}
