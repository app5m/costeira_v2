import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/features/movimentacoes/consumo/domain/entities/consumo_upsert_entity.dart';
import 'package:costeira/features/movimentacoes/consumo/domain/repository/consumos_datasource.dart';

class CreateConsumoUsecase {
  const CreateConsumoUsecase(this._datasource);

  final ConsumosDatasource _datasource;

  Future<ApiMessage> call(ConsumoUpsertEntity consumo) {
    return _datasource.createConsumo(consumo);
  }
}
