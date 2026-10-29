class TaskResponsavelUpsertEntity {
  const TaskResponsavelUpsertEntity({
    this.id,
    required this.appUsersId,
    required this.appFazendasId,
    required this.nome,
    required this.email,
    required this.celular,
  });

  final int? id;
  final int appUsersId;
  final int appFazendasId;
  final String nome;
  final String email;
  final String celular;
}
