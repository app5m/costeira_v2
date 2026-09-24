class AnimalLotUpsertEntity {
  const AnimalLotUpsertEntity({
    this.id,
    this.appUsersId,
    this.appFazendasId,
    required this.nome,
  });

  final int? id;
  final int? appUsersId;
  final int? appFazendasId;
  final String nome;

  AnimalLotUpsertEntity copyWith({
    int? id,
    int? appUsersId,
    int? appFazendasId,
    String? nome,
  }) {
    return AnimalLotUpsertEntity(
      id: id ?? this.id,
      appUsersId: appUsersId ?? this.appUsersId,
      appFazendasId: appFazendasId ?? this.appFazendasId,
      nome: nome ?? this.nome,
    );
  }
}
