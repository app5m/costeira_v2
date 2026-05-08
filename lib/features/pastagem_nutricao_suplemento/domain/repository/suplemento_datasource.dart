import 'package:costeira/features/pastagem_nutricao_suplemento/domain/entities/suplemento_filter.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/entities/suplementos_list.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/entities/suplemento.dart';

abstract class SuplementoDatasource {
  Future<SuplementosListEntity> getSuplementos(SuplementoFilterEntity filter);
  Future<ApiMessage> createSuplemento(SuplementoUpsertEntity suplemento);
  Future<ApiMessage> updateSuplemento(SuplementoUpsertEntity suplemento);
  Future<ApiMessage> createRegistro(SuplementoRegistroUpsertEntity registro);
  Future<ApiMessage> updateRegistro(SuplementoRegistroUpsertEntity registro);
  Future<ApiMessage> deleteSuplemento(DeleteSuplementoEntity suplemento);
  Future<ApiMessage> deleteRegistro(DeleteSuplementoRegistroEntity registro);
  Future<SuplementoChartsEntity> getCharts(SuplementoChartsFilterEntity filter);
}
