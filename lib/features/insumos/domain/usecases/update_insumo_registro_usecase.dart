import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/features/insumos/domain/entities/insumos.dart';
import 'package:costeira/features/insumos/domain/repository/insumos_datasource.dart';

class UpdateInsumoRegistroUsecase {
  const UpdateInsumoRegistroUsecase(this._datasource);

  final InsumosDatasource _datasource;

  Future<ApiMessage> call(InsumoRegistroUpsertEntity registro) {
    return _datasource.updateInsumoRegistro(registro);
  }
}
