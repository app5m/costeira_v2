import 'package:costeira/features/movimentacoes/domain/entities/troca_categoria_charts_entity.dart';

class TrocaCategoriaMonthlyModel extends TrocaCategoriaMonthlyEntity {
  const TrocaCategoriaMonthlyModel({
    required super.year,
    required super.month,
    required super.quantity,
  });

  factory TrocaCategoriaMonthlyModel.fromJson(Map<String, dynamic> json) {
    return TrocaCategoriaMonthlyModel(
      year: int.tryParse(json['ano']?.toString() ?? '') ?? 0,
      month: int.tryParse(json['mes']?.toString() ?? '') ?? 0,
      quantity: int.tryParse(json['quantidade']?.toString() ?? '') ?? 0,
    );
  }
}

class TrocaCategoriaChartsResponseModel extends TrocaCategoriaChartsEntity {
  const TrocaCategoriaChartsResponseModel({
    required super.quantidadeTrocas,
    required super.mesAMes,
  });

  factory TrocaCategoriaChartsResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final trocaCategoria = _extractSection(json, 'troca_categoria');
    final monthly = (trocaCategoria['mes_a_mes'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map(
          (item) => TrocaCategoriaMonthlyModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList(growable: false);

    return TrocaCategoriaChartsResponseModel(
      quantidadeTrocas:
          int.tryParse(trocaCategoria['quantidade_trocas']?.toString() ?? '') ??
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
