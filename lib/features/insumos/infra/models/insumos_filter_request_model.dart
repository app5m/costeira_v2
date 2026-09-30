import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/core/storage/sub_user_payload.dart';
import 'package:costeira/features/insumos/domain/entities/insumos.dart';

class InsumosFilterRequestModel {
  const InsumosFilterRequestModel._(this.data);

  final Map<String, dynamic> data;

  factory InsumosFilterRequestModel.fromEntity(InsumosFilterEntity filter) {
    return InsumosFilterRequestModel._(
      withSubUser({
        'token': WSConstantes.token,
        'app_users_id': filter.appUsersId,
        'app_fazendas_id': filter.appFazendasId,
        'id': filter.id,
        'tipo_insumo': filter.tipoInsumo,
      }..removeWhere((key, value) => value == null)),
    );
  }
}
