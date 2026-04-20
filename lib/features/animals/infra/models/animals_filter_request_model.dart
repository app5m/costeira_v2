import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/features/animals/domain/entities/animals_filter_entity.dart';

class AnimalsFilterRequestModel {
  const AnimalsFilterRequestModel._(this.data);

  final Map<String, dynamic> data;

  factory AnimalsFilterRequestModel.fromEntity(AnimalsFilterEntity filter) {
    return AnimalsFilterRequestModel._(
      {
        'token': WSConstantes.token,
        'app_users_id': filter.appUsersId,
        'id': filter.id,
        'app_animais_categorias_id': filter.appAnimaisCategoriasId,
        'app_animais_subcategorias_id': filter.appAnimaisSubcategoriasId,
        'ut_bases_raciais_id': filter.utBasesRaciaisId,
        'brinco': filter.brinco,
      }..removeWhere((key, value) => value == null),
    );
  }
}
