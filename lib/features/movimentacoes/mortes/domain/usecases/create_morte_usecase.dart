import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/features/movimentacoes/mortes/domain/entities/morte_upsert_entity.dart';
import 'package:costeira/features/movimentacoes/mortes/domain/repository/mortes_datasource.dart';

class CreateMorteUsecase {
  const CreateMorteUsecase(this._datasource);

  final MortesDatasource _datasource;

  Future<ApiMessage> call(MorteUpsertEntity morte) {
    return _datasource.createMorte(morte);
  }
}
