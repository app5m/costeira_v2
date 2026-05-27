import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/features/movimentacoes/abigeatos/domain/entities/abigeato_upsert_entity.dart';
import 'package:costeira/features/movimentacoes/abigeatos/domain/entities/delete_abigeato_entity.dart';

abstract interface class AbigeatosDatasource {
  Future<ApiMessage> createAbigeato(AbigeatoUpsertEntity abigeato);

  Future<ApiMessage> updateAbigeato(AbigeatoUpsertEntity abigeato);

  Future<ApiMessage> deleteAbigeato(DeleteAbigeatoEntity abigeato);
}
