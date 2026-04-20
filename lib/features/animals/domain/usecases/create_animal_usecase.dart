import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/features/animals/domain/entities/animal_upsert_entity.dart';
import 'package:costeira/features/animals/domain/repository/animals_datasource.dart';

class CreateAnimalUsecase {
  const CreateAnimalUsecase(this._datasource);

  final AnimalsDatasource _datasource;

  Future<ApiMessage> call(AnimalUpsertEntity animal) {
    return _datasource.createAnimal(animal);
  }
}
