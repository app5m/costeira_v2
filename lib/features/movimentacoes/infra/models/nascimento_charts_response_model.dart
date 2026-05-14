import 'package:costeira/features/movimentacoes/domain/entities/nascimento_charts_entity.dart';

class NascimentoMonthlyModel extends NascimentoMonthlyEntity {
  const NascimentoMonthlyModel({
    required super.year,
    required super.month,
    required super.quantity,
  });

  factory NascimentoMonthlyModel.fromJson(Map<String, dynamic> json) {
    return NascimentoMonthlyModel(
      year: int.tryParse(json['ano']?.toString() ?? '') ?? 0,
      month: int.tryParse(json['mes']?.toString() ?? '') ?? 0,
      quantity: int.tryParse(json['quantidade']?.toString() ?? '') ?? 0,
    );
  }
}

class NascimentoChartsResponseModel extends NascimentoChartsEntity {
  const NascimentoChartsResponseModel({
    required super.quantidadeTerneiros,
    required super.mesAMes,
  });

  factory NascimentoChartsResponseModel.fromJson(Map<String, dynamic> json) {
    final nascimentos = _extractSection(json, 'nascimentos');
    final monthly = (nascimentos['mes_a_mes'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map(
          (item) =>
              NascimentoMonthlyModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList(growable: false);

    return NascimentoChartsResponseModel(
      quantidadeTerneiros:
          int.tryParse(nascimentos['quantidade_terneiros']?.toString() ?? '') ??
          0,
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
