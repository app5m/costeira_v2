import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/features/movimentacoes/nascimento/domain/entities/delete_nascimento_entity.dart';

class DeleteNascimentoRequestModel {
  const DeleteNascimentoRequestModel._(this.data);

  final Map<String, dynamic> data;

  factory DeleteNascimentoRequestModel.fromEntity(
    DeleteNascimentoEntity entity,
  ) {
    return DeleteNascimentoRequestModel._({
      'token': WSConstantes.token,
      'app_users_id': entity.appUsersId,
      'id': entity.id,
    });
  }
}
