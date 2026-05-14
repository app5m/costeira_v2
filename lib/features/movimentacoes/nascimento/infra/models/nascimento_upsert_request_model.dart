import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/features/movimentacoes/nascimento/domain/entities/nascimento_upsert_animal_entity.dart';
import 'package:costeira/features/movimentacoes/nascimento/domain/entities/nascimento_upsert_entity.dart';

class NascimentoUpsertRequestModel {
  const NascimentoUpsertRequestModel._(this.data);

  final Map<String, dynamic> data;

  factory NascimentoUpsertRequestModel.create(
    NascimentoUpsertEntity nascimento,
  ) {
    return NascimentoUpsertRequestModel._(
      _baseData(nascimento)..addAll({
        'animais': nascimento.animais
            .map(_animalToJson)
            .toList(growable: false),
      }),
    );
  }

  factory NascimentoUpsertRequestModel.update(
    NascimentoUpsertEntity nascimento,
  ) {
    return NascimentoUpsertRequestModel._(
      _baseData(nascimento)..addAll({'id': nascimento.id}),
    );
  }

  static Map<String, dynamic> _baseData(NascimentoUpsertEntity nascimento) {
    return {
      'token': WSConstantes.token,
      'app_users_id': nascimento.appUsersId,
      'app_potreiros_id': nascimento.appPotreirosId,
      'app_animais_lotes_id': nascimento.appAnimaisLotesId,
      'data': nascimento.data,
      'peso_total': nascimento.pesoTotal,
      'obs': nascimento.obs,
    }..removeWhere((key, value) => value == null);
  }

  static Map<String, dynamic> _animalToJson(
    NascimentoUpsertAnimalEntity animal,
  ) {
    return {'id': animal.id, 'tipo': animal.tipo};
  }
}
