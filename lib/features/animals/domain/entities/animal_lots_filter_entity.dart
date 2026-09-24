class AnimalLotsFilterEntity {
  const AnimalLotsFilterEntity({
    required this.appUsersId,
    this.appFazendasId,
    this.id,
    this.nome,
  });

  final int appUsersId;
  final int? appFazendasId;
  final int? id;
  final String? nome;
}
