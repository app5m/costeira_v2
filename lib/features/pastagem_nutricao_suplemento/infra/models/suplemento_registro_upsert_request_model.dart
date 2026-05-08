import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/entities/suplemento.dart';

class SuplementoRegistroUpsertRequestModel {
  const SuplementoRegistroUpsertRequestModel._(this.data);

  final Map<String, dynamic> data;

  factory SuplementoRegistroUpsertRequestModel.fromEntity(
    SuplementoRegistroUpsertEntity registro,
  ) {
    return SuplementoRegistroUpsertRequestModel._(
      {
        'token': WSConstantes.token,
        'id': registro.id,
        'app_users_id': registro.appUsersId,
        'app_suplementacao_id': registro.appSuplementacaoId,
        'tipo': registro.tipo,
        'data_restabastecimento': registro.dataRestabastecimento,
        'quantidade': registro.quantidade,
      }..removeWhere((key, value) => value == null),
    );
  }
}
