import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/features/movimentacoes/abortos/domain/entities/aborto_upsert_animal_entity.dart';
import 'package:costeira/features/movimentacoes/abortos/domain/entities/aborto_upsert_entity.dart';

class AbortoUpsertRequestModel {
  const AbortoUpsertRequestModel._(this.data);

  final Map<String, dynamic> data;

  factory AbortoUpsertRequestModel.create(AbortoUpsertEntity aborto) {
    return AbortoUpsertRequestModel._(
      _baseData(aborto)..addAll({
        'animais': aborto.animais.map(_animalToJson).toList(growable: false),
      }),
    );
  }

  factory AbortoUpsertRequestModel.update(AbortoUpsertEntity aborto) {
    return AbortoUpsertRequestModel._(
      _baseData(aborto)..addAll({'id': aborto.id}),
    );
  }

  static Map<String, dynamic> _baseData(AbortoUpsertEntity aborto) {
    return {
      'token': WSConstantes.token,
      'app_users_id': aborto.appUsersId,
      'app_fazendas_id': aborto.appFazendasId,
      'data': aborto.data,
      'status_destino': aborto.statusDestino,
      'app_potreiros_id': aborto.appPotreirosId,
      'app_animais_lotes_id': aborto.appAnimaisLotesId,
      'obs': aborto.obs,
    }..removeWhere((key, value) => value == null);
  }

  static Map<String, dynamic> _animalToJson(AbortoUpsertAnimalEntity animal) {
    return {'id': animal.id, 'causa': animal.causa}
      ..removeWhere((key, value) => value == null);
  }
}
