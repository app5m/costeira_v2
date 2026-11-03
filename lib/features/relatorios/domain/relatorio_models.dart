import 'package:costeira/features/relatorios/domain/relatorio_categoria.dart';

class RelatorioValor {
  const RelatorioValor({this.qtd, this.unidade = '', this.texto = ''});

  final num? qtd;
  final String unidade;
  final String texto;

  bool get disponivel {
    final t = texto.trim();
    if (t.isNotEmpty && t.toLowerCase() != 'null') return true;
    return qtd != null;
  }

  String get exibicao {
    final t = texto.trim();
    if (t.isNotEmpty && t.toLowerCase() != 'null') return t;
    if (qtd == null) return '—';
    final n = qtd!;
    final numero = n == n.roundToDouble()
        ? n.toInt().toString()
        : n.toStringAsFixed(2).replaceAll('.', ',');
    final u = unidade.trim();
    return u.isEmpty ? numero : '$numero $u';
  }

  factory RelatorioValor.de(dynamic raw) {
    if (raw is! Map) return const RelatorioValor();
    final textoBruto = raw['texto']?.toString() ?? '';
    final texto = textoBruto.trim().toLowerCase() == 'null' ? '' : textoBruto;
    return RelatorioValor(
      qtd: num.tryParse(raw['qtd']?.toString() ?? ''),
      unidade: raw['string']?.toString() ?? '',
      texto: texto,
    );
  }
}

class RelatorioPeriodo {
  const RelatorioPeriodo({
    this.idAnoAgricola,
    this.dataIn = '',
    this.dataOut = '',
    this.dataOutCalculo = '',
    this.dias,
  });

  final int? idAnoAgricola;
  final String dataIn;
  final String dataOut;
  final String dataOutCalculo;
  final int? dias;

  String get rotulo {
    if (dataIn.isEmpty && dataOut.isEmpty) return 'Período';
    if (dataIn.isNotEmpty && dataOut.isNotEmpty) return '$dataIn a $dataOut';
    return dataIn.isNotEmpty ? dataIn : dataOut;
  }

  factory RelatorioPeriodo.de(Map<String, dynamic>? map) {
    if (map == null) return const RelatorioPeriodo();
    return RelatorioPeriodo(
      idAnoAgricola: int.tryParse(map['id_ano_agricola']?.toString() ?? ''),
      dataIn: map['data_in']?.toString() ?? '',
      dataOut: map['data_out']?.toString() ?? '',
      dataOutCalculo: map['data_out_calculo']?.toString() ?? '',
      dias: int.tryParse(map['dias']?.toString() ?? ''),
    );
  }
}

class RelatorioBloco {
  const RelatorioBloco({
    required this.chave,
    this.indicadores = const {},
    this.graficos = const {},
    this.listas = const {},
    this.metadados = const {},
  });

  /// Chave da API (`rebanho`, `geral`, …).
  final String chave;
  final Map<String, RelatorioValor> indicadores;
  final Map<String, List<Map<String, dynamic>>> graficos;
  final Map<String, List<Map<String, dynamic>>> listas;
  final Map<String, dynamic> metadados;

  RelatorioCategoria? get categoria => RelatorioCategoria.deApi(chave);
  String get titulo => RelatorioCategoria.tituloDe(chave);
  String get subtitulo => RelatorioCategoria.subtituloDe(chave);

  bool get temConteudo =>
      indicadores.isNotEmpty ||
      graficos.values.any((g) => g.isNotEmpty) ||
      listas.values.any((l) => l.isNotEmpty);

  /// Indicadores presentes na resposta (inclui qtd null — veio da API).
  Map<String, RelatorioValor> get indicadoresVisiveis => indicadores;

  /// Só gráficos com pontos.
  Map<String, List<Map<String, dynamic>>> get graficosVisiveis => {
        for (final e in graficos.entries)
          if (e.value.isNotEmpty) e.key: e.value,
      };

