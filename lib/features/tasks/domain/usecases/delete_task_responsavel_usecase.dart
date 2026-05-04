import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/features/tasks/domain/entities/delete_task_responsavel_entity.dart';
import 'package:costeira/features/tasks/domain/repository/tasks_datasource.dart';

class DeleteTaskResponsavelUsecase {
  const DeleteTaskResponsavelUsecase(this._datasource);

  final TasksDatasource _datasource;

  Future<ApiMessage> call(DeleteTaskResponsavelEntity responsavel) {
    return _datasource.deleteResponsavel(responsavel);
  }
}
