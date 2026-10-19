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

  List<Map<String, dynamic>> get detalhamento => _lista(raw['detalhamento']);

  IndicadorValor valor(String chave) => IndicadorValor.de(indicadores[chave]);

  Map<String, dynamic> get calculo => _mapa(indicadores['calculo']);

  List<Map<String, dynamic>> serie(String chave) => _lista(graficos[chave]);
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
  });

  final PeriodoIndicadores periodo;
  final IndicadorBloco gmdGlobal;
  final IndicadorBloco gmdLote;
  final IndicadorBloco kgProduzido;
  final IndicadorBloco lotacao;
  final IndicadorBloco rebanhoMedio;
  final IndicadorBloco areaMedia;

  static const vazia = IndicadoresLista(
    periodo: PeriodoIndicadores(),
    gmdGlobal: IndicadorBloco.vazio,
    gmdLote: IndicadorBloco.vazio,
    kgProduzido: IndicadorBloco.vazio,
    lotacao: IndicadorBloco.vazio,
    rebanhoMedio: IndicadorBloco.vazio,
    areaMedia: IndicadorBloco.vazio,
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
