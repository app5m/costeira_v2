import 'package:costeira/features/movimentacoes/domain/entities/aborto_charts_entity.dart';

class AbortoMonthlyModel extends AbortoMonthlyEntity {
  const AbortoMonthlyModel({
    required super.year,
    required super.month,
    required super.quantity,
  });

  factory AbortoMonthlyModel.fromJson(Map<String, dynamic> json) {
    return AbortoMonthlyModel(
      year: int.tryParse(json['ano']?.toString() ?? '') ?? 0,
      month: int.tryParse(json['mes']?.toString() ?? '') ?? 0,
      quantity: int.tryParse(json['quantidade']?.toString() ?? '') ?? 0,
    );
  }
}

class AbortoChartsResponseModel extends AbortoChartsEntity {
  const AbortoChartsResponseModel({
    required super.quantidadeAbortos,
    required super.mesAMes,
  });

  factory AbortoChartsResponseModel.fromJson(Map<String, dynamic> json) {
    final abortos = _extractSection(json, 'abortos');
    final monthly = (abortos['mes_a_mes'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map(
          (item) =>
              AbortoMonthlyModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList(growable: false);

    return AbortoChartsResponseModel(
      quantidadeAbortos:
          int.tryParse(abortos['quantidade_abortos']?.toString() ?? '') ?? 0,
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
