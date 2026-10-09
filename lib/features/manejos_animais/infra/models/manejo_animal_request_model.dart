import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/core/storage/sub_user_payload.dart';

class ManejoAnimalRequestModel {
  const ManejoAnimalRequestModel._(this.data);

  final Map<String, dynamic> data;

  factory ManejoAnimalRequestModel.create({
    required int appUsersId,
    required int appFazendasId,
    required Map<String, dynamic> fields,
  }) {
    return ManejoAnimalRequestModel._(
      withSubUser({
        'token': WSConstantes.token,
        'app_users_id': appUsersId,
        'app_fazendas_id': appFazendasId,
        ...fields,
      }..removeWhere((key, value) => value == null)),
    );
  }
}
