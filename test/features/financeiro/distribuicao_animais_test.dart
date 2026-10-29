import 'package:costeira/features/financeiro/domain/distribuicao_animais.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('divide 1000 em 3 e o resto fica nos primeiros', () {
    expect(DistribuicaoAnimais.dividirCentavos(100000, 3), [33334, 33333, 33333]);
  });

  test('rateio por centro fecha cada centro', () {
    final centavos = DistribuicaoAnimais.centavosIguais(
      totalCentavos: 100000,
      centros: const [1, 1, 2],
      porCentro: true,
      totaisPorCentro: const {1: 60000, 2: 40000},
    );
    expect(centavos, [30000, 30000, 40000]);
    expect(
      DistribuicaoAnimais.validar(
        totalCentavos: 100000,
        valores: centavos,
        centros: const [1, 1, 2],
        porCentro: true,
        totaisPorCentro: const {1: 60000, 2: 40000},
      ),
      isNull,
    );
  });

  test('soma diferente do lançamento bloqueia', () {
    expect(
      DistribuicaoAnimais.validar(
        totalCentavos: 100000,
        valores: const [50000, 40000],
        centros: const [1, 1],
        porCentro: false,
        totaisPorCentro: const {},
      ),
      'A soma dos animais precisa fechar o valor do lançamento.',
    );
  });
}
