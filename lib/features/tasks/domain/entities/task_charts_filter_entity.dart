class TaskChartsFilterEntity {
  const TaskChartsFilterEntity({this.appUsersId, this.month});

  final int? appUsersId;
  final DateTime? month;

  TaskChartsFilterEntity copyWith({int? appUsersId, DateTime? month}) {
    return TaskChartsFilterEntity(
      appUsersId: appUsersId ?? this.appUsersId,
      month: month ?? this.month,
    );
  }
}
