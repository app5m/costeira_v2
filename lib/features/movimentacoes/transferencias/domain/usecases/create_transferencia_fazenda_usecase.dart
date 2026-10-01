import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/features/movimentacoes/transferencias/domain/entities/transferencia_fazenda_upsert_entity.dart';
import 'package:costeira/features/movimentacoes/transferencias/domain/repository/transferencias_datasource.dart';

class CreateTransferenciaFazendaUsecase {
  const CreateTransferenciaFazendaUsecase(this._datasource);

  final TransferenciasDatasource _datasource;

  Future<ApiMessage> call(TransferenciaFazendaUpsertEntity transferencia) {
    return _datasource.createTransferenciaFazenda(transferencia);
  }
}