  /// Só listas com itens.
  Map<String, List<Map<String, dynamic>>> get listasVisiveis => {
        for (final e in listas.entries)
          if (e.value.isNotEmpty) e.key: e.value,
      };

  factory RelatorioBloco.de(String chave, Map<String, dynamic> map) {
    final indsRaw = map['indicadores'];
    final grafsRaw = map['graficos'];
    final listasRaw = map['listas'];
    final metaRaw = map['metadados'];

    final indicadores = <String, RelatorioValor>{};
    if (indsRaw is Map) {
      for (final entry in indsRaw.entries) {
        indicadores['${entry.key}'] = RelatorioValor.de(entry.value);
      }
    }

    final graficos = <String, List<Map<String, dynamic>>>{};
    if (grafsRaw is Map) {
      for (final entry in grafsRaw.entries) {
        final lista = entry.value;
        if (lista is! List) continue;
        final pontos = [
          for (final item in lista)
            if (item is Map) Map<String, dynamic>.from(item),
        ];
        // Chave ausente na API → não entra. Lista vazia → não exibe.
        if (pontos.isEmpty) continue;
        graficos['${entry.key}'] = pontos;
      }
    }

    final listas = <String, List<Map<String, dynamic>>>{};
    if (listasRaw is Map) {
      for (final entry in listasRaw.entries) {
        final lista = entry.value;
        if (lista is! List) continue;
        final itens = [
          for (final item in lista)
            if (item is Map) Map<String, dynamic>.from(item),
        ];
        if (itens.isEmpty) continue;
        listas['${entry.key}'] = itens;
      }
    }

    return RelatorioBloco(
      chave: chave,
      indicadores: indicadores,
      graficos: graficos,
      listas: listas,
      metadados: metaRaw is Map ? Map<String, dynamic>.from(metaRaw) : const {},
    );
  }
}

class RelatoriosLista {
  const RelatoriosLista({
    this.periodo = const RelatorioPeriodo(),
    this.categorias = const [],
    this.blocos = const {},
    this.limitacoes = const [],
    this.limit = 100,
    this.pagina = 1,
  });

  final RelatorioPeriodo periodo;
  final List<String> categorias;
  /// Só o que a API devolveu em `relatorios`.
  final Map<String, RelatorioBloco> blocos;
  final List<String> limitacoes;
  final int limit;
  final int pagina;

  static const vazia = RelatoriosLista();

  RelatorioBloco? bloco(String chave) => blocos[chave];

  /// Ordem: `categorias` da API (se houver), senão ordem dos blocos.
  List<String> get chavesVisiveis {
    if (categorias.isNotEmpty) {
      final vistas = <String>[];
      for (final c in categorias) {
        final k = c.trim().toLowerCase();
        if (k.isEmpty || !blocos.containsKey(k)) continue;
        if (!vistas.contains(k)) vistas.add(k);
      }
      for (final k in blocos.keys) {
        if (!vistas.contains(k)) vistas.add(k);
      }
      return vistas;
    }
    return blocos.keys.toList(growable: false);
  }

  factory RelatoriosLista.de(Map<String, dynamic> map) {
    final relRaw = map['relatorios'];
    final blocos = <String, RelatorioBloco>{};
    if (relRaw is Map) {
      for (final entry in relRaw.entries) {
        if (entry.value is! Map) continue;
        final chave = '${entry.key}'.trim().toLowerCase();
        if (chave.isEmpty) continue;
        final bloco = RelatorioBloco.de(
          chave,
          Map<String, dynamic>.from(entry.value as Map),
        );
        // Categoria veio na API → entra no hub (mesmo sem séries).
        blocos[chave] = bloco;
      }
    }

    final cats = map['categorias'];
    final lims = map['limitacoes'];
    return RelatoriosLista(
      periodo: RelatorioPeriodo.de(
        map['periodo'] is Map ? Map<String, dynamic>.from(map['periodo'] as Map) : null,
      ),
      categorias: cats is List ? [for (final c in cats) '$c'] : const [],
      blocos: blocos,
      limitacoes: lims is List ? [for (final l in lims) '$l'] : const [],
      limit: int.tryParse(map['limit']?.toString() ?? '') ?? 100,
      pagina: int.tryParse(map['pagina']?.toString() ?? '') ?? 1,
    );
  }
}

