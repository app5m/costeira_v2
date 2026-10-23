import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/core/storage/sub_user_payload.dart';
import 'package:costeira/features/movimentacoes/abigeatos/domain/entities/delete_abigeato_entity.dart';

class DeleteAbigeatoRequestModel {
  const DeleteAbigeatoRequestModel._(this.data);

  final Map<String, dynamic> data;

  factory DeleteAbigeatoRequestModel.fromEntity(DeleteAbigeatoEntity entity) {
    return DeleteAbigeatoRequestModel._(
      withSubUser({
        'token': WSConstantes.token,
        'app_users_id': entity.appUsersId,
        'id': entity.id,
      }),
    );
  }
}
