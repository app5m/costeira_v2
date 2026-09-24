class AnimalsFilterEntity {
  const AnimalsFilterEntity({
    required this.appUsersId,
    this.id,
    this.appFazendasId,
    this.appPotreirosId,
    this.appAnimaisLotesId,
    this.appAnimaisCategoriasId,
    this.appAnimaisSubcategoriasId,
    this.utBasesRaciaisId,
    this.brinco,
    this.brincoOnly = false,
  });

  final int appUsersId;
  final int? id;
  final int? appFazendasId;
  final int? appPotreirosId;
  final int? appAnimaisLotesId;
  final int? appAnimaisCategoriasId;
  final int? appAnimaisSubcategoriasId;
  final int? utBasesRaciaisId;
  final String? brinco;
  final bool brincoOnly;

  AnimalsFilterEntity copyWith({
    int? appUsersId,
    int? id,
    int? appFazendasId,
    int? appPotreirosId,
    int? appAnimaisLotesId,
    int? appAnimaisCategoriasId,
    int? appAnimaisSubcategoriasId,
    int? utBasesRaciaisId,
    String? brinco,
    bool? brincoOnly,
  }) {
    return AnimalsFilterEntity(
      appUsersId: appUsersId ?? this.appUsersId,
      id: id ?? this.id,
      appFazendasId: appFazendasId ?? this.appFazendasId,
      appPotreirosId: appPotreirosId ?? this.appPotreirosId,
      appAnimaisLotesId: appAnimaisLotesId ?? this.appAnimaisLotesId,
      appAnimaisCategoriasId:
          appAnimaisCategoriasId ?? this.appAnimaisCategoriasId,
      appAnimaisSubcategoriasId:
          appAnimaisSubcategoriasId ?? this.appAnimaisSubcategoriasId,
      utBasesRaciaisId: utBasesRaciaisId ?? this.utBasesRaciaisId,
      brinco: brinco ?? this.brinco,
      brincoOnly: brincoOnly ?? this.brincoOnly,
    );
  }
}
