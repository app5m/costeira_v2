class TrocaCategoriaMonthlyEntity {
  const TrocaCategoriaMonthlyEntity({
    required this.year,
    required this.month,
    required this.quantity,
  });

  final int year;
  final int month;
  final int quantity;
}

class TrocaCategoriaChartsEntity {
  const TrocaCategoriaChartsEntity({
    required this.quantidadeTrocas,
    required this.mesAMes,
  });

  final int quantidadeTrocas;
  final List<TrocaCategoriaMonthlyEntity> mesAMes;

  static const empty = TrocaCategoriaChartsEntity(
    quantidadeTrocas: 0,
    mesAMes: [],
  );
}
