import 'package:costeira/features/tasks/domain/entities/task_filter_entity.dart';
import 'package:costeira/features/tasks/domain/entities/tasks_list_entity.dart';
import 'package:costeira/features/tasks/domain/repository/tasks_datasource.dart';

class GetTasksUsecase {
  const GetTasksUsecase(this._datasource);

  final TasksDatasource _datasource;

  Future<TasksListEntity> call(TaskFilterEntity filter) {
    return _datasource.getTasks(filter);
  }
}
