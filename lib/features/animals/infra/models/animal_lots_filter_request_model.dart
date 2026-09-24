import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/features/animals/domain/entities/animal_lots_filter_entity.dart';

class AnimalLotsFilterRequestModel {
  const AnimalLotsFilterRequestModel._(this.data);

  final Map<String, dynamic> data;

  factory AnimalLotsFilterRequestModel.fromEntity(
    AnimalLotsFilterEntity filter,
  ) {
    return AnimalLotsFilterRequestModel._(
      {
        'token': WSConstantes.token,
        'app_users_id': filter.appUsersId,
        'app_fazendas_id': filter.appFazendasId,
        'id': filter.id,
        'nome': filter.nome,
      }..removeWhere((key, value) => value == null),
    );
  }
}
