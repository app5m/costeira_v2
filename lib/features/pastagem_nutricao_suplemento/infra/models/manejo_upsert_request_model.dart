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
        'tipo_manejo': manejo.tipoManejo,
        'data_manejo': manejo.dataManejo,
        'quantidade': manejo.quantidade,
      }..removeWhere((key, value) => value == null),
    );
  }
}
