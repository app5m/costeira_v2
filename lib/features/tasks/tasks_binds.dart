import 'package:costeira/features/tasks/domain/repository/tasks_datasource.dart';
import 'package:costeira/features/tasks/domain/usecases/delete_task_responsavel_usecase.dart';
import 'package:costeira/features/tasks/domain/usecases/delete_task_usecase.dart';
import 'package:costeira/features/tasks/domain/usecases/get_task_charts_usecase.dart';
import 'package:costeira/features/tasks/domain/usecases/get_task_responsaveis_usecase.dart';
import 'package:costeira/features/tasks/domain/usecases/get_tasks_usecase.dart';
import 'package:costeira/features/tasks/domain/usecases/save_task_responsavel_usecase.dart';
import 'package:costeira/features/tasks/domain/usecases/save_task_usecase.dart';
import 'package:costeira/features/tasks/domain/usecases/set_task_done_usecase.dart';
import 'package:costeira/features/tasks/infra/data/tasks_datasource_impl.dart';
import 'package:costeira/features/tasks/presentation/controllers/get_task_charts_controller.dart';
import 'package:costeira/features/tasks/presentation/controllers/list_task_responsaveis_controller.dart';
import 'package:costeira/features/tasks/presentation/controllers/list_tasks_controller.dart';
import 'package:costeira/features/tasks/presentation/controllers/save_task_controller.dart';
import 'package:costeira/features/tasks/presentation/controllers/save_task_responsavel_controller.dart';
import 'package:flutter_modular/flutter_modular.dart';

class TasksBinds {
  static void register(Injector i) {
    i.addLazySingleton<TasksDatasource>(TasksDatasourceImpl.new);
    i.addLazySingleton(GetTasksUsecase.new);
    i.addLazySingleton(SaveTaskUsecase.new);
    i.addLazySingleton(DeleteTaskUsecase.new);
    i.addLazySingleton(SetTaskDoneUsecase.new);
    i.addLazySingleton(GetTaskResponsaveisUsecase.new);
    i.addLazySingleton(SaveTaskResponsavelUsecase.new);
    i.addLazySingleton(DeleteTaskResponsavelUsecase.new);
    i.addLazySingleton(GetTaskChartsUsecase.new);
    i.add<ListTasksController>(ListTasksController.new);
    i.add<ListTaskResponsaveisController>(ListTaskResponsaveisController.new);
    i.add<SaveTaskController>(SaveTaskController.new);
    i.add<SaveTaskResponsavelController>(SaveTaskResponsavelController.new);
    i.add<GetTaskChartsController>(GetTaskChartsController.new);
  }
}
