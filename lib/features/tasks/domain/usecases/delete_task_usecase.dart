import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/features/tasks/domain/entities/delete_task_entity.dart';
import 'package:costeira/features/tasks/domain/repository/tasks_datasource.dart';

class DeleteTaskUsecase {
  const DeleteTaskUsecase(this._datasource);

  final TasksDatasource _datasource;

  Future<ApiMessage> call(DeleteTaskEntity task) {
    return _datasource.deleteTask(task);
  }
}
