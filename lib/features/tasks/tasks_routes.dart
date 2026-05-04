import 'package:costeira/features/tasks/domain/entities/task_entity.dart';
import 'package:costeira/features/tasks/domain/entities/task_responsavel_entity.dart';
import 'package:costeira/features/tasks/presentation/pages/add_tarefa.dart';
import 'package:costeira/features/tasks/presentation/pages/add_task_responsavel.dart';
import 'package:costeira/features/tasks/presentation/pages/detail_task.dart';
import 'package:costeira/features/tasks/presentation/pages/detail_task_responsavel.dart';
import 'package:costeira/features/tasks/presentation/pages/edit_task.dart';
import 'package:costeira/features/tasks/presentation/pages/task_page.dart';
import 'package:flutter_modular/flutter_modular.dart';

class TasksRoutes {
  static void register(RouteManager r) {
    r.child('/', child: (_) => const TaskPage());
    r.child('/add-task-page', child: (_) => const AddTask());
    r.child(
      '/edit-task-page',
      child: (_) {
        final task = Modular.args.data as TaskEntity;
        return EditTask(task: task);
      },
    );
    r.child(
      '/detail-task-page',
      child: (_) {
        final task = Modular.args.data as TaskEntity;
        return DetailTask(task: task);
      },
    );
    r.child('/add-responsavel-page', child: (_) => const AddTaskResponsavel());
    r.child(
      '/detail-responsavel-page',
      child: (_) {
        final responsavel = Modular.args.data as TaskResponsavelEntity;
        return DetailTaskResponsavel(responsavel: responsavel);
      },
    );
  }
}
