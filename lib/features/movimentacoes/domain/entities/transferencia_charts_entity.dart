class TransferenciaMonthlyEntity {
  const TransferenciaMonthlyEntity({
    required this.year,
    required this.month,
    required this.quantity,
  });

  final int year;
  final int month;
  final int quantity;
}

class TransferenciaChartsEntity {
  const TransferenciaChartsEntity({
    required this.quantidadeTransferencias,
    required this.mesAMes,
  });

  final int quantidadeTransferencias;
  final List<TransferenciaMonthlyEntity> mesAMes;

  static const empty = TransferenciaChartsEntity(
    quantidadeTransferencias: 0,
    mesAMes: [],
  );
}
