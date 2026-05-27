import 'package:costeira/features/movimentacoes/domain/entities/abigeato_charts_entity.dart';

class AbigeatoMonthlyModel extends AbigeatoMonthlyEntity {
  const AbigeatoMonthlyModel({
    required super.year,
    required super.month,
    required super.quantity,
  });

  factory AbigeatoMonthlyModel.fromJson(Map<String, dynamic> json) {
    return AbigeatoMonthlyModel(
      year: int.tryParse(json['ano']?.toString() ?? '') ?? 0,
      month: int.tryParse(json['mes']?.toString() ?? '') ?? 0,
      quantity: int.tryParse(json['quantidade']?.toString() ?? '') ?? 0,
    );
  }
}

class AbigeatoChartsResponseModel extends AbigeatoChartsEntity {
  const AbigeatoChartsResponseModel({
    required super.quantidadeAbigeatos,
    required super.mesAMes,
  });

  factory AbigeatoChartsResponseModel.fromJson(Map<String, dynamic> json) {
    final abigeatos = _extractSection(json, 'abigeatos');
    final monthly = (abigeatos['mes_a_mes'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map(
          (item) =>
              AbigeatoMonthlyModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList(growable: false);

    return AbigeatoChartsResponseModel(
      quantidadeAbigeatos:
          int.tryParse(abigeatos['quantidade_abigeatos']?.toString() ?? '') ??
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
