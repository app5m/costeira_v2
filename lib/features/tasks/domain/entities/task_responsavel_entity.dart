class TaskResponsavelEntity {
  const TaskResponsavelEntity({
    this.id,
    required this.nome,
    this.email = '',
    this.celular = '',
    this.appFazendasId,
    this.idLocal,
    this.syncStatus,
    this.pendingAction,
    this.isLocalOnly = false,
  });

  final int? id;
  final String nome;
  final String email;
  final String celular;
  final int? appFazendasId;
  final String? idLocal;
  final String? syncStatus;
  final String? pendingAction;
  final bool isLocalOnly;
}
