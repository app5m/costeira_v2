import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/entities/manejo.dart';

class DeleteManejoRequestModel {
  const DeleteManejoRequestModel._(this.data);

  final Map<String, dynamic> data;

  factory DeleteManejoRequestModel.fromEntity(DeleteManejoEntity manejo) {
    return DeleteManejoRequestModel._({
      'token': WSConstantes.token,
      'app_users_id': manejo.appUsersId,
      'id': manejo.id,
    });
  }
}
