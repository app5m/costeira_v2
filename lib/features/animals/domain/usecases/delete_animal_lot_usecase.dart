import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/features/animals/domain/entities/delete_animal_lot_entity.dart';
import 'package:costeira/features/animals/domain/repository/animals_datasource.dart';

class DeleteAnimalLotUsecase {
  const DeleteAnimalLotUsecase(this._datasource);

  final AnimalsDatasource _datasource;

  Future<ApiMessage> call(DeleteAnimalLotEntity lot) {
    return _datasource.deleteAnimalLot(lot);
  }
}
