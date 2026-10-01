class DashboardFilterEntity {
  const DashboardFilterEntity({
    this.appUsersId,
    this.appFazendasId,
    this.idAnoAgricola,
    required this.dataIn,
    required this.dataOut,
  });

  final int? appUsersId;
  final int? appFazendasId;
  final int? idAnoAgricola;
  final DateTime dataIn;
  final DateTime dataOut;

  DashboardFilterEntity copyWith({
    int? appUsersId,
    int? appFazendasId,
    int? idAnoAgricola,
    DateTime? dataIn,
    DateTime? dataOut,
  }) {
    return DashboardFilterEntity(
      appUsersId: appUsersId ?? this.appUsersId,
      appFazendasId: appFazendasId ?? this.appFazendasId,
      idAnoAgricola: idAnoAgricola ?? this.idAnoAgricola,
      dataIn: dataIn ?? this.dataIn,
      dataOut: dataOut ?? this.dataOut,
    );
  }
}

class AgriculturalYearRange {
  const AgriculturalYearRange({
    required this.label,
    required this.dataIn,
    required this.dataOut,
    this.id,
  });

  final int? id;
  final String label;
  final DateTime dataIn;
  final DateTime dataOut;

  static List<AgriculturalYearRange> fromApiList(List<dynamic>? raw) {
    if (raw == null || raw.isEmpty) {
      return const [];
    }
    final years = <AgriculturalYearRange>[];
    for (final item in raw) {
      if (item is! Map) {
        continue;
      }
      final parsed = tryParse(Map<String, dynamic>.from(item));
      if (parsed != null) {
        years.add(parsed);
      }
    }
    return years;
  }

  static AgriculturalYearRange? tryParse(Map<String, dynamic> json) {
    final id = int.tryParse(json['id']?.toString() ?? '');
    final anoIn = int.tryParse(json['ano_in']?.toString() ?? '');
    final anoOut = int.tryParse(json['ano_out']?.toString() ?? '');
    if (anoIn != null && anoOut != null) {
      return AgriculturalYearRange(
        id: id != null && id > 0 ? id : null,
        label: '$anoIn/$anoOut',
        dataIn: DateTime(anoIn, 7, 1),
        dataOut: DateTime(anoOut, 6, 30),
      );
    }

    final label =
        (json['nome'] ?? json['label'] ?? json['ano'])?.toString().trim() ??
        '';
    final dataIn = _parseDate(
      json['data_in'] ?? json['data_inicio'] ?? json['inicio'],
    );
    final dataOut = _parseDate(
      json['data_out'] ?? json['data_fim'] ?? json['fim'],
    );
    if (dataIn != null && dataOut != null) {
      return AgriculturalYearRange(
        id: id != null && id > 0 ? id : null,
        label: label.isNotEmpty ? label : '${dataIn.year}/${dataOut.year}',
        dataIn: dataIn,
        dataOut: dataOut,
      );
    }

    final match = RegExp(r'(\d{4})\s*/\s*(\d{4})').firstMatch(label);
    if (match == null) {
      return null;
    }
    final startYear = int.parse(match.group(1)!);
    return AgriculturalYearRange(
      id: id != null && id > 0 ? id : null,
      label: '${match.group(1)}/${match.group(2)}',
      dataIn: DateTime(startYear, 7, 1),
      dataOut: DateTime(startYear + 1, 6, 30),
    );
  }

  static AgriculturalYearRange? containingIn(
    List<AgriculturalYearRange> years,
    DateTime date,
  ) {
    final day = DateTime(date.year, date.month, date.day);
    for (final year in years) {
      final start = DateTime(year.dataIn.year, year.dataIn.month, year.dataIn.day);
      final end = DateTime(year.dataOut.year, year.dataOut.month, year.dataOut.day);
      if (!day.isBefore(start) && !day.isAfter(end)) {
        return year;
      }
    }
    return years.isEmpty ? null : years.first;
  }

  static DateTime? _parseDate(Object? raw) {
    final value = raw?.toString().trim() ?? '';
    if (value.isEmpty) {
      return null;
    }
    final br = RegExp(r'^(\d{2})/(\d{2})/(\d{4})').firstMatch(value);
    if (br != null) {
      return DateTime(
        int.parse(br.group(3)!),
        int.parse(br.group(2)!),
        int.parse(br.group(1)!),
      );
    }
    final iso = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(value);
    if (iso != null) {
      return DateTime(
        int.parse(iso.group(1)!),
        int.parse(iso.group(2)!),
        int.parse(iso.group(3)!),
      );
    }
    return null;
  }

  static AgriculturalYearRange containing(DateTime date) {
    final startYear = date.month >= 7 ? date.year : date.year - 1;
    return forStartYear(startYear);
  }

  static AgriculturalYearRange forStartYear(int startYear) {
    return AgriculturalYearRange(
      label: '$startYear/${startYear + 1}',
      dataIn: DateTime(startYear, 7, 1),
      dataOut: DateTime(startYear + 1, 6, 30),
    );
  }

  static List<AgriculturalYearRange> options(DateTime date) {
    final current = containing(date);
    final start = current.dataIn.year;
    return [
      for (var year = start + 1; year >= start - 2; year--) forStartYear(year),
    ];
  }
}
