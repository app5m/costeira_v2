import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/features/movimentacoes/compras/domain/entities/compra_upsert_entity.dart';
import 'package:costeira/features/movimentacoes/compras/domain/entities/delete_compra_entity.dart';

abstract interface class ComprasDatasource {
  Future<ApiMessage> createCompra(CompraUpsertEntity compra);
  Future<ApiMessage> updateCompra(CompraUpsertEntity compra);
  Future<ApiMessage> deleteCompra(DeleteCompraEntity compra);
}
