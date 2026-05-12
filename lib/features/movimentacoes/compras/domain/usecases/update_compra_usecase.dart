import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/features/movimentacoes/compras/domain/entities/compra_upsert_entity.dart';
import 'package:costeira/features/movimentacoes/compras/domain/repository/compras_datasource.dart';

class UpdateCompraUsecase {
  const UpdateCompraUsecase(this._datasource);

  final ComprasDatasource _datasource;

  Future<ApiMessage> call(CompraUpsertEntity compra) {
    return _datasource.updateCompra(compra);
  }
}
