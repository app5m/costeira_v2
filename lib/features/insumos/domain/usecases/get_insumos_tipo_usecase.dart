import 'package:costeira/features/insumos/domain/entities/insumos.dart';
import 'package:costeira/features/insumos/domain/repository/insumos_datasource.dart';

class GetInsumosTipoUsecase {
  const GetInsumosTipoUsecase(this._datasource);

  final InsumosDatasource _datasource;

  Future<InsumosTipoListEntity> call(InsumosTipoFilterEntity filter) {
    return _datasource.getInsumosTipo(filter);
  }
}
