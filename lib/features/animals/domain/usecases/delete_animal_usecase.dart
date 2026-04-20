import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/features/animals/domain/entities/delete_animal_entity.dart';
import 'package:costeira/features/animals/domain/repository/animals_datasource.dart';

class DeleteAnimalUsecase {
  const DeleteAnimalUsecase(this._datasource);

  final AnimalsDatasource _datasource;

  Future<ApiMessage> call(DeleteAnimalEntity animal) {
    return _datasource.deleteAnimal(animal);
  }
}
