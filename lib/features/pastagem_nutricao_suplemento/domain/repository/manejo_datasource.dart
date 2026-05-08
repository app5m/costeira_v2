import 'package:costeira/features/pastagem_nutricao_suplemento/domain/entities/manejo_filter.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/entities/manejos_list.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/entities/manejo.dart';

abstract class ManejoDataSource {
  Future<ManejosListEntity> getManejos(ManejoFilterEntity filter);
  Future<ApiMessage> createManejo(ManejoUpsertEntity manejo);
  Future<ApiMessage> updateManejo(ManejoUpsertEntity manejo);
  Future<ApiMessage> deleteManejo(DeleteManejoEntity manejo);
  Future<ManejoChartsEntity> getCharts(ManejoChartsFilterEntity filter);
}
