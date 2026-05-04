import 'package:costeira/features/tasks/domain/entities/task_charts_entity.dart';
import 'package:costeira/features/tasks/infra/models/task_responsavel_model.dart';

class TaskChartsResponseModel extends TaskChartsEntity {
  const TaskChartsResponseModel({
    required super.programadas,
    required super.atrasadas,
    required super.realizadas,
    required super.rankingFuncionarios,
  });

  factory TaskChartsResponseModel.fromJson(Map<String, dynamic> json) {
    final ranking =
        (json['ranking_execucao_funcionarios'] as List<dynamic>? ?? const [])
            .whereType<Map>()
            .map(
              (item) => _rankingFromJson(Map<String, dynamic>.from(item)),
            )
            .toList(growable: false);

    return TaskChartsResponseModel(
      programadas: _metricFromJson(json['programadas']),
      atrasadas: _metricFromJson(json['atrasadas']),
      realizadas: _metricFromJson(json['realizadas']),
      rankingFuncionarios: ranking,
    );
  }
}

TaskChartsMetricEntity _metricFromJson(dynamic raw) {
  if (raw is! Map) {
    return const TaskChartsMetricEntity(quantidade: 0, percentual: 0);
  }
  final map = Map<String, dynamic>.from(raw);
  return TaskChartsMetricEntity(
    quantidade: int.tryParse(map['quantidade']?.toString() ?? '') ?? 0,
    percentual: double.tryParse(map['percentual']?.toString() ?? '') ?? 0,
  );
}

TaskChartsRankingItemEntity _rankingFromJson(Map<String, dynamic> json) {
  final responsavelMap = json['responsavel'] is Map
      ? Map<String, dynamic>.from(json['responsavel'] as Map)
      : <String, dynamic>{};

  return TaskChartsRankingItemEntity(
    responsavel: TaskResponsavelModel.fromJson(responsavelMap),
    quantidadeRealizadas:
        int.tryParse(json['quantidade_realizadas']?.toString() ?? '') ?? 0,
  );
}
