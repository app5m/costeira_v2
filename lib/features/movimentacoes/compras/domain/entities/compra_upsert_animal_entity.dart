class CompraUpsertAnimalEntity {
  const CompraUpsertAnimalEntity({
    required this.appAnimaisCategoriasId,
    this.appAnimaisSubcategoriasId,
    this.utBasesRaciaisId,
    required this.sexo,
    required this.brinco,
    required this.pesoTotal,
  });

  final int appAnimaisCategoriasId;
  final int? appAnimaisSubcategoriasId;
  final int? utBasesRaciaisId;
  final int sexo;
  final String brinco;
  final String pesoTotal;

  CompraUpsertAnimalEntity copyWith({
    int? appAnimaisCategoriasId,
    int? appAnimaisSubcategoriasId,
    int? utBasesRaciaisId,
    int? sexo,
    String? brinco,
    String? pesoTotal,
  }) {
    return CompraUpsertAnimalEntity(
      appAnimaisCategoriasId:
          appAnimaisCategoriasId ?? this.appAnimaisCategoriasId,
      appAnimaisSubcategoriasId:
          appAnimaisSubcategoriasId ?? this.appAnimaisSubcategoriasId,
      utBasesRaciaisId: utBasesRaciaisId ?? this.utBasesRaciaisId,
      sexo: sexo ?? this.sexo,
      brinco: brinco ?? this.brinco,
      pesoTotal: pesoTotal ?? this.pesoTotal,
    );
  }
}
