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
    this.idLocal,
    this.syncStatus,
    this.pendingAction,
    this.isLocalOnly = false,
    this.dataPrazo,
    this.subUsuarioNome,
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
  final String? idLocal;
  final String? syncStatus;
  final String? pendingAction;
  final bool isLocalOnly;
  final String? dataPrazo;
  final String? subUsuarioNome;

  bool get isDone {
    final name = _plainStatus(statusNome);
    return statusId == 3 || name.contains('conclu') || name == 'realizado';
  }

  bool get isOverdue => _plainStatus(statusNome).contains('atras');
}

String _plainStatus(String value) {
  return value
      .toLowerCase()
      .replaceAll('í', 'i')
      .replaceAll('ú', 'u')
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('ó', 'o')
      .replaceAll('ã', 'a')
      .replaceAll('õ', 'o');
}
