class CompraMonthlyValueEntity {
  const CompraMonthlyValueEntity({
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

class CompraChartsEntity {
  const CompraChartsEntity({
    required this.totalComprado,
    required this.kgTotais,
    required this.precoMedio,
    required this.totalCabecas,
    required this.valorTotalMesAMes,
  });

  final String totalComprado;
  final double kgTotais;
  final String precoMedio;
  final int totalCabecas;
  final List<CompraMonthlyValueEntity> valorTotalMesAMes;

  static const empty = CompraChartsEntity(
    totalComprado: 'R\$ 0,00',
    kgTotais: 0,
    precoMedio: 'R\$ 0,00',
    totalCabecas: 0,
    valorTotalMesAMes: [],
  );
}
