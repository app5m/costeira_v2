import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/features/movimentacoes/transferencias/domain/repository/transferencias_datasource.dart';

class AceitarTransferenciaFazendaUsecase {
  const AceitarTransferenciaFazendaUsecase(this._datasource);

  final TransferenciasDatasource _datasource;

  Future<ApiMessage> call({
    required int id,
    required int statusTransferencia,
  }) {
    return _datasource.aceitarTransferenciaFazenda(
      id: id,
      statusTransferencia: statusTransferencia,
    );
  }
}
