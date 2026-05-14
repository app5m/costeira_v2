import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/features/movimentacoes/nascimento/domain/entities/delete_nascimento_entity.dart';
import 'package:costeira/features/movimentacoes/nascimento/domain/repository/nascimentos_datasource.dart';

class DeleteNascimentoUsecase {
  const DeleteNascimentoUsecase(this._datasource);

  final NascimentosDatasource _datasource;

  Future<ApiMessage> call(DeleteNascimentoEntity nascimento) {
    return _datasource.deleteNascimento(nascimento);
  }
}
