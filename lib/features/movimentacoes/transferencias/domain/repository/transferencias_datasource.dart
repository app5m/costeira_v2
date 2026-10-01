import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/features/movimentacoes/transferencias/domain/entities/delete_transferencia_entity.dart';
import 'package:costeira/features/movimentacoes/transferencias/domain/entities/transferencia_fazenda_upsert_entity.dart';
import 'package:costeira/features/movimentacoes/transferencias/domain/entities/transferencia_upsert_entity.dart';

abstract class TransferenciasDatasource {
  Future<ApiMessage> createTransferencia(
    TransferenciaUpsertEntity transferencia,
  );

  Future<ApiMessage> updateTransferencia(
    TransferenciaUpsertEntity transferencia,
  );

  Future<ApiMessage> deleteTransferencia(
    DeleteTransferenciaEntity transferencia,
  );

  Future<ApiMessage> createTransferenciaFazenda(
    TransferenciaFazendaUpsertEntity transferencia,
  );

  Future<ApiMessage> updateTransferenciaFazenda(
    TransferenciaFazendaUpsertEntity transferencia,
  );

  Future<ApiMessage> aceitarTransferenciaFazenda({
    required int id,
    required int statusTransferencia,
  });
}
