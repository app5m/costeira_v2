class ClimateFilterEntity {
  const ClimateFilterEntity({
    required this.appUsersId,
    this.id,
    this.dataIn,
    this.dataOut,
  });

  final int appUsersId;
  final int? id;
  final String? dataIn;
  final String? dataOut;

  ClimateFilterEntity copyWith({
    int? appUsersId,
    int? id,
    String? dataIn,
    String? dataOut,
  }) {
    return ClimateFilterEntity(
      appUsersId: appUsersId ?? this.appUsersId,
      id: id ?? this.id,
      dataIn: dataIn ?? this.dataIn,
      dataOut: dataOut ?? this.dataOut,
    );
  }
}
