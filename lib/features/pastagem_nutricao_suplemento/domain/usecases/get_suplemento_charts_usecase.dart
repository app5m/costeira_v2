import 'package:costeira/features/pastagem_nutricao_suplemento/domain/entities/suplemento.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/repository/suplemento_datasource.dart';

class GetSuplementoChartsUsecase {
  const GetSuplementoChartsUsecase(this._datasource);

  final SuplementoDatasource _datasource;

  Future<SuplementoChartsEntity> call(SuplementoChartsFilterEntity filter) {
    return _datasource.getCharts(filter);
  }
}
