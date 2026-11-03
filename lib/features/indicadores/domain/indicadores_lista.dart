import 'package:costeira/features/indicadores/domain/indicador_valor.dart';

class PeriodoIndicadores {
  const PeriodoIndicadores({
    this.dataIn,
    this.dataOut,
    this.dias,
    this.idAnoAgricola,
  });

  final String? dataIn;
  final String? dataOut;
  final int? dias;
  final int? idAnoAgricola;

  String get safra {
    final inicio = _ano(dataIn);
    final fim = _ano(dataOut);
    if (inicio == null || fim == null) {
      return '';
    }
    return '$inicio/$fim';
  }

  static String? _ano(String? data) {
    if (data == null || data.length < 4) {
      return null;
    }
    final partes = data.split('/');
    if (partes.length == 3) {
      return partes.last;
    }
    return data.substring(0, 4);
  }
}

class IndicadorBloco {
  const IndicadorBloco(this.raw);

  final Map<String, dynamic> raw;

  static const vazio = IndicadorBloco({});

  Map<String, dynamic> get indicadores => _mapa(raw['indicadores']);

  Map<String, dynamic> get graficos {
    final valor = raw['graficos'];
    if (valor is Map) {
      return Map<String, dynamic>.from(valor);
    }
    return const {};
  }

  /// Lista quando API manda array; vazio se vier mapa (reprodução).
  List<Map<String, dynamic>> get detalhamento {
    final valor = raw['detalhamento'];
    if (valor is List) {
      return _lista(valor);
    }
    return const [];
  }

  /// Reprodução manda `detalhamento` como objeto chave→valor.
  Map<String, dynamic> get detalheCampos {
    final valor = raw['detalhamento'];
    if (valor is Map) {
      return Map<String, dynamic>.from(valor);
    }
    return const {};
  }

  IndicadorValor valor(String chave) => IndicadorValor.de(indicadores[chave]);

  /// Atalho do bloco de reprodução (`indicadores.valor`).
  IndicadorValor get valorPrincipal => valor('valor');

  Map<String, dynamic> get calculo => _mapa(indicadores['calculo']);

  /// Fórmula no root do bloco financeiro (`calculo` string).
  String? get formula {
    final valor = raw['calculo'];
    if (valor is! String) return null;
    final texto = valor.trim();
    return texto.isEmpty ? null : texto;
  }

  bool get disponivel {
    final valor = raw['disponivel'];
    if (valor == null) return true;
    if (valor is bool) return valor;
    final texto = valor.toString().trim().toLowerCase();
    return texto != 'false' && texto != '0';
  }

  List<String> get avisos {
    final valor = raw['avisos'];
    if (valor is! List) return const [];
    return [
      for (final item in valor)
        if (item != null && item.toString().trim().isNotEmpty) item.toString().trim(),
    ];
  }

  bool get temAvisoFinanceiro => !disponivel || avisos.isNotEmpty;

  List<Map<String, dynamic>> serie(String chave) => _lista(graficos[chave]);

  int? get mesesEstoqueMedio =>
      numeroIndicador(raw['meses_estoque_medio'])?.round();
}

class ReproducaoMetadados {
  const ReproducaoMetadados({
    this.parcial = false,
    this.pendencias = const [],
    this.limitacoes = const [],
  });

  final bool parcial;
  final List<Map<String, dynamic>> pendencias;
  final List<String> limitacoes;

  static const vazio = ReproducaoMetadados();

  bool get temAviso => parcial || pendencias.isNotEmpty || limitacoes.isNotEmpty;
}

class FinanceiroMetadados {
  const FinanceiroMetadados({
    this.disponivel = true,
    this.avaliacaoEconomicaDisponivel = true,
    this.avisos = const [],
    this.baseCustos,
    this.baseCaixa,
  });

  final bool disponivel;
  final bool avaliacaoEconomicaDisponivel;
  final List<String> avisos;
  final String? baseCustos;
  final String? baseCaixa;

  static const vazio = FinanceiroMetadados();

  bool get temAviso =>
      !disponivel || !avaliacaoEconomicaDisponivel || avisos.isNotEmpty;
}

