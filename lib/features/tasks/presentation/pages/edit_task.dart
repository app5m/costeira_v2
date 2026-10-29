import 'package:costeira/features/tasks/presentation/pages/add_tarefa.dart';
import 'package:costeira/features/tasks/domain/entities/task_entity.dart';
import 'package:flutter/material.dart';

class EditTask extends StatelessWidget {
  const EditTask({
    super.key,
    required this.task,
    this.embeddedInWebDialog = false,
  });

  final TaskEntity task;
  final bool embeddedInWebDialog;

  @override
  Widget build(BuildContext context) {
    return AddTask(
      task: task,
      embeddedInWebDialog: embeddedInWebDialog,
    );
  }
}
