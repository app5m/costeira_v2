class AnimalUpsertEntity {
  const AnimalUpsertEntity({
    this.id,
    this.appUsersId,
    required this.appAnimaisCategoriasId,
    this.appAnimaisSubcategoriasId,
    this.utBasesRaciaisId,
    this.appAnimaisLotesId,
    this.appPotreirosId,
    required this.sexo,
    this.brinco,
    this.peso,
    this.obs,
    this.status,
  });

  final int? id;
  final int? appUsersId;
  final int appAnimaisCategoriasId;
  final int? appAnimaisSubcategoriasId;
  final int? utBasesRaciaisId;
  final int? appAnimaisLotesId;
  final int? appPotreirosId;
  final int sexo;
  final String? brinco;
  final String? peso;
  final String? obs;
  final String? status;

  AnimalUpsertEntity copyWith({
    int? id,
    int? appUsersId,
    int? appAnimaisCategoriasId,
    int? appAnimaisSubcategoriasId,
    int? utBasesRaciaisId,
    int? appAnimaisLotesId,
    int? appPotreirosId,
    int? sexo,
    String? brinco,
    String? peso,
    String? obs,
    String? status,
  }) {
    return AnimalUpsertEntity(
      id: id ?? this.id,
      appUsersId: appUsersId ?? this.appUsersId,
      appAnimaisCategoriasId:
          appAnimaisCategoriasId ?? this.appAnimaisCategoriasId,
      appAnimaisSubcategoriasId:
          appAnimaisSubcategoriasId ?? this.appAnimaisSubcategoriasId,
      utBasesRaciaisId: utBasesRaciaisId ?? this.utBasesRaciaisId,
      appAnimaisLotesId: appAnimaisLotesId ?? this.appAnimaisLotesId,
      appPotreirosId: appPotreirosId ?? this.appPotreirosId,
      sexo: sexo ?? this.sexo,
      brinco: brinco ?? this.brinco,
      peso: peso ?? this.peso,
      obs: obs ?? this.obs,
      status: status ?? this.status,
    );
  }
}
