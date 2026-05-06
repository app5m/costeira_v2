import 'package:costeira/features/insumos/domain/entities/insumos.dart';
import 'package:costeira/features/insumos/domain/repository/insumos_datasource.dart';

class GetInsumoChartsUsecase {
  const GetInsumoChartsUsecase(this._datasource);

  final InsumosDatasource _datasource;

  Future<InsumoChartsEntity> call(InsumoChartsFilterEntity filter) {
    return _datasource.getInsumoCharts(filter);
  }
}
