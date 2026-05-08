import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/entities/suplemento.dart';

class SuplementoUpsertRequestModel {
  const SuplementoUpsertRequestModel._(this.data);

  final Map<String, dynamic> data;

  factory SuplementoUpsertRequestModel.fromEntity(
    SuplementoUpsertEntity suplemento,
  ) {
    return SuplementoUpsertRequestModel._(
      {
        'token': WSConstantes.token,
        'id': suplemento.id,
        'app_users_id': suplemento.appUsersId,
        'app_potreiros_id': suplemento.appPotreirosId,
        'app_animais_lotes_id': suplemento.appAnimaisLotesId,
        'app_estoques_insumos_id': suplemento.appEstoquesInsumosId,
        'data_postagem': suplemento.dataPostagem,
        'quantidade': suplemento.quantidade,
      }..removeWhere((key, value) => value == null),
    );
  }
}
