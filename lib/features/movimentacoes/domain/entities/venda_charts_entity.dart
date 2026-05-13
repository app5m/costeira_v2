class VendaMonthlyValueEntity {
  const VendaMonthlyValueEntity({
    required this.year,
    required this.month,
    required this.value,
    required this.valueRaw,
  });

  final int year;
  final int month;
  final String value;
  final double valueRaw;
}

class VendaChartsEntity {
  const VendaChartsEntity({
    required this.totalVendido,
    required this.kgTotais,
    required this.precoMedio,
    required this.totalCabecas,
    required this.valorTotalMesAMes,
  });

  final String totalVendido;
  final double kgTotais;
  final String precoMedio;
  final int totalCabecas;
  final List<VendaMonthlyValueEntity> valorTotalMesAMes;

  static const empty = VendaChartsEntity(
    totalVendido: 'R\$ 0,00',
    kgTotais: 0,
    precoMedio: 'R\$ 0,00',
    totalCabecas: 0,
    valorTotalMesAMes: [],
  );
}
