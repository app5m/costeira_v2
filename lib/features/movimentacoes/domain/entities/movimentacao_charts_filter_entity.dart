class MovimentacaoChartsFilterEntity {
  const MovimentacaoChartsFilterEntity({
    required this.appUsersId,
    required this.month,
  });

  final int appUsersId;
  final DateTime month;

  String get mesAno =>
      '${month.month.toString().padLeft(2, '0')}/${month.year}';
}
