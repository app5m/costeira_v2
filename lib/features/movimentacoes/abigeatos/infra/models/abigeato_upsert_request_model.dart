import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/features/movimentacoes/abigeatos/domain/entities/abigeato_upsert_animal_entity.dart';
import 'package:costeira/features/movimentacoes/abigeatos/domain/entities/abigeato_upsert_entity.dart';

class AbigeatoUpsertRequestModel {
  const AbigeatoUpsertRequestModel._(this.data);

  final Map<String, dynamic> data;

  factory AbigeatoUpsertRequestModel.create(AbigeatoUpsertEntity abigeato) {
    return AbigeatoUpsertRequestModel._(
      _baseData(abigeato)..addAll({
        'animais': abigeato.animais.map(_animalToJson).toList(growable: false),
      }),
    );
  }

  factory AbigeatoUpsertRequestModel.update(AbigeatoUpsertEntity abigeato) {
    return AbigeatoUpsertRequestModel._(
      _baseData(abigeato)..addAll({'id': abigeato.id}),
    );
  }

  static Map<String, dynamic> _baseData(AbigeatoUpsertEntity abigeato) {
    return {
      'token': WSConstantes.token,
      'app_users_id': abigeato.appUsersId,
      'app_fazendas_id': abigeato.appFazendasId,
      'data': abigeato.data,
      'obs': abigeato.obs,
    }..removeWhere((key, value) => value == null);
  }

  static Map<String, dynamic> _animalToJson(AbigeatoUpsertAnimalEntity animal) {
    return {'id': animal.id};
  }
}
