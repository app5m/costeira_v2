class ClimateMonthlyRainPointEntity {
  const ClimateMonthlyRainPointEntity({
    required this.label,
    required this.value,
  });

  final String label;
  final double value;
}

class ClimateYearComparisonEntity {
  const ClimateYearComparisonEntity({required this.year, required this.points});

  final String year;
  final List<ClimateMonthlyRainPointEntity> points;
}

class ClimateChartsEntity {
  const ClimateChartsEntity({
    required this.totalChuvaAcumulada,
    required this.totalChuvaUltimoMes,
    required this.chuvaMesAMes,
    required this.comparativoUltimos2Anos,
  });

  final double totalChuvaAcumulada;
  final double totalChuvaUltimoMes;
  final List<ClimateMonthlyRainPointEntity> chuvaMesAMes;
  final List<ClimateYearComparisonEntity> comparativoUltimos2Anos;
}
