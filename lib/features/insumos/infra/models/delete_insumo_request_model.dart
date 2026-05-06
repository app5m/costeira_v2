import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/features/insumos/domain/entities/insumos.dart';

class DeleteInsumoRequestModel {
  const DeleteInsumoRequestModel._(this.data);

  final Map<String, dynamic> data;

  factory DeleteInsumoRequestModel.fromEntity(DeleteInsumoEntity insumo) {
    return DeleteInsumoRequestModel._({
      'token': WSConstantes.token,
      'app_users_id': insumo.appUsersId,
      'id': insumo.id,
    });
  }
}
