import 'package:costeira/features/tasks/domain/entities/task_entity.dart';
import 'package:costeira/features/tasks/infra/models/task_date_info_model.dart';
import 'package:costeira/features/tasks/infra/models/task_responsavel_model.dart';

class TaskModel extends TaskEntity {
  const TaskModel({
    required super.id,
    required super.appUsersId,
    super.responsavelId,
    required super.tipo,
    required super.descricao,
    super.obs,
    required super.urgenciaId,
    required super.urgenciaNome,
    required super.urgenciaCor,
    required super.statusId,
    required super.statusNome,
    super.responsavel,
    super.datas,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    final urgencia = _asMap(json['urgencia']);
    final status = _asMap(json['status']);
    final responsavelMap = _asMap(json['responsavel']);
    final datas = json['datas'] is List ? json['datas'] as List : const [];

    return TaskModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      appUsersId: int.tryParse(json['app_users_id']?.toString() ?? '') ?? 0,
      responsavelId: int.tryParse(
        json['app_tarefas_responsaveis_id']?.toString() ?? '',
      ),
      tipo: int.tryParse(json['tipo']?.toString() ?? '') ?? 1,
      descricao: json['descricao']?.toString() ?? '',
      obs: json['obs']?.toString() ?? '',
      urgenciaId: int.tryParse(urgencia['id']?.toString() ?? '') ?? 0,
      urgenciaNome: urgencia['nome']?.toString() ?? '',
      urgenciaCor: urgencia['cor']?.toString() ?? '#8C8C8C',
      statusId: int.tryParse(status['id']?.toString() ?? '') ?? 0,
      statusNome: status['nome']?.toString() ?? '',
      responsavel: responsavelMap.isEmpty
          ? null
          : TaskResponsavelModel.fromJson(responsavelMap),
      datas: datas
          .whereType<Map>()
          .map(
            (item) =>
                TaskDateInfoModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(growable: false),
    );
  }
}

Map<String, dynamic> _asMap(dynamic data) {
  return data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{};
}
