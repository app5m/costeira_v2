import 'package:costeira/features/dashboard/domain/entities/dashboard_filter_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('lê ano_in e ano_out', () {
    final years = AgriculturalYearRange.fromApiList([
      {'id': 1, 'ano_in': 2025, 'ano_out': 2026},
      {'id': 2, 'ano_in': 2026, 'ano_out': 2027},
    ]);

    expect(years, hasLength(2));
    expect(years.first.id, 1);
    expect(years.first.label, '2025/2026');
    expect(years.first.dataIn, DateTime(2025, 7, 1));
    expect(years.first.dataOut, DateTime(2026, 6, 30));
    expect(years.last.label, '2026/2027');
    expect(years.last.dataIn, DateTime(2026, 7, 1));
    expect(years.last.dataOut, DateTime(2027, 6, 30));
  });

  test('lista vazia não gera ano', () {
    expect(AgriculturalYearRange.fromApiList(const []), isEmpty);
  });
}
