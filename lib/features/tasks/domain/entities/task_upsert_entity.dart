class TaskUpsertEntity {
  const TaskUpsertEntity({
    this.id,
    required this.appUsersId,
    this.responsavelId,
    required this.tipo,
    required this.descricao,
    required this.obs,
    required this.urgencia,
    required this.datas,
  });

  final int? id;
  final int appUsersId;
  final int? responsavelId;
  final int tipo;
  final String descricao;
  final String obs;
  final int urgencia;
  final List<String> datas;
}
