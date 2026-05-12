import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/features/movimentacoes/compras/domain/entities/delete_compra_entity.dart';
import 'package:costeira/features/movimentacoes/compras/domain/repository/compras_datasource.dart';

class DeleteCompraUsecase {
  const DeleteCompraUsecase(this._datasource);

  final ComprasDatasource _datasource;

  Future<ApiMessage> call(DeleteCompraEntity compra) {
    return _datasource.deleteCompra(compra);
  }
}
