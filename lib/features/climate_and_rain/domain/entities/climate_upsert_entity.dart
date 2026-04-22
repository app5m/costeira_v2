class ClimateUpsertEntity {
  const ClimateUpsertEntity({
    this.id,
    this.appUsersId,
    required this.quantidade,
    required this.dataIn,
    required this.dataOut,
  });

  final int? id;
  final int? appUsersId;
  final String quantidade;
  final String dataIn;
  final String dataOut;

  ClimateUpsertEntity copyWith({
    int? id,
    int? appUsersId,
    String? quantidade,
    String? dataIn,
    String? dataOut,
  }) {
    return ClimateUpsertEntity(
      id: id ?? this.id,
      appUsersId: appUsersId ?? this.appUsersId,
      quantidade: quantidade ?? this.quantidade,
      dataIn: dataIn ?? this.dataIn,
      dataOut: dataOut ?? this.dataOut,
    );
  }
}
