import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/entities/suplemento.dart';

class SuplementoChartsFilterRequestModel {
  const SuplementoChartsFilterRequestModel._(this.data);

  final Map<String, dynamic> data;

  factory SuplementoChartsFilterRequestModel.fromEntity(
    SuplementoChartsFilterEntity filter,
  ) {
    return SuplementoChartsFilterRequestModel._({
      'token': WSConstantes.token,
      'app_users_id': filter.appUsersId,
      'mes_ano': filter.mesAno,
    });
  }
}
