import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/features/movimentacoes/transferencias/domain/entities/delete_transferencia_entity.dart';
import 'package:costeira/features/movimentacoes/transferencias/domain/repository/transferencias_datasource.dart';

class DeleteTransferenciaUsecase {
  const DeleteTransferenciaUsecase(this._datasource);

  final TransferenciasDatasource _datasource;

  Future<ApiMessage> call(DeleteTransferenciaEntity transferencia) {
    return _datasource.deleteTransferencia(transferencia);
  }
}
