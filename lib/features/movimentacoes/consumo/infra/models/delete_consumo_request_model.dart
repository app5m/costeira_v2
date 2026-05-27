import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/features/movimentacoes/consumo/domain/entities/delete_consumo_entity.dart';

class DeleteConsumoRequestModel {
  const DeleteConsumoRequestModel._(this.data);

  final Map<String, dynamic> data;

  factory DeleteConsumoRequestModel.fromEntity(DeleteConsumoEntity entity) {
    return DeleteConsumoRequestModel._({
      'token': WSConstantes.token,
      'app_users_id': entity.appUsersId,
      'id': entity.id,
    });
  }
}
