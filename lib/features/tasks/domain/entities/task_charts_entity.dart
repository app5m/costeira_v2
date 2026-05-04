import 'package:costeira/features/tasks/domain/entities/task_responsavel_entity.dart';

class TaskChartsMetricEntity {
  const TaskChartsMetricEntity({
    required this.quantidade,
    required this.percentual,
  });

  final int quantidade;
  final double percentual;
}

class TaskChartsRankingItemEntity {
  const TaskChartsRankingItemEntity({
    required this.responsavel,
    required this.quantidadeRealizadas,
  });

  final TaskResponsavelEntity responsavel;
  final int quantidadeRealizadas;
}

class TaskChartsEntity {
  const TaskChartsEntity({
    required this.programadas,
    required this.atrasadas,
    required this.realizadas,
    required this.rankingFuncionarios,
  });

  final TaskChartsMetricEntity programadas;
  final TaskChartsMetricEntity atrasadas;
  final TaskChartsMetricEntity realizadas;
  final List<TaskChartsRankingItemEntity> rankingFuncionarios;

  static const empty = TaskChartsEntity(
    programadas: TaskChartsMetricEntity(quantidade: 0, percentual: 0),
    atrasadas: TaskChartsMetricEntity(quantidade: 0, percentual: 0),
    realizadas: TaskChartsMetricEntity(quantidade: 0, percentual: 0),
    rankingFuncionarios: [],
  );
}
