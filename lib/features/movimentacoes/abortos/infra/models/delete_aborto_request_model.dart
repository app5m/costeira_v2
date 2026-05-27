import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/features/movimentacoes/abortos/domain/entities/delete_aborto_entity.dart';

class DeleteAbortoRequestModel {
  const DeleteAbortoRequestModel._(this.data);

  final Map<String, dynamic> data;

  factory DeleteAbortoRequestModel.fromEntity(DeleteAbortoEntity entity) {
    return DeleteAbortoRequestModel._({
      'token': WSConstantes.token,
      'app_users_id': entity.appUsersId,
      'id': entity.id,
    });
  }
}
