import 'package:costeira/features/movimentacoes/domain/entities/venda_charts_entity.dart';

class VendaMonthlyValueModel extends VendaMonthlyValueEntity {
  const VendaMonthlyValueModel({
    required super.year,
    required super.month,
    required super.value,
    required super.valueRaw,
  });

  factory VendaMonthlyValueModel.fromJson(Map<String, dynamic> json) {
    return VendaMonthlyValueModel(
      year: int.tryParse(json['ano']?.toString() ?? '') ?? 0,
      month: int.tryParse(json['mes']?.toString() ?? '') ?? 0,
      value: json['valor_total']?.toString().trim() ?? 'R\$ 0,00',
      valueRaw: _chartDouble(json['valor_total_raw']),
    );
  }
}

class VendaChartsResponseModel extends VendaChartsEntity {
  const VendaChartsResponseModel({
    required super.totalVendido,
    required super.kgTotais,
    required super.precoMedio,
    required super.totalCabecas,
    required super.valorTotalMesAMes,
  });

  factory VendaChartsResponseModel.fromJson(Map<String, dynamic> json) {
    final vendas = _extractSection(json, 'vendas');
    final monthly =
        (vendas['valor_total_mes_a_mes'] as List<dynamic>? ?? const [])
            .whereType<Map>()
            .map(
              (item) => VendaMonthlyValueModel.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList(growable: false);

    return VendaChartsResponseModel(
      totalVendido: vendas['total_vendido']?.toString().trim() ?? 'R\$ 0,00',
      kgTotais: _chartDouble(vendas['kg_totais']),
      precoMedio: vendas['preco_medio']?.toString().trim() ?? 'R\$ 0,00',
      totalCabecas:
          int.tryParse(vendas['total_cabecas']?.toString() ?? '') ?? 0,
      valorTotalMesAMes: monthly,
    );
  }
}

Map<String, dynamic> _extractSection(Map<String, dynamic> wrapper, String key) {
  final data = wrapper['data'] as List<dynamic>? ?? const [];
  final first = data.whereType<Map>().cast<Map>().firstOrNull;
  if (first == null) {
    return const {};
  }
  final section = first[key];
  if (section is Map<String, dynamic>) {
    return section;
  }
  if (section is Map) {
    return Map<String, dynamic>.from(section);
  }
  return const {};
}

double _chartDouble(dynamic value) {
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value?.toString() ?? '') ?? 0;
}
