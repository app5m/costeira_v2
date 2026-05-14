import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/features/movimentacoes/nascimento/domain/entities/nascimento_upsert_entity.dart';
import 'package:costeira/features/movimentacoes/nascimento/domain/repository/nascimentos_datasource.dart';

class CreateNascimentoUsecase {
  const CreateNascimentoUsecase(this._datasource);

  final NascimentosDatasource _datasource;

  Future<ApiMessage> call(NascimentoUpsertEntity nascimento) {
    return _datasource.createNascimento(nascimento);
  }
}