class RelatorioArquivoPdf {
  const RelatorioArquivoPdf({
    required this.categoria,
    required this.nome,
    required this.url,
    this.tamanhoBytes,
    this.sha256 = '',
    this.expiraEm = '',
  });

  final String categoria;
  final String nome;
  final String url;
  final int? tamanhoBytes;
  final String sha256;
  final String expiraEm;

  factory RelatorioArquivoPdf.de(Map<String, dynamic> map) {
    return RelatorioArquivoPdf(
      categoria: map['categoria']?.toString() ?? '',
      nome: map['nome']?.toString() ?? 'relatorio.pdf',
      url: map['url']?.toString() ?? '',
      tamanhoBytes: int.tryParse(map['tamanho_bytes']?.toString() ?? ''),
      sha256: map['sha256']?.toString() ?? '',
      expiraEm: map['expira_em']?.toString() ?? '',
    );
  }
}

class RelatoriosExportacao {
  const RelatoriosExportacao({
    this.msg = '',
    this.periodo = const RelatorioPeriodo(),
    this.arquivos = const [],
  });

  final String msg;
  final RelatorioPeriodo periodo;
  final List<RelatorioArquivoPdf> arquivos;

  factory RelatoriosExportacao.de(Map<String, dynamic> map) {
    final raw = map['arquivos'];
    return RelatoriosExportacao(
      msg: map['msg']?.toString() ?? '',
      periodo: RelatorioPeriodo.de(
        map['periodo'] is Map ? Map<String, dynamic>.from(map['periodo'] as Map) : null,
      ),
      arquivos: [
        if (raw is List)
          for (final item in raw)
            if (item is Map) RelatorioArquivoPdf.de(Map<String, dynamic>.from(item)),
      ],
    );
  }
}

String rotuloIndicadorRelatorio(String chave) {
  const mapa = {
    'resultado_periodo': 'Resultado do período',
    'custos_periodo': 'Custos do período',
    'kg_produzido': 'Kg produzido',
    'gmd_global': 'GMD global',
    'rebanho_medio': 'Rebanho médio',
    'pendencias': 'Pendências',
    'receitas_periodo': 'Receitas do período',
    'custos_fixos': 'Custos fixos',
    'custos_variaveis_financeiros_repasses': 'Custos variáveis / repasses',
    'nascimentos': 'Nascimentos',
    'mortes': 'Mortes',
    'cabecas': 'Cabeças',
    'ua': 'UA',
    'peso_medio': 'Peso médio',
    'lotes_com_animais': 'Lotes com animais',
    'area_ativa': 'Área ativa',
    'lotacao': 'Lotação',
    'kg_hectare': 'Kg/ha',
    'pesagens': 'Pesagens',
    'animais_vendidos': 'Animais vendidos',
    'receita_vendas': 'Receita de vendas',
    'kg_vendidos': 'Kg vendidos',
    'preco_medio_kg_vendido': 'Preço médio kg',
    'animais_perdidos': 'Animais perdidos',
    'taxa_prenhez': 'Taxa de prenhez',
    'taxa_natalidade': 'Taxa de natalidade',
    'taxa_desmame': 'Taxa de desmame',
    'peso_desmame': 'Peso ao desmame',
    'kg_vaca_exposta': 'Kg/vaca exposta',
    'taxa_aborto': 'Taxa de aborto',
    'intervalo_entre_partos': 'Intervalo entre partos',
    'merma': 'Merma',
    'nascimentos_registrados': 'Nascimentos registrados',
    'diagnosticos_realizados': 'Diagnósticos realizados',
    'registros': 'Registros',
    'produtos': 'Produtos',
    'animais_atendidos': 'Animais atendidos',
    'custo': 'Custo',
    'custo_animal_atendido': 'Custo/animal atendido',
    'custo_cabeca_dia': 'Custo/cabeça/dia',
    'manejos': 'Manejos',
    'tipos': 'Tipos',
    'piquetes': 'Piquetes',
    'area_manejada': 'Área manejada',
    'produtos_zerados': 'Produtos zerados',
    'valor_estoque': 'Valor do estoque',
    'valor_entradas_periodo': 'Valor entradas',
    'entradas': 'Entradas',
    'saidas': 'Saídas',
    'saldo_movimentacoes': 'Saldo movimentações',
    'movimentacoes_piquete': 'Mov. de piquete',
    'chuva_total': 'Chuva total',
    'dias_com_chuva': 'Dias com chuva',
    'media_dia_chuvoso': 'Média dia chuvoso',
    'criadas_periodo': 'Criadas no período',
    'pendentes_hoje': 'Pendentes hoje',
    'atrasadas_hoje': 'Atrasadas hoje',
    'concluidas_periodo': 'Concluídas no período',
    'concluidas_com_prazo_periodo': 'Concluídas no prazo',
  };
  return mapa[chave] ??
      chave
          .replaceAll('_', ' ')
          .split(' ')
          .map((p) => p.isEmpty ? p : '${p[0].toUpperCase()}${p.substring(1)}')
          .join(' ');
}

