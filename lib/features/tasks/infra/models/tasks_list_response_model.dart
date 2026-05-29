import 'package:costeira/features/tasks/domain/entities/tasks_list_entity.dart';
import 'package:costeira/features/tasks/infra/models/task_model.dart';
import 'package:costeira/features/tasks/infra/models/task_responsavel_model.dart';

class TasksListResponseModel extends TasksListEntity {
  const TasksListResponseModel({
    required super.rows,
    required super.data,
    required super.responsaveis,
  });

  factory TasksListResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : <String, dynamic>{};
    final rawTasks = data['lista'];
    final rawResponsaveis = _firstPresentList(data, const [
      'responsaveis',
      'responsáveis',
      'responsÃ¡veis',
    ]);

    final responsaveis = rawResponsaveis
        .whereType<Map>()
        .map(
          (item) =>
              TaskResponsavelModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .where((item) => item.nome.trim().isNotEmpty)
        .toList(growable: false);

    final tasks = rawTasks is List
        ? rawTasks
              .whereType<Map>()
              .map(
                (item) => TaskModel.fromJson(Map<String, dynamic>.from(item)),
              )
              .where((item) => item.descricao.trim().isNotEmpty)
              .toList(growable: false)
        : <TaskModel>[];

    return TasksListResponseModel(
      rows: int.tryParse(json['rows']?.toString() ?? '') ?? tasks.length,
      data: tasks,
      responsaveis: responsaveis,
    );
  }
}

List<dynamic> _firstPresentList(Map<String, dynamic> data, List<String> keys) {
  for (final key in keys) {
    final value = data[key];
    if (value is List) {
      return value;
    }
  }

  return const [];
}
