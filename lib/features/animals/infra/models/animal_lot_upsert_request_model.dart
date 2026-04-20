import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/features/animals/domain/entities/animal_lot_upsert_entity.dart';

class AnimalLotUpsertRequestModel {
  const AnimalLotUpsertRequestModel._(this.data);

  final Map<String, dynamic> data;

  factory AnimalLotUpsertRequestModel.create(AnimalLotUpsertEntity lot) {
    return AnimalLotUpsertRequestModel._(
      {
        'token': WSConstantes.token,
        'app_users_id': lot.appUsersId,
        'nome': lot.nome,
      }..removeWhere((key, value) => value == null),
    );
  }

  factory AnimalLotUpsertRequestModel.update(AnimalLotUpsertEntity lot) {
    return AnimalLotUpsertRequestModel._(
      {
        'token': WSConstantes.token,
        'id': lot.id,
        'app_users_id': lot.appUsersId,
        'nome': lot.nome,
      }..removeWhere((key, value) => value == null),
    );
  }
}
