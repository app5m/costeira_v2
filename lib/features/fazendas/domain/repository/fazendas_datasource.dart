import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/features/fazendas/domain/entities/fazenda_filter_entity.dart';
import 'package:costeira/features/fazendas/domain/entities/fazenda_list_entity.dart';
import 'package:costeira/features/fazendas/domain/entities/fazenda_upsert_entity.dart';

abstract interface class FazendasDatasource {
  Future<FazendaListEntity> getFazendas(FazendaFilterEntity filter);
  Future<ApiMessage> createFazenda(FazendaUpsertEntity fazenda);
  Future<ApiMessage> updateFazenda(FazendaUpsertEntity fazenda);
}
