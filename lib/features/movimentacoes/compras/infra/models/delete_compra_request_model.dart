import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/features/movimentacoes/compras/domain/entities/delete_compra_entity.dart';

class DeleteCompraRequestModel {
  const DeleteCompraRequestModel._(this.data);

  final Map<String, dynamic> data;

  factory DeleteCompraRequestModel.fromEntity(DeleteCompraEntity entity) {
    return DeleteCompraRequestModel._({
      'token': WSConstantes.token,
      'app_users_id': entity.appUsersId,
      'id': entity.id,
    });
  }
}
