import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/features/movimentacoes/mortes/domain/entities/delete_morte_entity.dart';
import 'package:costeira/features/movimentacoes/mortes/domain/entities/morte_upsert_entity.dart';

abstract interface class MortesDatasource {
  Future<ApiMessage> createMorte(MorteUpsertEntity morte);
  Future<ApiMessage> updateMorte(MorteUpsertEntity morte);
  Future<ApiMessage> deleteMorte(DeleteMorteEntity morte);
}
