import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/features/fazendas/domain/entities/fazenda_upsert_entity.dart';
import 'package:costeira/features/fazendas/domain/repository/fazendas_datasource.dart';

class CreateFazendaUsecase {
  const CreateFazendaUsecase(this._datasource);

  final FazendasDatasource _datasource;

  Future<ApiMessage> call(FazendaUpsertEntity fazenda) {
    return _datasource.createFazenda(fazenda);
  }
}
