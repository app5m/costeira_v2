import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/features/insumos/domain/entities/insumos.dart';
import 'package:costeira/features/insumos/domain/repository/insumos_datasource.dart';

class DeleteInsumoRegistroUsecase {
  const DeleteInsumoRegistroUsecase(this._datasource);

  final InsumosDatasource _datasource;

  Future<ApiMessage> call(DeleteInsumoEntity registro) {
    return _datasource.deleteInsumoRegistro(registro);
  }
}
