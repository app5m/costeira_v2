class ClimateFilterEntity {
  const ClimateFilterEntity({
    required this.appUsersId,
    required this.appFazendasId,
    this.id,
    this.dataIn,
    this.dataOut,
  });

  final int appUsersId;
  final int appFazendasId;
  final int? id;
  final String? dataIn;
  final String? dataOut;

  ClimateFilterEntity copyWith({
    int? appUsersId,
    int? appFazendasId,
    int? id,
    String? dataIn,
    String? dataOut,
  }) {
    return ClimateFilterEntity(
      appUsersId: appUsersId ?? this.appUsersId,
      appFazendasId: appFazendasId ?? this.appFazendasId,
      id: id ?? this.id,
      dataIn: dataIn ?? this.dataIn,
      dataOut: dataOut ?? this.dataOut,
    );
  }
}
