import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/core/storage/sub_user_payload.dart';
import 'package:costeira/features/insumos/domain/entities/insumos.dart';

class InsumosTipoFilterRequestModel {
  const InsumosTipoFilterRequestModel._(this.data);

  final Map<String, dynamic> data;

  factory InsumosTipoFilterRequestModel.fromEntity(
    InsumosTipoFilterEntity filter,
  ) {
    return InsumosTipoFilterRequestModel._(
      withSubUser({
        'token': WSConstantes.token,
        'app_users_id': filter.appUsersId,
        'app_fazendas_id': filter.appFazendasId,
        'tipo': filter.tipo,
        'nome': filter.nome,
      }..removeWhere((key, value) => value == null)),
    );
  }
}
