import 'package:costeira/features/tasks/domain/entities/task_date_info_entity.dart';
import 'package:costeira/features/tasks/domain/entities/task_responsavel_entity.dart';

class TaskEntity {
  const TaskEntity({
    required this.id,
    required this.appUsersId,
    this.responsavelId,
    required this.tipo,
    required this.descricao,
    this.obs = '',
    required this.urgenciaId,
    required this.urgenciaNome,
    required this.urgenciaCor,
    required this.statusId,
    required this.statusNome,
    this.responsavel,
    this.datas = const [],
  });

  final int id;
  final int appUsersId;
  final int? responsavelId;
  final int tipo;
  final String descricao;
  final String obs;
  final int urgenciaId;
  final String urgenciaNome;
  final String urgenciaCor;
  final int statusId;
  final String statusNome;
  final TaskResponsavelEntity? responsavel;
  final List<TaskDateInfoEntity> datas;

  bool get isDone => statusId == 3 || statusNome.toLowerCase() == 'realizado';
}
