import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/features/movimentacoes/abigeatos/domain/entities/abigeato_upsert_entity.dart';
import 'package:costeira/features/movimentacoes/abigeatos/domain/repository/abigeatos_datasource.dart';

class CreateAbigeatoUsecase {
  const CreateAbigeatoUsecase(this._datasource);

  final AbigeatosDatasource _datasource;

  Future<ApiMessage> call(AbigeatoUpsertEntity abigeato) {
    return _datasource.createAbigeato(abigeato);
  }
}
