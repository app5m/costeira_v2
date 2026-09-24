import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/features/movimentacoes/troca_categoria/domain/entities/troca_categoria_upsert_animal_entity.dart';
import 'package:costeira/features/movimentacoes/troca_categoria/domain/entities/troca_categoria_upsert_entity.dart';

class TrocaCategoriaUpsertRequestModel {
  const TrocaCategoriaUpsertRequestModel._(this.data);

  final Map<String, dynamic> data;

  factory TrocaCategoriaUpsertRequestModel.create(
    TrocaCategoriaUpsertEntity troca,
  ) {
    return TrocaCategoriaUpsertRequestModel._(
      _baseData(troca)..addAll({
        'animais': troca.animais.map(_animalToJson).toList(growable: false),
      }),
    );
  }

  factory TrocaCategoriaUpsertRequestModel.update(
    TrocaCategoriaUpsertEntity troca,
  ) {
    return TrocaCategoriaUpsertRequestModel._(
      _baseData(troca)..addAll({'id': troca.id}),
    );
  }

  static Map<String, dynamic> _baseData(TrocaCategoriaUpsertEntity troca) {
    return {
      'token': WSConstantes.token,
      'app_users_id': troca.appUsersId,
      'app_fazendas_id': troca.appFazendasId,
      'data': troca.data,
      'catg_destino': troca.catgDestino,
      'app_potreiros_id': troca.appPotreirosId,
      'app_animais_lotes_id': troca.appAnimaisLotesId,
      'obs': troca.obs,
    }..removeWhere((key, value) => value == null);
  }

  static Map<String, dynamic> _animalToJson(
    TrocaCategoriaUpsertAnimalEntity animal,
  ) {
    return {'id': animal.id};
  }
}
