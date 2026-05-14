import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/features/movimentacoes/troca_categoria/domain/entities/delete_troca_categoria_entity.dart';
import 'package:costeira/features/movimentacoes/troca_categoria/domain/repository/troca_categoria_datasource.dart';

class DeleteTrocaCategoriaUsecase {
  const DeleteTrocaCategoriaUsecase(this._datasource);

  final TrocaCategoriaDatasource _datasource;

  Future<ApiMessage> call(DeleteTrocaCategoriaEntity troca) {
    return _datasource.deleteTrocaCategoria(troca);
  }
}
