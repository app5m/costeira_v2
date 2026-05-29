import 'package:costeira/features/climate_and_rain/domain/entities/climate_charts_entity.dart';

class ClimateMonthlyRainPointModel extends ClimateMonthlyRainPointEntity {
  const ClimateMonthlyRainPointModel({
    required super.label,
    required super.value,
  });

  factory ClimateMonthlyRainPointModel.fromJson(Map<String, dynamic> json) {
    return ClimateMonthlyRainPointModel(
      label: _resolveLabel(json),
      value: _resolveValue(json),
    );
  }

  static String _resolveLabel(Map<String, dynamic> json) {
    const candidates = [
      'label',
      'mes',
      'month',
      'mes_nome',
      'nome',
      'dia',
      'x',
    ];

    for (final key in candidates) {
      final value = json[key]?.toString().trim() ?? '';
      if (value.isNotEmpty) {
        return value;
      }
    }

    return '';
  }

  static double _resolveValue(Map<String, dynamic> json) {
    const candidates = [
      'valor',
      'value',
      'quantidade',
      'total',
      'chuva',
      'mm',
      'y',
    ];

    for (final key in candidates) {
      final value = _toDouble(json[key]);
      if (value != 0 || json.containsKey(key)) {
        return value;
      }
    }

    return 0;
  }
}

class ClimateYearComparisonModel extends ClimateYearComparisonEntity {
  const ClimateYearComparisonModel({
    required super.year,
    required super.points,
  });

  factory ClimateYearComparisonModel.fromDynamic(dynamic raw, int index) {
    if (raw is Map<String, dynamic>) {
      return ClimateYearComparisonModel(
        year: _resolveYear(raw, index),
        points: _resolvePoints(raw),
      );
    }

    if (raw is Map) {
      final json = Map<String, dynamic>.from(raw);
      return ClimateYearComparisonModel(
        year: _resolveYear(json, index),
        points: _resolvePoints(json),
      );
    }

    return ClimateYearComparisonModel(
      year: '${DateTime.now().year - index}',
      points: const [],
    );
  }

  static String _resolveYear(Map<String, dynamic> json, int index) {
    const candidates = ['ano', 'year', 'label', 'nome'];
    for (final key in candidates) {
      final value = json[key]?.toString().trim() ?? '';
      if (value.isNotEmpty) {
        return value;
      }
    }
    return '${DateTime.now().year - index}';
  }

  static List<ClimateMonthlyRainPointEntity> _resolvePoints(
    Map<String, dynamic> json,
  ) {
    final month = _resolveMonth(json);
    if (month != null) {
      return [
        ClimateMonthlyRainPointEntity(
          label: month,
          value: ClimateMonthlyRainPointModel._resolveValue(json),
        ),
      ];
    }

    const listKeys = ['valores', 'dados', 'itens', 'meses', 'points', 'data'];
    for (final key in listKeys) {
      final rawList = json[key];
      if (rawList is List) {
        return rawList
            .whereType<Map>()
            .map(
              (item) => ClimateMonthlyRainPointModel.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList(growable: false);
      }
    }

    final monthEntries = <ClimateMonthlyRainPointEntity>[];
    for (final entry in json.entries) {
      final lower = entry.key.toLowerCase();
      if (lower == 'ano' ||
          lower == 'year' ||
          lower == 'label' ||
          lower == 'nome') {
        continue;
      }

      final value = _toDouble(entry.value);
      if (value != 0 || entry.value != null) {
        monthEntries.add(
          ClimateMonthlyRainPointEntity(label: entry.key, value: value),
        );
      }
    }

    return monthEntries;
  }

  static String? _resolveMonth(Map<String, dynamic> json) {
    const candidates = ['mes', 'month', 'mes_nome', 'nome_mes', 'label'];
    for (final key in candidates) {
      final value = json[key]?.toString().trim() ?? '';
      if (value.isNotEmpty && !_isYear(value)) {
        return value;
      }
    }
    return null;
  }

  static bool _isYear(String value) {
    final parsed = int.tryParse(value);
    return parsed != null && parsed >= 1900 && parsed <= 2200;
  }
}

class ClimateChartsResponseModel extends ClimateChartsEntity {
  const ClimateChartsResponseModel({
    required super.totalChuvaAcumulada,
    required super.totalChuvaUltimoMes,
    required super.chuvaMesAMes,
    required super.comparativoUltimos2Anos,
  });

  factory ClimateChartsResponseModel.fromJson(Map<String, dynamic> json) {
    final chuvaMesAMes = (json['chuva_mes_a_mes'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map(
          (item) => ClimateMonthlyRainPointModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList(growable: false);

    final comparativo = _mergeSeriesByYear(
      (json['comparativo_ultimos_2_anos'] as List<dynamic>? ?? const [])
          .asMap()
          .entries
          .map(
            (entry) =>
                ClimateYearComparisonModel.fromDynamic(entry.value, entry.key),
          )
          .toList(growable: false),
    );

    return ClimateChartsResponseModel(
      totalChuvaAcumulada: _toDouble(json['total_chuva_acumulada']),
      totalChuvaUltimoMes: _toDouble(json['total_chuva_ultimo_mes']),
      chuvaMesAMes: chuvaMesAMes,
      comparativoUltimos2Anos: comparativo,
    );
  }
}

List<ClimateYearComparisonEntity> _mergeSeriesByYear(
  List<ClimateYearComparisonEntity> series,
) {
  final grouped = <String, Map<String, ClimateMonthlyRainPointEntity>>{};
  final yearLabels = <String, String>{};

  for (final yearSeries in series) {
    final yearKey = yearSeries.year.trim();
    if (yearKey.isEmpty) {
      continue;
    }

    yearLabels.putIfAbsent(yearKey, () => yearSeries.year);
    final pointsByLabel = grouped.putIfAbsent(yearKey, () => {});

    for (final point in yearSeries.points) {
      final labelKey = _normalizePointLabel(point.label);
      if (labelKey.isEmpty) {
        continue;
      }

      final current = pointsByLabel[labelKey];
      pointsByLabel[labelKey] = ClimateMonthlyRainPointEntity(
        label: current?.label ?? point.label,
        value: (current?.value ?? 0) + point.value,
      );
    }
  }

  return grouped.entries
      .map(
        (entry) => ClimateYearComparisonModel(
          year: yearLabels[entry.key] ?? entry.key,
          points: entry.value.values.toList(growable: false),
        ),
      )
      .toList(growable: false);
}

String _normalizePointLabel(String label) {
  final trimmed = label.trim();
  final month = int.tryParse(trimmed);
  if (month != null && month >= 1 && month <= 12) {
    return month.toString().padLeft(2, '0');
  }
  return trimmed.toLowerCase();
}

double _toDouble(dynamic value) {
  return double.tryParse(value?.toString() ?? '') ?? 0;
}
