import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/features/movimentacoes/abortos/domain/entities/aborto_upsert_entity.dart';
import 'package:costeira/features/movimentacoes/abortos/domain/entities/delete_aborto_entity.dart';

abstract interface class AbortosDatasource {
  Future<ApiMessage> createAborto(AbortoUpsertEntity aborto);
  Future<ApiMessage> updateAborto(AbortoUpsertEntity aborto);
  Future<ApiMessage> deleteAborto(DeleteAbortoEntity aborto);
}
