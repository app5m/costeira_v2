import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/core/storage/sub_user_payload.dart';
import 'package:costeira/features/movimentacoes/nascimento/domain/entities/nascimento_upsert_entity.dart';

class NascimentoUpsertRequestModel {
  const NascimentoUpsertRequestModel._(this.data);

  final Map<String, dynamic> data;

  factory NascimentoUpsertRequestModel.create(
    NascimentoUpsertEntity nascimento,
  ) {
    return NascimentoUpsertRequestModel._(
      withSubUser(
        {
          'token': WSConstantes.token,
          'app_users_id': nascimento.appUsersId,
          'app_fazendas_id': nascimento.appFazendasId,
          'sexo': nascimento.sexo,
          'id_animal_mae': nascimento.idAnimalMae,
          'brinco_cria': nascimento.brincoCria,
          'data': nascimento.data,
          'peso_total': nascimento.pesoTotal,
          'obs': nascimento.obs,
          'app_potreiros_id': nascimento.appPotreirosId,
          'app_animais_lotes_id': nascimento.appAnimaisLotesId,
        }..removeWhere((key, value) => value == null),
      ),
    );
  }

  factory NascimentoUpsertRequestModel.update(
    NascimentoUpsertEntity nascimento,
  ) {
    return NascimentoUpsertRequestModel._(
      withSubUser(
        {
          'token': WSConstantes.token,
          'app_users_id': nascimento.appUsersId,
          'app_fazendas_id': nascimento.appFazendasId,
          'id': nascimento.id,
          'app_potreiros_id': nascimento.appPotreirosId,
          'app_animais_lotes_id': nascimento.appAnimaisLotesId,
          'data': nascimento.data,
          'peso_total': nascimento.pesoTotal,
          'obs': nascimento.obs,
        }..removeWhere((key, value) => value == null),
      ),
    );
  }
}
