class ConsumoMonthlyEntity {
  const ConsumoMonthlyEntity({
    required this.year,
    required this.month,
    required this.quantity,
  });

  final int year;
  final int month;
  final int quantity;
}

class ConsumoChartsEntity {
  const ConsumoChartsEntity({
    required this.quantidadeConsumos,
    required this.mesAMes,
  });

  final int quantidadeConsumos;
  final List<ConsumoMonthlyEntity> mesAMes;

  static const empty = ConsumoChartsEntity(quantidadeConsumos: 0, mesAMes: []);
}
