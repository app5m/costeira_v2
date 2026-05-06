import 'package:costeira/features/insumos/domain/entities/insumos.dart';
import 'package:costeira/features/insumos/domain/repository/insumos_datasource.dart';

class GetInsumosUsecase {
  const GetInsumosUsecase(this._datasource);

  final InsumosDatasource _datasource;

  Future<InsumosListEntity> call(InsumosFilterEntity filter) {
    return _datasource.getInsumos(filter);
  }
}
