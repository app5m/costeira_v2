import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/features/animals/domain/entities/animals_filter_entity.dart';

class AnimalsFilterRequestModel {
  const AnimalsFilterRequestModel._(this.data);

  final Map<String, dynamic> data;

  factory AnimalsFilterRequestModel.fromEntity(AnimalsFilterEntity filter) {
    final farmId = filter.appFazendasId;
    if (farmId == null || farmId <= 0) {
      throw ArgumentError(
        'app_fazendas_id é obrigatório no payload de /animais/listar.',
      );
    }

    final data = <String, dynamic>{
      'token': WSConstantes.token,
      'app_users_id': filter.appUsersId,
      'id': filter.id,
      'app_fazendas_id': farmId,
      'app_potreiros_id': filter.appPotreirosId,
      'app_animais_lotes_id': filter.appAnimaisLotesId,
      'app_lotes_id': filter.appAnimaisLotesId,
      'app_animais_categorias_id': filter.appAnimaisCategoriasId,
      'app_animais_subcategorias_id': filter.appAnimaisSubcategoriasId,
      'ut_bases_raciais_id': filter.utBasesRaciaisId,
      if (filter.brincoOnly) 'brincos': true,
      if (!filter.brincoOnly) 'brinco': filter.brinco,
    };
    data.removeWhere(
      (key, value) => key != 'app_fazendas_id' && value == null,
    );
    return AnimalsFilterRequestModel._(data);
  }
}
