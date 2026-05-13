class MorteMonthlyTotalEntity {
  const MorteMonthlyTotalEntity({
    required this.year,
    required this.month,
    required this.quantity,
  });

  final int year;
  final int month;
  final int quantity;
}

class MorteCauseEntity {
  const MorteCauseEntity({
    required this.cause,
    required this.quantity,
    required this.percent,
  });

  final String cause;
  final int quantity;
  final double percent;
}

class MorteChartsEntity {
  const MorteChartsEntity({required this.totalMesAMes, required this.porCausa});

  final List<MorteMonthlyTotalEntity> totalMesAMes;
  final List<MorteCauseEntity> porCausa;

  static const empty = MorteChartsEntity(totalMesAMes: [], porCausa: []);
}
