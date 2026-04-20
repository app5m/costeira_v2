import 'package:costeira/features/animals/domain/entities/animals_filter_entity.dart';
import 'package:costeira/features/animals/domain/entities/animals_list_entity.dart';
import 'package:costeira/features/animals/domain/repository/animals_datasource.dart';

class GetAnimalsUsecase {
  const GetAnimalsUsecase(this._datasource);

  final AnimalsDatasource _datasource;

  Future<AnimalsListEntity> call(AnimalsFilterEntity filter) {
    return _datasource.getAnimals(filter);
  }
}
