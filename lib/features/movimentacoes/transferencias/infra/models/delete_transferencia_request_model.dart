import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/features/movimentacoes/transferencias/domain/entities/delete_transferencia_entity.dart';

class DeleteTransferenciaRequestModel {
  const DeleteTransferenciaRequestModel._(this.data);

  final Map<String, dynamic> data;

  factory DeleteTransferenciaRequestModel.fromEntity(
    DeleteTransferenciaEntity entity,
  ) {
    return DeleteTransferenciaRequestModel._({
      'token': WSConstantes.token,
      'app_users_id': entity.appUsersId,
      'id': entity.id,
    });
  }
}
