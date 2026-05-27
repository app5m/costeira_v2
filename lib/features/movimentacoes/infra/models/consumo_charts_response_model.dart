import 'package:costeira/features/movimentacoes/domain/entities/consumo_charts_entity.dart';

class ConsumoMonthlyModel extends ConsumoMonthlyEntity {
  const ConsumoMonthlyModel({
    required super.year,
    required super.month,
    required super.quantity,
  });

  factory ConsumoMonthlyModel.fromJson(Map<String, dynamic> json) {
    return ConsumoMonthlyModel(
      year: int.tryParse(json['ano']?.toString() ?? '') ?? 0,
      month: int.tryParse(json['mes']?.toString() ?? '') ?? 0,
      quantity: int.tryParse(json['quantidade']?.toString() ?? '') ?? 0,
    );
  }
}

class ConsumoChartsResponseModel extends ConsumoChartsEntity {
  const ConsumoChartsResponseModel({
    required super.quantidadeConsumos,
    required super.mesAMes,
  });

  factory ConsumoChartsResponseModel.fromJson(Map<String, dynamic> json) {
    final consumos = _extractSection(json, 'consumos');
    final monthly = (consumos['mes_a_mes'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map(
          (item) =>
              ConsumoMonthlyModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList(growable: false);

    return ConsumoChartsResponseModel(
      quantidadeConsumos:
          int.tryParse(consumos['quantidade_consumos']?.toString() ?? '') ?? 0,
      mesAMes: monthly,
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
