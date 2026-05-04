import 'package:costeira/features/tasks/domain/entities/task_charts_entity.dart';
import 'package:costeira/features/tasks/domain/entities/task_charts_filter_entity.dart';
import 'package:costeira/features/tasks/domain/repository/tasks_datasource.dart';

class GetTaskChartsUsecase {
  const GetTaskChartsUsecase(this._datasource);

  final TasksDatasource _datasource;

  Future<TaskChartsEntity> call(TaskChartsFilterEntity filter) {
    return _datasource.getTaskCharts(filter);
  }
}
