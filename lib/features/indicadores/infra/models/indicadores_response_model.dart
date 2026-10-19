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
}
