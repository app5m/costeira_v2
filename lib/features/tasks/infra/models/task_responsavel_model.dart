import 'package:costeira/features/tasks/domain/entities/task_responsavel_entity.dart';

class TaskResponsavelModel extends TaskResponsavelEntity {
  const TaskResponsavelModel({
    super.id,
    required super.nome,
    super.email,
    super.celular,
  });

  factory TaskResponsavelModel.fromJson(Map<String, dynamic> json) {
    return TaskResponsavelModel(
      id: int.tryParse(json['id']?.toString() ?? ''),
      nome: json['nome']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      celular: json['celular']?.toString() ?? '',
    );
  }
}
