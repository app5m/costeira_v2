import 'package:costeira/features/pastagem_nutricao_suplemento/domain/entities/manejo.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/repository/manejo_datasource.dart';

class GetManejoChartsUsecase {
  const GetManejoChartsUsecase(this._datasource);

  final ManejoDataSource _datasource;

  Future<ManejoChartsEntity> call(ManejoChartsFilterEntity filter) {
    return _datasource.getCharts(filter);
  }
}
