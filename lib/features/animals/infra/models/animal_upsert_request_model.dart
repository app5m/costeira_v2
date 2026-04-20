import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/features/animals/domain/entities/animal_upsert_entity.dart';

class AnimalUpsertRequestModel {
  const AnimalUpsertRequestModel._(this.data);

  final Map<String, dynamic> data;

  factory AnimalUpsertRequestModel.create(AnimalUpsertEntity animal) {
    return AnimalUpsertRequestModel._(
      {
        'token': WSConstantes.token,
        'app_users_id': animal.appUsersId,
        'app_animais_categorias_id': animal.appAnimaisCategoriasId,
        'app_animais_subcategorias_id': animal.appAnimaisSubcategoriasId,
        'ut_bases_raciais_id': animal.utBasesRaciaisId,
        'app_animais_lotes_id': animal.appAnimaisLotesId,
        'app_potreiros_id': animal.appPotreirosId,
        'sexo': animal.sexo,
        'brinco': animal.brinco,
        'peso': animal.peso,
        'obs': animal.obs,
        'status': animal.status,
      }..removeWhere((key, value) => value == null),
    );
  }

  factory AnimalUpsertRequestModel.update(AnimalUpsertEntity animal) {
    return AnimalUpsertRequestModel._(
      {
        'token': WSConstantes.token,
        'id': animal.id,
        'app_users_id': animal.appUsersId,
        'app_animais_categorias_id': animal.appAnimaisCategoriasId,
        'app_animais_subcategorias_id': animal.appAnimaisSubcategoriasId,
        'ut_bases_raciais_id': animal.utBasesRaciaisId,
        'app_animais_lotes_id': animal.appAnimaisLotesId,
        'app_potreiros_id': animal.appPotreirosId,
        'sexo': animal.sexo,
        'brinco': animal.brinco,
        'peso': animal.peso,
        'obs': animal.obs,
        'status': animal.status,
      }..removeWhere((key, value) => value == null),
    );
  }
}
