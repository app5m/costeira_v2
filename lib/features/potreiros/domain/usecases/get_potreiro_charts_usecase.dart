import 'package:costeira/features/potreiros/domain/entities/potreiro_charts_entity.dart';
import 'package:costeira/features/potreiros/domain/entities/potreiro_charts_filter_entity.dart';
import 'package:costeira/features/potreiros/domain/repository/potreiros_datasource.dart';

class GetPotreiroChartsUsecase {
  const GetPotreiroChartsUsecase(this._datasource);

  final PotreirosDatasource _datasource;

  Future<PotreiroChartsEntity> call(PotreiroChartsFilterEntity filter) {
    return _datasource.getPotreiroCharts(filter);
  }
}