class IndicadoresLista {
  const IndicadoresLista({
    required this.periodo,
    required this.gmdGlobal,
    required this.gmdLote,
    required this.kgProduzido,
    required this.lotacao,
    required this.rebanhoMedio,
    required this.areaMedia,
    required this.taxaDesfrute,
    required this.taxaAbate,
    required this.taxaGiro,
    required this.mortalidade,
    this.taxaPrenhez = IndicadorBloco.vazio,
    this.taxaNatalidade = IndicadorBloco.vazio,
    this.taxaDesmame = IndicadorBloco.vazio,
    this.pesoDesmame = IndicadorBloco.vazio,
    this.kgVacaExposta = IndicadorBloco.vazio,
    this.taxaAborto = IndicadorBloco.vazio,
    this.intervaloEntrePartos = IndicadorBloco.vazio,
    this.histogramaParicao = IndicadorBloco.vazio,
    this.merma = IndicadorBloco.vazio,
    this.reproducaoMeta = ReproducaoMetadados.vazio,
    this.custoPorCabeca = IndicadorBloco.vazio,
    this.custoPorKgProduzido = IndicadorBloco.vazio,
    this.resultadoOperacaoHectare = IndicadorBloco.vazio,
    this.resultadoOperacao = IndicadorBloco.vazio,
    this.percentualCustoFixo = IndicadorBloco.vazio,
    this.percentualCustoVariavel = IndicadorBloco.vazio,
    this.resultadoPatrimonio = IndicadorBloco.vazio,
    this.financeiroMeta = FinanceiroMetadados.vazio,
  });

  final PeriodoIndicadores periodo;
  final IndicadorBloco gmdGlobal;
  final IndicadorBloco gmdLote;
  final IndicadorBloco kgProduzido;
  final IndicadorBloco lotacao;
  final IndicadorBloco rebanhoMedio;
  final IndicadorBloco areaMedia;
  final IndicadorBloco taxaDesfrute;
  final IndicadorBloco taxaAbate;
  final IndicadorBloco taxaGiro;
  final IndicadorBloco mortalidade;
  final IndicadorBloco taxaPrenhez;
  final IndicadorBloco taxaNatalidade;
  final IndicadorBloco taxaDesmame;
  final IndicadorBloco pesoDesmame;
  final IndicadorBloco kgVacaExposta;
  final IndicadorBloco taxaAborto;
  final IndicadorBloco intervaloEntrePartos;
  final IndicadorBloco histogramaParicao;
  final IndicadorBloco merma;
  final ReproducaoMetadados reproducaoMeta;
  final IndicadorBloco custoPorCabeca;
  final IndicadorBloco custoPorKgProduzido;
  final IndicadorBloco resultadoOperacaoHectare;
  final IndicadorBloco resultadoOperacao;
  final IndicadorBloco percentualCustoFixo;
  final IndicadorBloco percentualCustoVariavel;
  final IndicadorBloco resultadoPatrimonio;
  final FinanceiroMetadados financeiroMeta;

  static const vazia = IndicadoresLista(
    periodo: PeriodoIndicadores(),
    gmdGlobal: IndicadorBloco.vazio,
    gmdLote: IndicadorBloco.vazio,
    kgProduzido: IndicadorBloco.vazio,
    lotacao: IndicadorBloco.vazio,
    rebanhoMedio: IndicadorBloco.vazio,
    areaMedia: IndicadorBloco.vazio,
    taxaDesfrute: IndicadorBloco.vazio,
    taxaAbate: IndicadorBloco.vazio,
    taxaGiro: IndicadorBloco.vazio,
    mortalidade: IndicadorBloco.vazio,
  );
}

Map<String, dynamic> _mapa(dynamic raw) {
  if (raw is Map<String, dynamic>) {
    return raw;
  }
  if (raw is Map) {
    return Map<String, dynamic>.from(raw);
  }
  return const {};
}

List<Map<String, dynamic>> _lista(dynamic raw) {
  if (raw is! List) {
    return const [];
  }
  return raw
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList(growable: false);
}
