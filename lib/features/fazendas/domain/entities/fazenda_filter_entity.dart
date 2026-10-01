class FazendaFilterEntity {
  const FazendaFilterEntity({
    required this.appUsersId,
    this.id,
    this.nome,
    this.mesmoTitular = false,
  });

  final int appUsersId;
  final int? id;
  final String? nome;
  final bool mesmoTitular;
}
