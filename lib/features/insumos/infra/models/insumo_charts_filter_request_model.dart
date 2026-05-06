import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/features/insumos/domain/entities/insumos.dart';

class InsumoChartsFilterRequestModel {
  const InsumoChartsFilterRequestModel._(this.data);

  final Map<String, dynamic> data;

  factory InsumoChartsFilterRequestModel.fromEntity(
    InsumoChartsFilterEntity filter,
  ) {
    return InsumoChartsFilterRequestModel._({
      'token': WSConstantes.token,
      'app_users_id': filter.appUsersId,
      'mes_ano': filter.mesAno,
    });
  }
}
