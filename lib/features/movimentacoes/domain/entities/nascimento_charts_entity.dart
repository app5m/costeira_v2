class NascimentoMonthlyEntity {
  const NascimentoMonthlyEntity({
    required this.year,
    required this.month,
    required this.quantity,
  });

  final int year;
  final int month;
  final int quantity;
}

class NascimentoChartsEntity {
  const NascimentoChartsEntity({
    required this.quantidadeTerneiros,
    required this.mesAMes,
  });

  final int quantidadeTerneiros;
  final List<NascimentoMonthlyEntity> mesAMes;

  static const empty = NascimentoChartsEntity(
    quantidadeTerneiros: 0,
    mesAMes: [],
  );
}
