class TaskStatusEntity {
  const TaskStatusEntity({
    required this.appUsersId,
    required this.appFazendasId,
    required this.id,
    required this.status,
  });

  static const int pendente = 1;
  static const int concluido = 3;

  final int appUsersId;
  final int appFazendasId;
  final int id;
  final int status;
}
