class TaskResponsavelEntity {
  const TaskResponsavelEntity({
    this.id,
    required this.nome,
    this.email = '',
    this.celular = '',
  });

  final int? id;
  final String nome;
  final String email;
  final String celular;
}
