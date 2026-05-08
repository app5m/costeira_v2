import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/entities/suplemento_filter.dart';

class SuplementoFilterRequestModel {
  const SuplementoFilterRequestModel._(this.data);

  final Map<String, dynamic> data;

  factory SuplementoFilterRequestModel.fromEntity(
    SuplementoFilterEntity filter,
  ) {
    return SuplementoFilterRequestModel._(
      {
        'token': WSConstantes.token,
        'app_users_id': filter.appUsersId,
        'id': filter.id,
        'id_potreiro': filter.idPotreiro,
        'id_lote': filter.idLote,
        'id_produto': filter.idProduto,
      }..removeWhere((key, value) => value == null),
    );
  }
}
