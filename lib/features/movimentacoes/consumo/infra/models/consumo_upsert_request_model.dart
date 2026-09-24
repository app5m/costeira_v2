import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/features/movimentacoes/consumo/domain/entities/consumo_upsert_animal_entity.dart';
import 'package:costeira/features/movimentacoes/consumo/domain/entities/consumo_upsert_entity.dart';

class ConsumoUpsertRequestModel {
  const ConsumoUpsertRequestModel._(this.data);

  final Map<String, dynamic> data;

  factory ConsumoUpsertRequestModel.create(ConsumoUpsertEntity consumo) {
    return ConsumoUpsertRequestModel._(
      _baseData(consumo)..addAll({
        'animais': consumo.animais.map(_animalToJson).toList(growable: false),
      }),
    );
  }

  factory ConsumoUpsertRequestModel.update(ConsumoUpsertEntity consumo) {
    return ConsumoUpsertRequestModel._(
      _baseData(consumo)..addAll({'id': consumo.id}),
    );
  }

  static Map<String, dynamic> _baseData(ConsumoUpsertEntity consumo) {
    return {
      'token': WSConstantes.token,
      'app_users_id': consumo.appUsersId,
      'app_fazendas_id': consumo.appFazendasId,
      'data': consumo.data,
      'obs': consumo.obs,
    }..removeWhere((key, value) => value == null);
  }

  static Map<String, dynamic> _animalToJson(ConsumoUpsertAnimalEntity animal) {
    return {'id': animal.id};
  }
}
