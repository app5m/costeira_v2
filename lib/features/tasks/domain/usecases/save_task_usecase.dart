import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/features/tasks/domain/entities/task_upsert_entity.dart';
import 'package:costeira/features/tasks/domain/repository/tasks_datasource.dart';

class SaveTaskUsecase {
  const SaveTaskUsecase(this._datasource);

  final TasksDatasource _datasource;

  Future<ApiMessage> call(TaskUpsertEntity task) {
    return _datasource.saveTask(task);
  }
}
