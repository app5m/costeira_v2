import 'package:costeira/features/insumos/domain/entities/insumos.dart';
import 'package:costeira/core/models/api_message.dart';

abstract class InsumosDatasource {
  Future<InsumosListEntity> getInsumos(InsumosFilterEntity filter);
  Future<ApiMessage> createInsumo(InsumoUpsertEntity insumo);
  Future<ApiMessage> updateInsumo(InsumoUpsertEntity insumo);
  Future<ApiMessage> createInsumoRegistro(InsumoRegistroUpsertEntity registro);
  Future<ApiMessage> updateInsumoRegistro(InsumoRegistroUpsertEntity registro);
  Future<ApiMessage> deleteInsumo(DeleteInsumoEntity insumo);
  Future<ApiMessage> deleteInsumoRegistro(DeleteInsumoEntity registro);
  Future<InsumosTipoListEntity> getInsumosTipo(InsumosTipoFilterEntity filter);
  Future<InsumoChartsEntity> getInsumoCharts(InsumoChartsFilterEntity filter);
}
