import 'package:costeira/features/tasks/domain/entities/task_filter_entity.dart';
import 'package:costeira/features/tasks/domain/entities/task_responsavel_entity.dart';
import 'package:costeira/features/tasks/domain/repository/tasks_datasource.dart';

class GetTaskResponsaveisUsecase {
  const GetTaskResponsaveisUsecase(this._datasource);

  final TasksDatasource _datasource;

  Future<List<TaskResponsavelEntity>> call(TaskFilterEntity filter) async {
    final result = await _datasource.getTasks(filter);
    return result.responsaveis;
  }
}
