import 'package:costeira/features/indicadores/domain/indicador_valor.dart';
import 'package:costeira/features/indicadores/infra/models/indicadores_request_model.dart';
import 'package:costeira/features/indicadores/infra/models/indicadores_response_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('texto ganha de qtd e null não vira zero', () {
    expect(
      IndicadorValor.de({'qtd': 1, 'texto': '0,205 kg/dia'}).exibir(),
      '0,205 kg/dia',
    );
    expect(IndicadorValor.de({'qtd': null}).exibir(), '—');
    expect(IndicadorValor.de({'qtd': 0, 'string': 'kg'}).exibir(), '0 kg');
    expect(IndicadorValor.de({'qtd': 0.005, 'string': 'UA/ha'}).exibir(), '0.005 UA/ha');
    final comTexto = IndicadorValor.de({
      'qtd': 555.55,
      'string': 'ha',
      'texto': '555.550 ha',
    }).partes(unidadePadrao: 'ha');
    expect(comTexto.numero, '555.550');
    expect(comTexto.unidade, 'ha');
    final gmd = IndicadorValor.de({
      'qtd': 17.333,
      'string': 'kg/dia',
      'texto': '17.333 kg/dia',
    }).partes();
    expect(gmd.numero, '17.333');
    expect(gmd.unidade, 'kg/dia');
    final semTexto = IndicadorValor.de({'qtd': 22}).partes(
      unidadePadrao: 'cab',
      inteiro: true,
    );
    expect(semTexto.numero, '22');
    expect(semTexto.unidade, 'cab');
    expect(formatarNumero(2.889), '2.889');
  });

  test('parser lê produção e ignora null no gmd do lote', () {
    final lista = IndicadoresResponseModel.fromJson({
      'status': '01',
      'data': {
        'periodo': {
          'data_in': '01/07/2026',
          'data_out': '19/10/2026',
          'dias': 111,
        },
        'producao_rebanho': {
          'gmd_global': {
            'indicadores': {
              'gmd_global': {'qtd': 0.205, 'string': 'kg/dia'},
            },
            'graficos': {
              'gmd_global': [
                {'nome_mes': 'Jul', 'gmd_global': null},
                {'nome_mes': 'Ago', 'gmd_global': 0.2},
              ],
            },
            'detalhamento': [],
          },
          'gmd_lote_categoria': {
            'indicadores': {'gmd_medio': {'qtd': null}},
            'graficos': {'gmd_lote': []},
            'detalhamento': [
              {'nome': 'A', 'gmd': null, 'peso_inicio': 10},
              {'nome': 'B', 'gmd': 0},
            ],
          },
          'kg_produzido': {
            'indicadores': {
              'kg_produzido': {'qtd': 3000},
              'calculo': {
                'estoque_atual': 47410,
                'saidas': 0,
                'inventario_inicial': 44410,
                'compras_entradas': null,
              },
            },
          },
          'area_medida_utilizada': {
            'indicadores': {'area_media': {'qtd': 274.4, 'string': 'ha'}},
            'graficos': [],
          },
        },
      },
    });

    expect(lista.periodo.safra, '2026/2026');
    expect(lista.gmdGlobal.valor('gmd_global').exibir(), '0.205 kg/dia');
    expect(numeroIndicador(lista.gmdGlobal.serie('gmd_global').first['gmd_global']), isNull);
    expect(lista.gmdLote.valor('gmd_medio').exibir(), '—');
    expect(numeroIndicador(lista.kgProduzido.calculo['compras_entradas']), isNull);
    expect(lista.areaMedia.graficos, isEmpty);
  });

  test('todo o período não manda periodo', () {
    final corpo = IndicadoresRequestModel(
      appUsersId: 450,
      appFazendasId: 451,
    ).toJson();
    expect(corpo.containsKey('periodo'), isFalse);
    expect(corpo['app_users_id'], 450);
    expect(corpo.containsKey('app_animais_lotes_id'), isFalse);
  });
}
