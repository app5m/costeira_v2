class ClimateUpsertEntity {
  const ClimateUpsertEntity({
    this.id,
    this.appUsersId,
    this.appFazendasId,
    required this.quantidade,
    required this.dataIn,
    required this.dataOut,
  });

  final int? id;
  final int? appUsersId;
  final int? appFazendasId;
  final String quantidade;
  final String dataIn;
  final String dataOut;

  ClimateUpsertEntity copyWith({
    int? id,
    int? appUsersId,
    int? appFazendasId,
    String? quantidade,
    String? dataIn,
    String? dataOut,
  }) {
    return ClimateUpsertEntity(
      id: id ?? this.id,
      appUsersId: appUsersId ?? this.appUsersId,
      appFazendasId: appFazendasId ?? this.appFazendasId,
      quantidade: quantidade ?? this.quantidade,
      dataIn: dataIn ?? this.dataIn,
      dataOut: dataOut ?? this.dataOut,
    );
  }
}
