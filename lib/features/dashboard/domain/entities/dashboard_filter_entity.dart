class DashboardFilterEntity {
  const DashboardFilterEntity({
    this.appUsersId,
    this.appFazendasId,
    required this.dataIn,
    required this.dataOut,
  });

  final int? appUsersId;
  final int? appFazendasId;
  final DateTime dataIn;
  final DateTime dataOut;

  DashboardFilterEntity copyWith({
    int? appUsersId,
    int? appFazendasId,
    DateTime? dataIn,
    DateTime? dataOut,
  }) {
    return DashboardFilterEntity(
      appUsersId: appUsersId ?? this.appUsersId,
      appFazendasId: appFazendasId ?? this.appFazendasId,
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
  });

  final String label;
  final DateTime dataIn;
  final DateTime dataOut;

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
