class AbortoMonthlyEntity {
  const AbortoMonthlyEntity({
    required this.year,
    required this.month,
    required this.quantity,
  });

  final int year;
  final int month;
  final int quantity;
}

class AbortoChartsEntity {
  const AbortoChartsEntity({
    required this.quantidadeAbortos,
    required this.mesAMes,
  });

  final int quantidadeAbortos;
  final List<AbortoMonthlyEntity> mesAMes;

  static const empty = AbortoChartsEntity(quantidadeAbortos: 0, mesAMes: []);
}
