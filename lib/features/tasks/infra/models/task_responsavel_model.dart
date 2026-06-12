import 'package:costeira/features/tasks/domain/entities/task_responsavel_entity.dart';

class TaskResponsavelModel extends TaskResponsavelEntity {
  const TaskResponsavelModel({
    super.id,
    required super.nome,
    super.email,
    super.celular,
    super.idLocal,
    super.syncStatus,
    super.pendingAction,
    super.isLocalOnly = false,
  });

  factory TaskResponsavelModel.fromJson(Map<String, dynamic> json) {
    return TaskResponsavelModel(
      id: int.tryParse(json['id']?.toString() ?? ''),
      nome: json['nome']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      celular: json['celular']?.toString() ?? '',
      idLocal: json['idLocal']?.toString(),
      syncStatus: json['syncStatus']?.toString(),
      pendingAction: json['pendingAction']?.toString(),
      isLocalOnly: json['isLocalOnly'] == true,
    );
  }
}
