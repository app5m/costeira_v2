import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/entities/suplemento.dart';

class DeleteSuplementoRequestModel {
  const DeleteSuplementoRequestModel._(this.data);

  final Map<String, dynamic> data;

  factory DeleteSuplementoRequestModel.fromEntity(
    DeleteSuplementoEntity suplemento,
  ) {
    return DeleteSuplementoRequestModel._({
      'token': WSConstantes.token,
      'app_users_id': suplemento.appUsersId,
      'id': suplemento.id,
    });
  }
}
