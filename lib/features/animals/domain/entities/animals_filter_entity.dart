class AnimalsFilterEntity {
  const AnimalsFilterEntity({
    required this.appUsersId,
    this.id,
    this.appAnimaisCategoriasId,
    this.appAnimaisSubcategoriasId,
    this.utBasesRaciaisId,
    this.brinco,
  });

  final int appUsersId;
  final int? id;
  final int? appAnimaisCategoriasId;
  final int? appAnimaisSubcategoriasId;
  final int? utBasesRaciaisId;
  final String? brinco;

  AnimalsFilterEntity copyWith({
    int? appUsersId,
    int? id,
    int? appAnimaisCategoriasId,
    int? appAnimaisSubcategoriasId,
    int? utBasesRaciaisId,
    String? brinco,
  }) {
    return AnimalsFilterEntity(
      appUsersId: appUsersId ?? this.appUsersId,
      id: id ?? this.id,
      appAnimaisCategoriasId:
          appAnimaisCategoriasId ?? this.appAnimaisCategoriasId,
      appAnimaisSubcategoriasId:
          appAnimaisSubcategoriasId ?? this.appAnimaisSubcategoriasId,
      utBasesRaciaisId: utBasesRaciaisId ?? this.utBasesRaciaisId,
      brinco: brinco ?? this.brinco,
    );
  }
}
