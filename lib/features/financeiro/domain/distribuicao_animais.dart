class DistribuicaoAnimais {
  const DistribuicaoAnimais._();

  static List<int> dividirCentavos(int totalCentavos, int quantidade) {
    if (quantidade <= 0 || totalCentavos < 0) return const [];
    final base = totalCentavos ~/ quantidade;
    final resto = totalCentavos % quantidade;
    return [
      for (var i = 0; i < quantidade; i++) base + (i < resto ? 1 : 0),
    ];
  }

  static List<int?> centavosIguais({
    required int totalCentavos,
    required List<int?> centros,
    required bool porCentro,
    required Map<int, int> totaisPorCentro,
  }) {
    if (!porCentro) return dividirCentavos(totalCentavos, centros.length);
    final saida = List<int?>.filled(centros.length, null);
    final grupos = <int, List<int>>{};
    for (var i = 0; i < centros.length; i++) {
      final centro = centros[i];
      if (centro == null) continue;
      grupos.putIfAbsent(centro, () => []).add(i);
    }
    for (final grupo in grupos.entries) {
      final partes = dividirCentavos(totaisPorCentro[grupo.key] ?? 0, grupo.value.length);
      for (var i = 0; i < grupo.value.length; i++) {
        saida[grupo.value[i]] = partes[i];
      }
    }
    return saida;
  }

  static String? validar({
    required int totalCentavos,
    required List<int?> valores,
    required List<int?> centros,
    required bool porCentro,
    required Map<int, int> totaisPorCentro,
  }) {
    if (valores.isEmpty) return null;
    if (totalCentavos <= 0) return 'Informe o valor do lançamento.';
    if (centros.any((centro) => centro == null)) {
      return 'Selecione o centro de cada animal.';
    }
    if (valores.any((valor) => valor == null || valor <= 0)) {
      return 'Informe o valor de cada animal.';
    }
    final soma = valores.fold<int>(0, (total, valor) => total + valor!);
    if (soma != totalCentavos) {
      return 'A soma dos animais precisa fechar o valor do lançamento.';
    }
    if (!porCentro) return null;
    final porCentroSoma = <int, int>{};
    for (var i = 0; i < centros.length; i++) {
      final centro = centros[i]!;
      porCentroSoma[centro] = (porCentroSoma[centro] ?? 0) + valores[i]!;
    }
    for (final centro in totaisPorCentro.entries) {
      if ((porCentroSoma[centro.key] ?? 0) != centro.value) {
        return 'Os animais de cada centro precisam fechar o valor desse centro.';
      }
    }
    for (final centro in porCentroSoma.keys) {
      if (!totaisPorCentro.containsKey(centro)) {
        return 'Há animal em centro sem valor no rateio.';
      }
    }
    return null;
  }
}
