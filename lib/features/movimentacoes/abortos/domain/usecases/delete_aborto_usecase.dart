import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/features/movimentacoes/abortos/domain/entities/delete_aborto_entity.dart';
import 'package:costeira/features/movimentacoes/abortos/domain/repository/abortos_datasource.dart';

class DeleteAbortoUsecase {
  const DeleteAbortoUsecase(this._datasource);

  final AbortosDatasource _datasource;

  Future<ApiMessage> call(DeleteAbortoEntity aborto) {
    return _datasource.deleteAborto(aborto);
  }
}