String rotuloGraficoRelatorio(String chave) {
  const mapa = {
    'custos_mensais': 'Custos mensais',
    'resultado_acumulado': 'Resultado acumulado',
    'custo_cabeca': 'Custo por cabeça',
    'producao': 'Produção',
    'evolucao_rebanho': 'Evolução do rebanho',
    'composicao': 'Composição',
    'producao_mensal': 'Produção mensal',
    'gmd_lote': 'GMD por lote',
    'histograma_paricao': 'Histograma de parição',
    'chuva_mensal': 'Chuva mensal',
  };
  return mapa[chave] ?? rotuloIndicadorRelatorio(chave);
}

String rotuloListaRelatorio(String chave) {
  const mapa = {
    'meses': 'Meses',
    'rebanho_atual': 'Rebanho atual',
    'pendencias': 'Pendências',
    'composicao': 'Composição',
    'lotes': 'Lotes',
    'piquetes': 'Piquetes',
    'composicao_producao': 'Composição da produção',
    'gmd_lotes': 'GMD por lote',
    'pesagens': 'Pesagens',
    'vendas': 'Vendas',
    'perdas': 'Perdas',
    'consumo_interno': 'Consumo interno',
    'diagnosticos': 'Diagnósticos',
    'nascimentos': 'Nascimentos',
    'partos': 'Partos',
    'abortos_manejos': 'Abortos (manejos)',
    'abortos_movimentacoes': 'Abortos (movimentações)',
    'estacoes_monta': 'Estações de monta',
    'iatf': 'IATF',
    'produtos': 'Produtos',
    'por_lote': 'Por lote',
    'registros': 'Registros',
    'por_tipo': 'Por tipo',
    'posicao_atual': 'Posição atual',
    'entradas': 'Entradas',
    'consumo_manejos': 'Consumo em manejos',
    'saidas_avulsas': 'Saídas avulsas',
    'saidas': 'Saídas',
    'movimentacoes_piquete': 'Movimentações de piquete',
    'totais_mensais': 'Totais mensais',
    'pendentes': 'Pendentes',
    'concluidas_periodo': 'Concluídas no período',
    'concluidas_sem_data': 'Concluídas sem data',
    'por_responsavel': 'Por responsável',
  };
  return mapa[chave] ?? rotuloIndicadorRelatorio(chave);
}
