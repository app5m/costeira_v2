/// Normaliza payload de simular/confirmar apuração de parceria.
///
/// Backend costuma mandar totais só em `itens[]` (sem bloco `totais`/`resumo`).
Map<String, dynamic> flattenApuracaoParceria(Map<String, dynamic> raiz) {
  final out = Map<String, dynamic>.from(raiz);

  for (final chave in const [
    'dados',
    'data',
    'totais',
    'resumo',
    'indicadores',
    'apuracao',
    'simulacao',
    'resultado',
  ]) {
    final nested = out[chave];
    if (nested is Map) {
      final mapa = Map<String, dynamic>.from(nested);
      mapa.forEach((k, v) {
        if (!_temValor(out, k)) out[k] = v;
      });
    }
  }

  final itens = out['itens'];
  if (itens is List) {
    const agregados = <String, List<String>>{
      'receita_bruta': ['receita_bruta', 'receita', 'valor_bruto', 'valor_total'],
      'capital_investidor': ['capital_investidor', 'capital'],
      'ganho_valor': ['ganho_valor'],
      'ganho_investidor': ['ganho_investidor'],
      'ganho_fazenda': ['ganho_fazenda'],
      'custo_operacional': ['custo_operacional'],
      'reembolso_custo': ['reembolso_custo', 'reembolso'],
      'margem_fazenda': ['margem_fazenda'],
    };
    for (final entry in agregados.entries) {
      if (_temValor(out, entry.key)) continue;
      final soma = _somaItens(itens, entry.value);
      if (soma != null) out[entry.key] = soma;
    }
  }

  _alias(out, de: 'capital_investidor', para: 'capital');
  _alias(out, de: 'reembolso_custo', para: 'reembolso');
  _alias(out, de: 'capital', para: 'capital_investidor');
  _alias(out, de: 'reembolso', para: 'reembolso_custo');

  return out;
}

void _alias(Map<String, dynamic> out, {required String de, required String para}) {
  if (_temValor(out, para) || !_temValor(out, de)) return;
  out[para] = out[de];
  final deStr = out['${de}_string'];
  if (deStr != null && !_temValor(out, '${para}_string')) {
    out['${para}_string'] = deStr;
  }
}

bool _temValor(Map<String, dynamic> mapa, String chave) {
  final v = mapa[chave] ?? mapa['${chave}_string'];
  if (v == null) return false;
  return v.toString().trim().isNotEmpty;
}

double? _somaItens(List itens, List<String> chaves) {
  var total = 0.0;
  var achou = false;
  for (final item in itens) {
    if (item is! Map) continue;
    for (final chave in chaves) {
      final n = _numeroFlex(item[chave] ?? item['${chave}_string']);
      if (n == null) continue;
      total += n;
      achou = true;
      break;
    }
  }
  return achou ? total : null;
}

double? _numeroFlex(dynamic bruto) {
  if (bruto == null) return null;
  if (bruto is num) return bruto.toDouble();
  final texto = bruto.toString().trim();
  if (texto.isEmpty) return null;
  final limpo = texto.replaceAll(RegExp(r'[^\d,.-]'), '');
  if (limpo.isEmpty) return null;
  if (limpo.contains(',') && limpo.contains('.')) {
    return double.tryParse(limpo.replaceAll('.', '').replaceAll(',', '.'));
  }
  if (limpo.contains(',')) {
    return double.tryParse(limpo.replaceAll(',', '.'));
  }
  return double.tryParse(limpo);
}
