num? numeroIndicador(dynamic raw) {
  if (raw == null) {
    return null;
  }
  if (raw is num) {
    return raw;
  }
  final texto = raw.toString().trim().replaceAll(',', '.');
  if (texto.isEmpty || texto == 'null') {
    return null;
  }
  return num.tryParse(texto);
}

String formatarNumero(num valor, {int casas = 3, bool fixo = false}) {
  if (casas <= 0) {
    return valor.round().toString();
  }
  final texto = valor.toStringAsFixed(casas);
  if (fixo) {
    return texto;
  }
  return texto
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '');
}

class IndicadorValor {
  const IndicadorValor({this.qtd, this.texto, this.unidade});

  final num? qtd;
  final String? texto;
  final String? unidade;

  static const vazio = IndicadorValor();

  factory IndicadorValor.de(dynamic raw) {
    if (raw is! Map) {
      return IndicadorValor(qtd: numeroIndicador(raw));
    }
    return IndicadorValor(
      qtd: numeroIndicador(raw['qtd']),
      texto: _limpo(raw['texto']),
      unidade: _limpo(raw['string']),
    );
  }

  String exibir({String? unidadePadrao, int casas = 3, bool inteiro = false}) {
    final pronto = texto?.trim();
    if (pronto != null && pronto.isNotEmpty) {
      return pronto;
    }
    if (qtd == null) {
      return '—';
    }
    final numero = inteiro
        ? qtd!.round().toString()
        : formatarNumero(qtd!, casas: casas);
    final unidadeFinal = (unidade != null && unidade!.isNotEmpty)
        ? unidade
        : unidadePadrao;
    if (unidadeFinal == null || unidadeFinal.isEmpty) {
      return numero;
    }
    return '$numero $unidadeFinal';
  }
}

String? _limpo(dynamic raw) {
  if (raw == null) {
    return null;
  }
  final texto = raw.toString().trim();
  if (texto.isEmpty || texto == 'null') {
    return null;
  }
  return texto;
}
