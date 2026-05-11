import 'package:costeira/features/sanitarios/domain/entities/sanitario.dart';
import 'package:costeira/features/sanitarios/domain/repository/sanitarios_datasource.dart';

class GetSanitarioChartsUsecase {
  const GetSanitarioChartsUsecase(this._datasource);

  final SanitariosDatasource _datasource;

  Future<SanitarioChartsEntity> call(SanitarioChartsFilterEntity filter) {
    return _datasource.getSanitarioCharts(filter);
  }
}
