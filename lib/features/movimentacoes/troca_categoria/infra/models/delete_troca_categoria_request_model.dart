import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/features/movimentacoes/troca_categoria/domain/entities/delete_troca_categoria_entity.dart';

class DeleteTrocaCategoriaRequestModel {
  const DeleteTrocaCategoriaRequestModel._(this.data);

  final Map<String, dynamic> data;

  factory DeleteTrocaCategoriaRequestModel.fromEntity(
    DeleteTrocaCategoriaEntity entity,
  ) {
    return DeleteTrocaCategoriaRequestModel._({
      'token': WSConstantes.token,
      'app_users_id': entity.appUsersId,
      'id': entity.id,
    });
  }
}
