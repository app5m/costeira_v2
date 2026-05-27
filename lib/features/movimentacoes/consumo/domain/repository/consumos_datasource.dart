import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/features/movimentacoes/consumo/domain/entities/consumo_upsert_entity.dart';
import 'package:costeira/features/movimentacoes/consumo/domain/entities/delete_consumo_entity.dart';

abstract interface class ConsumosDatasource {
  Future<ApiMessage> createConsumo(ConsumoUpsertEntity consumo);
  Future<ApiMessage> updateConsumo(ConsumoUpsertEntity consumo);
  Future<ApiMessage> deleteConsumo(DeleteConsumoEntity consumo);
}
