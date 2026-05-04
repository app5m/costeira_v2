class TaskFilterEntity {
  const TaskFilterEntity({
    this.appUsersId,
    this.month,
    this.dataIn,
    this.dataOut,
    this.urgencia,
    this.status,
  });

  final int? appUsersId;
  final DateTime? month;
  final DateTime? dataIn;
  final DateTime? dataOut;
  final int? urgencia;
  final int? status;

  TaskFilterEntity copyWith({
    int? appUsersId,
    DateTime? month,
    DateTime? dataIn,
    DateTime? dataOut,
    int? urgencia,
    int? status,
    bool clearDateRange = false,
  }) {
    return TaskFilterEntity(
      appUsersId: appUsersId ?? this.appUsersId,
      month: month ?? this.month,
      dataIn: clearDateRange ? null : dataIn ?? this.dataIn,
      dataOut: clearDateRange ? null : dataOut ?? this.dataOut,
      urgencia: urgencia ?? this.urgencia,
      status: status ?? this.status,
    );
  }

  TaskFilterEntity clearAdvanced() =>
      TaskFilterEntity(appUsersId: appUsersId, month: month);
}
