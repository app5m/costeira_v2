import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/features/movimentacoes/abigeatos/domain/entities/delete_abigeato_entity.dart';
import 'package:costeira/features/movimentacoes/abigeatos/domain/repository/abigeatos_datasource.dart';

class DeleteAbigeatoUsecase {
  const DeleteAbigeatoUsecase(this._datasource);

  final AbigeatosDatasource _datasource;

  Future<ApiMessage> call(DeleteAbigeatoEntity abigeato) {
    return _datasource.deleteAbigeato(abigeato);
  }
}
