class AnimalLotUpsertEntity {
  const AnimalLotUpsertEntity({this.id, this.appUsersId, required this.nome});

  final int? id;
  final int? appUsersId;
  final String nome;

  AnimalLotUpsertEntity copyWith({int? id, int? appUsersId, String? nome}) {
    return AnimalLotUpsertEntity(
      id: id ?? this.id,
      appUsersId: appUsersId ?? this.appUsersId,
      nome: nome ?? this.nome,
    );
  }
}
