import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/entities/suplemento.dart';

class DeleteSuplementoRegistroRequestModel {
  const DeleteSuplementoRegistroRequestModel._(this.data);

  final Map<String, dynamic> data;

  factory DeleteSuplementoRegistroRequestModel.fromEntity(
    DeleteSuplementoRegistroEntity registro,
  ) {
    return DeleteSuplementoRegistroRequestModel._({
      'token': WSConstantes.token,
      'app_users_id': registro.appUsersId,
      'id': registro.id,
    });
  }
}
