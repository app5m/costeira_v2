import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/features/movimentacoes/troca_categoria/domain/entities/troca_categoria_upsert_entity.dart';
import 'package:costeira/features/movimentacoes/troca_categoria/domain/repository/troca_categoria_datasource.dart';

class UpdateTrocaCategoriaUsecase {
  const UpdateTrocaCategoriaUsecase(this._datasource);

  final TrocaCategoriaDatasource _datasource;

  Future<ApiMessage> call(TrocaCategoriaUpsertEntity troca) {
    return _datasource.updateTrocaCategoria(troca);
  }
}
