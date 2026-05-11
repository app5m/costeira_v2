import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/entities/manejo.dart';

class ManejoUpsertRequestModel {
  const ManejoUpsertRequestModel._(this.data);

  final Map<String, dynamic> data;

  factory ManejoUpsertRequestModel.fromEntity(ManejoUpsertEntity manejo) {
    return ManejoUpsertRequestModel._(
      {
        'token': WSConstantes.token,
        'id': manejo.id,
        'app_users_id': manejo.appUsersId,
        'app_potreiros_id': manejo.appPotreirosId,
        'tipo_manejo': manejo.tipoManejo.trim().toLowerCase(),
        'data_manejo': manejo.dataManejo,
        'quantidade': _formatQuantidade(manejo.quantidade),
      }..removeWhere((key, value) => value == null),
    );
  }
}

num _formatQuantidade(double value) {
  if (value % 1 == 0) {
    return value.toInt();
  }
  return value;
}
