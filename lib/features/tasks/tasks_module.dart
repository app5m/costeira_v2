import 'package:costeira/features/tasks/tasks_binds.dart';
import 'package:costeira/features/tasks/tasks_routes.dart';
import 'package:flutter_modular/flutter_modular.dart';

class TasksModule extends Module {
  @override
  void binds(i) => TasksBinds.register(i);

  @override
  void routes(r) => TasksRoutes.register(r);
}
