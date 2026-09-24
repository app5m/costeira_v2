import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/features/movimentacoes/mortes/domain/entities/morte_upsert_animal_entity.dart';
import 'package:costeira/features/movimentacoes/mortes/domain/entities/morte_upsert_entity.dart';

class MorteUpsertRequestModel {
  const MorteUpsertRequestModel._(this.data);

  final Map<String, dynamic> data;

  factory MorteUpsertRequestModel.create(MorteUpsertEntity morte) {
    return MorteUpsertRequestModel._(
      _baseData(morte)..addAll({
        'animais': morte.animais.map(_animalToJson).toList(growable: false),
      }),
    );
  }

  factory MorteUpsertRequestModel.update(MorteUpsertEntity morte) {
    return MorteUpsertRequestModel._(
      _baseData(morte)..addAll({'id': morte.id}),
    );
  }

  static Map<String, dynamic> _baseData(MorteUpsertEntity morte) {
    return {
      'token': WSConstantes.token,
      'app_users_id': morte.appUsersId,
      'app_fazendas_id': morte.appFazendasId,
      'app_potreiros_id': morte.appPotreirosId,
      'data': morte.data,
    }..removeWhere((key, value) => value == null);
  }

  static Map<String, dynamic> _animalToJson(MorteUpsertAnimalEntity animal) {
    return {'id': animal.id, 'causa': animal.causa}
      ..removeWhere((key, value) => value == null);
  }
}
