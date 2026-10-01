import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/core/storage/sub_user_payload.dart';
import 'package:costeira/features/movimentacoes/vendas/domain/entities/delete_venda_entity.dart';

class DeleteVendaRequestModel {
  const DeleteVendaRequestModel._(this.data);

  final Map<String, dynamic> data;

  factory DeleteVendaRequestModel.fromEntity(DeleteVendaEntity entity) {
    return DeleteVendaRequestModel._(
      withSubUser({
        'token': WSConstantes.token,
        'app_users_id': entity.appUsersId,
        'id': entity.id,
      }),
    );
  }
}
