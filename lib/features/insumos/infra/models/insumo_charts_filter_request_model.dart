import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/core/storage/sub_user_payload.dart';
import 'package:costeira/features/insumos/domain/entities/insumos.dart';

class InsumoChartsFilterRequestModel {
  const InsumoChartsFilterRequestModel._(this.data);

  final Map<String, dynamic> data;

  factory InsumoChartsFilterRequestModel.fromEntity(
    InsumoChartsFilterEntity filter,
  ) {
    return InsumoChartsFilterRequestModel._(
      withSubUser({
        'token': WSConstantes.token,
        'app_users_id': filter.appUsersId,
        'app_fazendas_id': filter.appFazendasId,
        'mes_ano': filter.mesAno,
      }..removeWhere((key, value) => value == null)),
    );
  }
}
