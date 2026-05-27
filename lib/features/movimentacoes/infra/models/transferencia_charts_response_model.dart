import 'package:costeira/features/movimentacoes/domain/entities/transferencia_charts_entity.dart';

class TransferenciaMonthlyModel extends TransferenciaMonthlyEntity {
  const TransferenciaMonthlyModel({
    required super.year,
    required super.month,
    required super.quantity,
  });

  factory TransferenciaMonthlyModel.fromJson(Map<String, dynamic> json) {
    return TransferenciaMonthlyModel(
      year: int.tryParse(json['ano']?.toString() ?? '') ?? 0,
      month: int.tryParse(json['mes']?.toString() ?? '') ?? 0,
      quantity: int.tryParse(json['quantidade']?.toString() ?? '') ?? 0,
    );
  }
}

class TransferenciaChartsResponseModel extends TransferenciaChartsEntity {
  const TransferenciaChartsResponseModel({
    required super.quantidadeTransferencias,
    required super.mesAMes,
  });

  factory TransferenciaChartsResponseModel.fromJson(Map<String, dynamic> json) {
    final transferencias = _extractSection(json, 'transferencias');
    final monthly = (transferencias['mes_a_mes'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map(
          (item) => TransferenciaMonthlyModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList(growable: false);

    return TransferenciaChartsResponseModel(
      quantidadeTransferencias:
          int.tryParse(
            transferencias['quantidade_transferencias']?.toString() ?? '',
          ) ??
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
