class TaskChartsFilterEntity {
  const TaskChartsFilterEntity({
    this.appUsersId,
    this.appFazendasId,
    this.month,
  });

  final int? appUsersId;
  final int? appFazendasId;
  final DateTime? month;

  TaskChartsFilterEntity copyWith({
    int? appUsersId,
    int? appFazendasId,
    DateTime? month,
  }) {
    return TaskChartsFilterEntity(
      appUsersId: appUsersId ?? this.appUsersId,
      appFazendasId: appFazendasId ?? this.appFazendasId,
      month: month ?? this.month,
    );
  }
}
