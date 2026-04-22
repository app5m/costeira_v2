import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/features/potreiros/domain/entities/delete_potreiro_entity.dart';
import 'package:costeira/features/potreiros/domain/entities/potreiro_charts_entity.dart';
import 'package:costeira/features/potreiros/domain/entities/potreiro_charts_filter_entity.dart';
import 'package:costeira/features/potreiros/domain/entities/potreiro_upsert_entity.dart';
import 'package:costeira/features/potreiros/domain/entities/potreiros_filter_entity.dart';
import 'package:costeira/features/potreiros/domain/entities/potreiros_list_entity.dart';

abstract class PotreirosDatasource {
  Future<PotreirosListEntity> getPotreiros(PotreirosFilterEntity filter);
  Future<ApiMessage> createPotreiro(PotreiroUpsertEntity potreiro);
  Future<ApiMessage> updatePotreiro(PotreiroUpsertEntity potreiro);
  Future<ApiMessage> deletePotreiro(DeletePotreiroEntity potreiro);
  Future<PotreiroChartsEntity> getPotreiroCharts(
    PotreiroChartsFilterEntity filter,
  );
}
