import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/features/sanitarios/domain/entities/sanitario.dart';
import 'package:costeira/features/sanitarios/domain/repository/sanitarios_datasource.dart';

class ExecutarSanitarioUsecase {
  const ExecutarSanitarioUsecase(this._datasource);

  final SanitariosDatasource _datasource;

  Future<ApiMessage> call(SanitarioExecucaoEntity execucao) {
    return _datasource.executarSanitario(execucao);
  }
}
