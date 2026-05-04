import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/features/tasks/domain/entities/task_responsavel_upsert_entity.dart';
import 'package:costeira/features/tasks/domain/repository/tasks_datasource.dart';

class SaveTaskResponsavelUsecase {
  const SaveTaskResponsavelUsecase(this._datasource);

  final TasksDatasource _datasource;

  Future<ApiMessage> call(TaskResponsavelUpsertEntity responsavel) {
    return _datasource.saveResponsavel(responsavel);
  }
}
