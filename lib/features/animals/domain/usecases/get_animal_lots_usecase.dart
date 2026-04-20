import 'package:costeira/features/animals/domain/entities/animal_lots_filter_entity.dart';
import 'package:costeira/features/animals/domain/entities/animal_lots_list_entity.dart';
import 'package:costeira/features/animals/domain/repository/animals_datasource.dart';

class GetAnimalLotsUsecase {
  const GetAnimalLotsUsecase(this._datasource);

  final AnimalsDatasource _datasource;

  Future<AnimalLotsListEntity> call(AnimalLotsFilterEntity filter) {
    return _datasource.getAnimalLots(filter);
  }
}
