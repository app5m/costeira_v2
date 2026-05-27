import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/features/movimentacoes/abortos/domain/entities/aborto_upsert_entity.dart';
import 'package:costeira/features/movimentacoes/abortos/domain/repository/abortos_datasource.dart';

class UpdateAbortoUsecase {
  const UpdateAbortoUsecase(this._datasource);

  final AbortosDatasource _datasource;

  Future<ApiMessage> call(AbortoUpsertEntity aborto) {
    return _datasource.updateAborto(aborto);
  }
}
