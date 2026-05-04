import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/features/tasks/domain/entities/task_status_entity.dart';
import 'package:costeira/features/tasks/domain/repository/tasks_datasource.dart';

class SetTaskDoneUsecase {
  const SetTaskDoneUsecase(this._datasource);

  final TasksDatasource _datasource;

  Future<ApiMessage> call(TaskStatusEntity task) {
    return _datasource.setTaskDone(task);
  }
}
