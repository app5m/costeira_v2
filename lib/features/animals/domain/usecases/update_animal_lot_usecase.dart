import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/features/animals/domain/entities/animal_lot_upsert_entity.dart';
import 'package:costeira/features/animals/domain/repository/animals_datasource.dart';

class UpdateAnimalLotUsecase {
  const UpdateAnimalLotUsecase(this._datasource);

  final AnimalsDatasource _datasource;

  Future<ApiMessage> call(AnimalLotUpsertEntity lot) {
    return _datasource.updateAnimalLot(lot);
  }
}
