import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/features/movimentacoes/transferencias/domain/entities/transferencia_upsert_entity.dart';
import 'package:costeira/features/movimentacoes/transferencias/domain/repository/transferencias_datasource.dart';

class CreateTransferenciaUsecase {
  const CreateTransferenciaUsecase(this._datasource);

  final TransferenciasDatasource _datasource;

  Future<ApiMessage> call(TransferenciaUpsertEntity transferencia) {
    return _datasource.createTransferencia(transferencia);
  }
}
