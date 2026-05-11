class DashboardFilterEntity {
  const DashboardFilterEntity({
    this.appUsersId,
    required this.dataIn,
    required this.dataOut,
  });

  final int? appUsersId;
  final DateTime dataIn;
  final DateTime dataOut;

  DashboardFilterEntity copyWith({
    int? appUsersId,
    DateTime? dataIn,
    DateTime? dataOut,
  }) {
    return DashboardFilterEntity(
      appUsersId: appUsersId ?? this.appUsersId,
      dataIn: dataIn ?? this.dataIn,
      dataOut: dataOut ?? this.dataOut,
    );
  }
}
