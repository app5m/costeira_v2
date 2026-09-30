import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/core/storage/sub_user_payload.dart';
import 'package:costeira/features/movimentacoes/mortes/domain/entities/morte_upsert_animal_entity.dart';
import 'package:costeira/features/movimentacoes/mortes/domain/entities/morte_upsert_entity.dart';

class MorteUpsertRequestModel {
  const MorteUpsertRequestModel._(this.data);

  final Map<String, dynamic> data;

  factory MorteUpsertRequestModel.create(MorteUpsertEntity morte) {
    return MorteUpsertRequestModel._(
      withSubUser(
        {
          'token': WSConstantes.token,
          'app_users_id': morte.appUsersId,
          'app_fazendas_id': morte.appFazendasId,
          'id_categoria': morte.idCategoria,
          'data': morte.data,
          'obs': morte.obs,
          'animais': morte.animais.map(_animalToJson).toList(growable: false),
        }..removeWhere((key, value) => value == null),
      ),
    );
  }

  factory MorteUpsertRequestModel.update(MorteUpsertEntity morte) {
    return MorteUpsertRequestModel._(
      withSubUser(
        {
          'token': WSConstantes.token,
          'app_users_id': morte.appUsersId,
          'app_fazendas_id': morte.appFazendasId,
          'id': morte.id,
          'id_categoria': morte.idCategoria,
          'data': morte.data,
          'obs': morte.obs,
        }..removeWhere((key, value) => value == null),
      ),
    );
  }

  static Map<String, dynamic> _animalToJson(MorteUpsertAnimalEntity animal) {
    return {'id': animal.id};
  }
}
