import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/entities/manejo_filter.dart';

class ManejoFilterRequestModel {
  const ManejoFilterRequestModel._(this.data);

  final Map<String, dynamic> data;

  factory ManejoFilterRequestModel.fromEntity(ManejoFilterEntity filter) {
    return ManejoFilterRequestModel._({
      'token': WSConstantes.token,
      'app_users_id': filter.appUsersId,
      'id': filter.id,
      'id_potreiro': filter.idPotreiro,
    });
  }
}
