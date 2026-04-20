import 'package:costeira/features/animals/domain/entities/animal_charts_entity.dart';
import 'package:costeira/features/animals/domain/entities/animal_charts_filter_entity.dart';
import 'package:costeira/features/animals/domain/repository/animals_datasource.dart';

class GetAnimalChartsUsecase {
  const GetAnimalChartsUsecase(this._datasource);

  final AnimalsDatasource _datasource;

  Future<AnimalChartsEntity> call(AnimalChartsFilterEntity filter) {
    return _datasource.getAnimalCharts(filter);
  }
}
