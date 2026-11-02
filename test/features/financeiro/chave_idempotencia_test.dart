import 'package:costeira/features/financeiro/domain/chave_idempotencia.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('lote de salvar usa o mesmo uuid e cabe no teto', () {
    final lote = ChaveIdempotencia.loteSalvar();
    expect(lote.criar, '${lote.uuid}-criar');
    expect(lote.confirmar, '${lote.uuid}-confirmar');
    expect(lote.baixa, '${lote.uuid}-baixa');
    for (final chave in [lote.criar, lote.confirmar, lote.baixa]) {
      expect(chave.length, inInclusiveRange(42, 51));
      expect(chave.length, lessThanOrEqualTo(ChaveIdempotencia.teto));
    }
  });

  test('ação fora da lista não gera chave', () {
    expect(
      () => ChaveIdempotencia.montar(
        '11111111-1111-4111-8111-111111111111',
        'outro',
      ),
      throwsArgumentError,
    );
  });
}
