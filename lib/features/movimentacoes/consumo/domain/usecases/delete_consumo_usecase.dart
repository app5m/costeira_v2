import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/features/movimentacoes/consumo/domain/entities/delete_consumo_entity.dart';
import 'package:costeira/features/movimentacoes/consumo/domain/repository/consumos_datasource.dart';

class DeleteConsumoUsecase {
  const DeleteConsumoUsecase(this._datasource);

  final ConsumosDatasource _datasource;

  Future<ApiMessage> call(DeleteConsumoEntity consumo) {
    return _datasource.deleteConsumo(consumo);
  }
}
