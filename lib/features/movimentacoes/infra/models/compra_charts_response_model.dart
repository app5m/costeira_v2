import 'package:costeira/features/movimentacoes/domain/entities/compra_charts_entity.dart';

class CompraMonthlyValueModel extends CompraMonthlyValueEntity {
  const CompraMonthlyValueModel({
    required super.year,
    required super.month,
    required super.value,
    required super.valueRaw,
  });

  factory CompraMonthlyValueModel.fromJson(Map<String, dynamic> json) {
    return CompraMonthlyValueModel(
      year: int.tryParse(json['ano']?.toString() ?? '') ?? 0,
      month: int.tryParse(json['mes']?.toString() ?? '') ?? 0,
      value: json['valor_total']?.toString().trim() ?? 'R\$ 0,00',
      valueRaw: _chartDouble(json['valor_total_raw']),
    );
  }
}

class CompraChartsResponseModel extends CompraChartsEntity {
  const CompraChartsResponseModel({
    required super.totalComprado,
    required super.kgTotais,
    required super.precoMedio,
    required super.totalCabecas,
    required super.valorTotalMesAMes,
  });

  factory CompraChartsResponseModel.fromJson(Map<String, dynamic> json) {
    final compras = _extractCompras(json);
    final monthly =
        (compras['valor_total_mes_a_mes'] as List<dynamic>? ?? const [])
            .whereType<Map>()
            .map(
              (item) => CompraMonthlyValueModel.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList(growable: false);

    return CompraChartsResponseModel(
      totalComprado: compras['total_comprado']?.toString().trim() ?? 'R\$ 0,00',
      kgTotais: _chartDouble(compras['kg_totais']),
      precoMedio: compras['preco_medio']?.toString().trim() ?? 'R\$ 0,00',
      totalCabecas:
          int.tryParse(compras['total_cabecas']?.toString() ?? '') ?? 0,
      valorTotalMesAMes: monthly,
    );
  }

  static Map<String, dynamic> _extractCompras(Map<String, dynamic> wrapper) {
    final data = wrapper['data'] as List<dynamic>? ?? const [];
    final first = data.whereType<Map>().cast<Map>().firstOrNull;
    if (first == null) {
      return const {};
    }
    final compras = first['compras'];
    if (compras is Map<String, dynamic>) {
      return compras;
    }
    if (compras is Map) {
      return Map<String, dynamic>.from(compras);
    }
    return const {};
  }
}

double _chartDouble(dynamic value) {
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value?.toString() ?? '') ?? 0;
}
