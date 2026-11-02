import 'package:costeira/features/indicadores/domain/indicador_valor.dart';
import 'package:costeira/features/indicadores/domain/indicadores_lista.dart';

class IndicadoresResponseModel {
  const IndicadoresResponseModel._();

  static IndicadoresLista fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;
    final producao = data['producao_rebanho'] is Map
        ? Map<String, dynamic>.from(data['producao_rebanho'] as Map)
        : <String, dynamic>{};
    final desfrute = data['desfrute_saidas'] is Map
        ? Map<String, dynamic>.from(data['desfrute_saidas'] as Map)
        : <String, dynamic>{};
    final reproducao = data['reproducao'] is Map
        ? Map<String, dynamic>.from(data['reproducao'] as Map)
        : <String, dynamic>{};
    final periodo = data['periodo'] is Map
        ? Map<String, dynamic>.from(data['periodo'] as Map)
        : <String, dynamic>{};

    return IndicadoresLista(
      periodo: PeriodoIndicadores(
        dataIn: periodo['data_in']?.toString(),
        dataOut: periodo['data_out']?.toString(),
        dias: numeroIndicador(periodo['dias'])?.round(),
        idAnoAgricola: numeroIndicador(periodo['id_ano_agricola'])?.round(),
      ),
      gmdGlobal: _bloco(producao['gmd_global']),
      gmdLote: _bloco(producao['gmd_lote_categoria']),
      kgProduzido: _bloco(producao['kg_produzido']),
      lotacao: _bloco(producao['lotacao']),
      rebanhoMedio: _bloco(producao['rebanho_medio']),
      areaMedia: _bloco(producao['area_medida_utilizada']),
      taxaDesfrute: _bloco(desfrute['taxa_desfrute']),
      taxaAbate: _bloco(desfrute['taxa_abate']),
      taxaGiro: _bloco(desfrute['taxa_giro']),
      mortalidade: _bloco(desfrute['mortalidade']),
      taxaPrenhez: _bloco(reproducao['taxa_prenhez']),
      taxaNatalidade: _bloco(reproducao['taxa_natalidade']),
      taxaDesmame: _bloco(reproducao['taxa_desmame']),
      pesoDesmame: _bloco(reproducao['peso_desmame']),
      kgVacaExposta: _bloco(reproducao['kg_vaca_exposta']),
      taxaAborto: _bloco(reproducao['taxa_aborto']),
      intervaloEntrePartos: _bloco(reproducao['intervalo_entre_partos']),
      histogramaParicao: _bloco(reproducao['histograma_paricao']),
      merma: _bloco(reproducao['merma']),
      reproducaoMeta: _metaReproducao(reproducao['metadados']),
    );
  }

  static IndicadorBloco _bloco(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      return IndicadorBloco(raw);
    }
    if (raw is Map) {
      return IndicadorBloco(Map<String, dynamic>.from(raw));
    }
    return IndicadorBloco.vazio;
  }

  static ReproducaoMetadados _metaReproducao(dynamic raw) {
    if (raw is! Map) {
      return ReproducaoMetadados.vazio;
    }
    final mapa = Map<String, dynamic>.from(raw);
    final pendencias = mapa['pendencias'] is List
        ? [
            for (final item in mapa['pendencias'] as List)
              if (item is Map) Map<String, dynamic>.from(item),
          ]
        : const <Map<String, dynamic>>[];
    final limitacoes = mapa['limitacoes'] is List
        ? [
            for (final item in mapa['limitacoes'] as List)
              if (item != null && item.toString().trim().isNotEmpty) item.toString().trim(),
          ]
        : const <String>[];
    final parcial = mapa['parcial'] == true || mapa['parcial']?.toString() == '1';
    return ReproducaoMetadados(
      parcial: parcial,
      pendencias: pendencias,
      limitacoes: limitacoes,
    );
  }
}
