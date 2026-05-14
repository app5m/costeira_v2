import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/features/movimentacoes/nascimento/domain/entities/delete_nascimento_entity.dart';
import 'package:costeira/features/movimentacoes/nascimento/domain/entities/nascimento_upsert_entity.dart';

abstract interface class NascimentosDatasource {
  Future<ApiMessage> createNascimento(NascimentoUpsertEntity nascimento);
  Future<ApiMessage> updateNascimento(NascimentoUpsertEntity nascimento);
  Future<ApiMessage> deleteNascimento(DeleteNascimentoEntity nascimento);
}
