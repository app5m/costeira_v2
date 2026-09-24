class MenuSlug {
  const MenuSlug._();

  static const compra = 'compra';
  static const nascimento = 'nascimento';
  static const transferenciaRecebida = 'transferencia_recebida';
  static const venda = 'venda';
  static const morte = 'morte';
  static const manejoAnimal = 'manejo_animal';
  static const potreiros = 'potreiros';
  static const estoque = 'estoque';
  static const tarefas = 'tarefas';
  static const pluviosidade = 'pluviosidade';
  static const fornecedores = 'fornecedores';
  static const compradores = 'compradores';
  static const usuarios = 'usuarios';
  static const dashboard = 'dashboard';
  static const fazendas = 'fazendas';
  static const animais = 'animais';
  static const manejos = 'manejos';
  static const perfil = 'perfil';
  static const movimentacoes = 'movimentacoes';

  static const _aliases = {
    'venda_de_animais': venda,
    'morte_baixa': morte,
    'usuarios_e_acessos': usuarios,
    'usuarios_de_acesso': usuarios,
    'transferencia': transferenciaRecebida,
    'climas_e_chuvas': pluviosidade,
    'climas_chuvas': pluviosidade,
    'entradas': 'entrada',
    'saidas': 'saida',
  };

  static String resolve({String? action, required String name}) {
    final raw = action?.trim() ?? '';
    if (raw.isNotEmpty && !raw.startsWith('/')) {
      return _normalize(raw);
    }
    return _normalize(name);
  }

  static String _normalize(String value) {
    final buffer = StringBuffer();
    for (final rune in value.toLowerCase().trim().runes) {
      buffer.write(_fold(String.fromCharCode(rune)));
    }
    final slug = buffer
        .toString()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    return _aliases[slug] ?? slug;
  }

  static String _fold(String char) {
    const map = {
      'á': 'a',
      'à': 'a',
      'ã': 'a',
      'â': 'a',
      'é': 'e',
      'ê': 'e',
      'í': 'i',
      'ó': 'o',
      'ô': 'o',
      'õ': 'o',
      'ú': 'u',
      'ü': 'u',
      'ç': 'c',
    };
    return map[char] ?? char;
  }
}
