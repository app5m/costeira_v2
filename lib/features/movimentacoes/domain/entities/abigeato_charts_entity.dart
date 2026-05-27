class AbigeatoMonthlyEntity {
  const AbigeatoMonthlyEntity({
    required this.year,
    required this.month,
    required this.quantity,
  });

  final int year;
  final int month;
  final int quantity;
}

class AbigeatoChartsEntity {
  const AbigeatoChartsEntity({
    required this.quantidadeAbigeatos,
    required this.mesAMes,
  });

  final int quantidadeAbigeatos;
  final List<AbigeatoMonthlyEntity> mesAMes;

  static const empty = AbigeatoChartsEntity(
    quantidadeAbigeatos: 0,
    mesAMes: [],
  );
}
