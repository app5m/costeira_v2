import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/core/storage/sub_user_payload.dart';
import 'package:costeira/features/movimentacoes/mortes/domain/entities/delete_morte_entity.dart';

class DeleteMorteRequestModel {
  const DeleteMorteRequestModel._(this.data);

  final Map<String, dynamic> data;

  factory DeleteMorteRequestModel.fromEntity(DeleteMorteEntity entity) {
    return DeleteMorteRequestModel._(
      withSubUser({
        'token': WSConstantes.token,
        'app_users_id': entity.appUsersId,
        'id': entity.id,
      }),
    );
  }
}
