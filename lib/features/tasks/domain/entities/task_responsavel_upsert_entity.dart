class TaskResponsavelUpsertEntity {
  const TaskResponsavelUpsertEntity({
    this.id,
    required this.appUsersId,
    required this.nome,
    required this.email,
    required this.celular,
  });

  final int? id;
  final int appUsersId;
  final String nome;
  final String email;
  final String celular;
}
