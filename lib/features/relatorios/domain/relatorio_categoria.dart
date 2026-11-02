enum RelatorioCategoria {
  geral,
  rebanho,
  desempenhoProdutivo,
  reprodutivo,
  sanitario,
  nutricao,
  manejoCampo,
  estoque,
  movimentacoes,
  pluviosidade,
  tarefas;

  String get apiKey => switch (this) {
        RelatorioCategoria.geral => 'geral',
        RelatorioCategoria.rebanho => 'rebanho',
        RelatorioCategoria.desempenhoProdutivo => 'desempenho_produtivo',
        RelatorioCategoria.reprodutivo => 'reprodutivo',
        RelatorioCategoria.sanitario => 'sanitario',
        RelatorioCategoria.nutricao => 'nutricao',
        RelatorioCategoria.manejoCampo => 'manejo_campo',
        RelatorioCategoria.estoque => 'estoque',
        RelatorioCategoria.movimentacoes => 'movimentacoes',
        RelatorioCategoria.pluviosidade => 'pluviosidade',
        RelatorioCategoria.tarefas => 'tarefas',
      };

  String get titulo => switch (this) {
        RelatorioCategoria.geral => 'Mês a mês',
        RelatorioCategoria.rebanho => 'Rebanho',
        RelatorioCategoria.desempenhoProdutivo => 'Desempenho produtivo',
        RelatorioCategoria.reprodutivo => 'Reprodutivo',
        RelatorioCategoria.sanitario => 'Sanitário',
        RelatorioCategoria.nutricao => 'Nutrição',
        RelatorioCategoria.manejoCampo => 'Manejo de campo',
        RelatorioCategoria.estoque => 'Estoque',
        RelatorioCategoria.movimentacoes => 'Movimentações',
        RelatorioCategoria.pluviosidade => 'Pluviosidade',
        RelatorioCategoria.tarefas => 'Tarefas',
      };

  String get subtitulo => switch (this) {
        RelatorioCategoria.geral => 'Resultado, custos, produção e rebanho no período',
        RelatorioCategoria.rebanho => 'Composição, lotes, piquetes e evolução',
        RelatorioCategoria.desempenhoProdutivo => 'Kg produzido, GMD, vendas e perdas',
        RelatorioCategoria.reprodutivo => 'Taxas, nascimentos e diagnósticos',
        RelatorioCategoria.sanitario => 'Custos e registros sanitários',
        RelatorioCategoria.nutricao => 'Suplementação e custo por cabeça',
        RelatorioCategoria.manejoCampo => 'Manejos de pastagem e área',
        RelatorioCategoria.estoque => 'Posição, entradas e consumo',
        RelatorioCategoria.movimentacoes => 'Entradas, saídas e saldo',
        RelatorioCategoria.pluviosidade => 'Chuva mensal e registros',
        RelatorioCategoria.tarefas => 'Pendentes, atrasadas e por responsável',
      };

  static RelatorioCategoria? deApi(String? chave) {
    final k = (chave ?? '').trim().toLowerCase();
    for (final item in RelatorioCategoria.values) {
      if (item.apiKey == k) return item;
    }
    return null;
  }

  static String tituloDe(String chave) {
    return deApi(chave)?.titulo ?? _humanizar(chave);
  }

  static String subtituloDe(String chave) {
    return deApi(chave)?.subtitulo ?? 'Indicadores, gráficos e listas do período';
  }

  static String _humanizar(String chave) {
    final limpo = chave.trim().replaceAll('_', ' ');
    if (limpo.isEmpty) return 'Relatório';
    return limpo
        .split(' ')
        .map((p) => p.isEmpty ? p : '${p[0].toUpperCase()}${p.substring(1)}')
        .join(' ');
  }

  static const todos = RelatorioCategoria.values;
}
