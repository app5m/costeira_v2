import 'package:costeira/features/tasks/domain/entities/task_entity.dart';
import 'package:costeira/features/tasks/domain/entities/task_responsavel_entity.dart';

class TasksListEntity {
  const TasksListEntity({
    required this.rows,
    required this.data,
    required this.responsaveis,
  });

  final int rows;
  final List<TaskEntity> data;
  final List<TaskResponsavelEntity> responsaveis;

  TasksListEntity copyWith({
    int? rows,
    List<TaskEntity>? data,
    List<TaskResponsavelEntity>? responsaveis,
  }) {
    return TasksListEntity(
      rows: rows ?? this.rows,
      data: data ?? this.data,
      responsaveis: responsaveis ?? this.responsaveis,
    );
  }
}
