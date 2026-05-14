import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/features/movimentacoes/troca_categoria/domain/entities/delete_troca_categoria_entity.dart';
import 'package:costeira/features/movimentacoes/troca_categoria/domain/entities/troca_categoria_upsert_entity.dart';

abstract interface class TrocaCategoriaDatasource {
  Future<ApiMessage> createTrocaCategoria(TrocaCategoriaUpsertEntity troca);
  Future<ApiMessage> updateTrocaCategoria(TrocaCategoriaUpsertEntity troca);
  Future<ApiMessage> deleteTrocaCategoria(DeleteTrocaCategoriaEntity troca);
}
