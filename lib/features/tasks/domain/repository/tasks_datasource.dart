import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/features/tasks/domain/entities/delete_task_entity.dart';
import 'package:costeira/features/tasks/domain/entities/delete_task_responsavel_entity.dart';
import 'package:costeira/features/tasks/domain/entities/task_charts_entity.dart';
import 'package:costeira/features/tasks/domain/entities/task_charts_filter_entity.dart';
import 'package:costeira/features/tasks/domain/entities/task_filter_entity.dart';
import 'package:costeira/features/tasks/domain/entities/task_responsavel_upsert_entity.dart';
import 'package:costeira/features/tasks/domain/entities/task_status_entity.dart';
import 'package:costeira/features/tasks/domain/entities/task_upsert_entity.dart';
import 'package:costeira/features/tasks/domain/entities/tasks_list_entity.dart';

abstract interface class TasksDatasource {
  Future<TasksListEntity> getTasks(TaskFilterEntity filter);
  Future<ApiMessage> saveTask(TaskUpsertEntity task);
  Future<ApiMessage> deleteTask(DeleteTaskEntity task);
  Future<ApiMessage> setTaskDone(TaskStatusEntity task);
  Future<ApiMessage> saveResponsavel(TaskResponsavelUpsertEntity responsavel);
  Future<ApiMessage> deleteResponsavel(DeleteTaskResponsavelEntity responsavel);
  Future<TaskChartsEntity> getTaskCharts(TaskChartsFilterEntity filter);
}
