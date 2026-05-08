import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/entities/manejo.dart';

class ManejoChartsFilterRequestModel {
  const ManejoChartsFilterRequestModel._(this.data);

  final Map<String, dynamic> data;

  factory ManejoChartsFilterRequestModel.fromEntity(
    ManejoChartsFilterEntity filter,
  ) {
    return ManejoChartsFilterRequestModel._({
      'token': WSConstantes.token,
      'app_users_id': filter.appUsersId,
      'mes_ano': filter.mesAno,
    });
  }
}
