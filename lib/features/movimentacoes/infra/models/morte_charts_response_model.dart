import 'package:costeira/features/movimentacoes/domain/entities/morte_charts_entity.dart';

class MorteMonthlyTotalModel extends MorteMonthlyTotalEntity {
  const MorteMonthlyTotalModel({
    required super.year,
    required super.month,
    required super.quantity,
  });

  factory MorteMonthlyTotalModel.fromJson(Map<String, dynamic> json) {
    return MorteMonthlyTotalModel(
      year: int.tryParse(json['ano']?.toString() ?? '') ?? 0,
      month: int.tryParse(json['mes']?.toString() ?? '') ?? 0,
      quantity: int.tryParse(json['quantidade']?.toString() ?? '') ?? 0,
    );
  }
}

class MorteCauseModel extends MorteCauseEntity {
  const MorteCauseModel({
    required super.cause,
    required super.quantity,
    required super.percent,
  });

  factory MorteCauseModel.fromJson(Map<String, dynamic> json) {
    return MorteCauseModel(
      cause: json['causa']?.toString().trim().isNotEmpty == true
          ? json['causa'].toString().trim()
          : 'Nao informado',
      quantity: int.tryParse(json['quantidade']?.toString() ?? '') ?? 0,
      percent: _chartDouble(json['percentual']),
    );
  }
}

class MorteChartsResponseModel extends MorteChartsEntity {
  const MorteChartsResponseModel({
    required super.totalMesAMes,
    required super.porCausa,
  });

  factory MorteChartsResponseModel.fromJson(Map<String, dynamic> json) {
    final mortes = _extractSection(json, 'mortes');
    final monthly = (mortes['total_mes_a_mes'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map(
          (item) =>
              MorteMonthlyTotalModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList(growable: false);
    final causes = (mortes['por_causa'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map(
          (item) => MorteCauseModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList(growable: false);

    return MorteChartsResponseModel(totalMesAMes: monthly, porCausa: causes);
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
