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
    expect(lista.taxaDesfrute.valor('taxa_desfrute').exibir(), '—');
  });

  test('parser lê desfrute_saidas', () {
    final lista = IndicadoresResponseModel.fromJson({
      'status': '01',
      'data': {
        'desfrute_saidas': {
          'taxa_desfrute': {
            'indicadores': {
              'taxa_desfrute': {'qtd': 7.1, 'string': '%', 'texto': '7.1%'},
              'kg_produzido': {'qtd': 3150, 'string': 'kg'},
              'kg_inventario_inicial': {'qtd': 44410, 'string': 'kg'},
            },
            'detalhamento': [],
          },
          'taxa_abate': {
            'indicadores': {
              'taxa_abate': {'qtd': 0, 'string': '%', 'texto': '0.0%'},
              'kg_vendidos': {'qtd': 0, 'string': 'kg', 'texto': '0 kg'},
              'kg_estoque_inicial': {'qtd': 44410, 'string': 'kg'},
            },
          },
          'taxa_giro': {
            'indicadores': {
              'taxa_giro': {'qtd': 0, 'string': '%', 'texto': '0.000%'},
              'cabecas_vendidas': {'qtd': 0, 'string': 'cab'},
              'estoque_inicial': {'qtd': 104, 'string': 'cab'},
            },
          },
          'mortalidade': {
            'indicadores': {
              'taxa_mortalidade': {'qtd': 0, 'string': '%', 'texto': '0.00%'},
              'animais_perdidos': {'qtd': 0},
              'estoque_medio': {'qtd': 135},
            },
            'graficos': {'mortalidade_categoria': []},
            'detalhamento': [],
            'meses_estoque_medio': 4,
          },
        },
      },
    });

    expect(lista.taxaDesfrute.valor('taxa_desfrute').partes().numero, '7.1');
    expect(lista.taxaAbate.valor('kg_vendidos').exibir(), '0 kg');
    expect(lista.taxaGiro.valor('estoque_inicial').qtd, 104);
    expect(lista.mortalidade.mesesEstoqueMedio, 4);
    expect(lista.mortalidade.serie('mortalidade_categoria'), isEmpty);
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

  test('parser lê reproducao com detalhamento mapa e metadados', () {
    final lista = IndicadoresResponseModel.fromJson({
      'status': '01',
      'data': {
        'reproducao': {
          'taxa_prenhez': {
            'indicadores': {
              'valor': {'qtd': 0, 'string': '%', 'texto': '0.000%'},
            },
            'graficos': [],
            'detalhamento': {'prenhas': 0, 'acasaladas': 2},
          },
          'histograma_paricao': {
            'indicadores': {
              'valor': {'qtd': 3, 'string': 'cab.', 'texto': '3.000 cab.'},
            },
            'graficos': {
              'nascimentos_mes': [
                {'mes': '2026-09', 'quantidade': 3},
              ],
            },
            'detalhamento': [],
          },
          'metadados': {
            'parcial': true,
            'pendencias': [
              {
                'brinco': '0010',
                'msg': 'Matriz sem diagnostico.',
              },
            ],
            'limitacoes': ['Filtros usam vínculos atuais.'],
          },
        },
      },
    });

    expect(lista.taxaPrenhez.valorPrincipal.exibir(), '0.000%');
    expect(lista.taxaPrenhez.detalheCampos['acasaladas'], 2);
    expect(lista.taxaPrenhez.detalhamento, isEmpty);
    expect(lista.histogramaParicao.valorPrincipal.partes().numero, '3.000');
    expect(lista.histogramaParicao.serie('nascimentos_mes').first['quantidade'], 3);
    expect(lista.reproducaoMeta.parcial, isTrue);
    expect(lista.reproducaoMeta.pendencias.first['brinco'], '0010');
    expect(lista.reproducaoMeta.limitacoes, hasLength(1));
  });

  test('parser lê financeiro com texto, formula e avisos', () {
    final lista = IndicadoresResponseModel.fromJson({
      'status': '01',
      'data': {
        'financeiro': {
          'custo_por_cabeca': {
            'indicadores': {
              'desembolso_cabeca_mes': {
                'qtd': 14.611,
                'string': 'R\$',
                'texto': 'R\$ 14.611',
              },
              'custo_producao_cabeca': {
                'qtd': 60,
                'string': 'R\$',
                'texto': 'R\$ 60.000',
              },
              'rebanho_medio': {
                'qtd': 1.2,
                'string': 'cab',
                'texto': '1.200 cab',
              },
            },
            'graficos': {
              'desembolso_cabeca_mes': [
                {'mes': '2026-10', 'nome_mes': 'Out', 'valor': 11.976},
              ],
            },
            'detalhamento': [
              {
                'id': 38,
                'descricao': 'Despesa teste',
                'valor': 20,
                'classificacao': 'custo_fixo',
              },
            ],
            'calculo': '(CF + CV) / rebanho medio / (dias / 30.44)',
            'disponivel': true,
            'avisos': [],
          },
          'percentual_custo_fixo': {
            'indicadores': {
              'percentual_custo_fixo': {
                'qtd': 27.778,
                'string': '%',
                'texto': '27.778%',
              },
              'custo_fixo': {'qtd': 20, 'string': 'R\$', 'texto': 'R\$ 20.000'},
              'custo_total': {'qtd': 72, 'string': 'R\$', 'texto': 'R\$ 72.000'},
            },
            'graficos': [],
            'detalhamento': [],
            'calculo': 'CF / (CF + CV) * 100',
            'disponivel': true,
            'avisos': [],
          },
          'custo_por_kg_produzido': {
            'indicadores': {
              'custo_kg': {'qtd': null, 'string': 'R\$', 'texto': null},
            },
            'disponivel': false,
            'avisos': ['Producao de kg ausente, zero ou negativa.'],
            'calculo': '(CF + CV) / kg produzidos',
          },
          'metadados': {
            'disponivel': true,
            'avaliacao_economica_disponivel': false,
            'avisos': [],
            'base_custos': 'competencia',
          },
        },
      },
    });

    expect(lista.custoPorCabeca.valor('desembolso_cabeca_mes').exibir(), 'R\$ 14.611');
    expect(lista.custoPorCabeca.formula, contains('rebanho medio'));
    expect(lista.custoPorCabeca.disponivel, isTrue);
    expect(lista.custoPorCabeca.serie('desembolso_cabeca_mes').first['valor'], 11.976);
    expect(lista.custoPorCabeca.detalhamento.first['descricao'], 'Despesa teste');
    expect(lista.percentualCustoFixo.valor('percentual_custo_fixo').exibir(), '27.778%');
    expect(lista.custoPorKgProduzido.disponivel, isFalse);
    expect(lista.custoPorKgProduzido.avisos, hasLength(1));
    expect(lista.custoPorKgProduzido.temAvisoFinanceiro, isTrue);
    expect(lista.financeiroMeta.avaliacaoEconomicaDisponivel, isFalse);
    expect(lista.financeiroMeta.baseCustos, 'competencia');
  });

  test('parser mantém lotação/custo/mortalidade do payload real', () {
    final lista = IndicadoresResponseModel.fromJson({
      'status': '01',
      'data': {
        'periodo': {
          'data_in': '01/07/2026',
          'data_out': '30/06/2027',
          'dias': 129,
        },
        'producao_rebanho': {
          'gmd_global': {
            'indicadores': {
              'gmd_global': {'qtd': null, 'string': 'kg/dia', 'texto': null},
              'qtd_pesagens': {'qtd': 0},
            },
            'graficos': {'gmd_global': []},
            'detalhamento': [],
          },
          'gmd_lote_categoria': {
            'indicadores': {'gmd_medio': {'qtd': null}},
            'graficos': {'gmd_lote': []},
            'detalhamento': [],
          },
          'kg_produzido': {
            'indicadores': {
              'kg_produzido': {'qtd': null, 'string': 'kg', 'texto': null},
            },
          },
          'lotacao': {
            'indicadores': {
              'ua_ha_total': {'qtd': 0.019},
              'cabecas': {'qtd': 7},
              'ua_total': {'qtd': 93.333},
              'area_total': {
                'qtd': 5000,
                'string': 'ha',
                'texto': '5000.000 ha',
              },
            },
            'graficos': {
              'lotacao_piquete': [
                {'id': 50, 'nome': 'teste', 'ua_ha': 0.0187},
              ],
            },
            'detalhamento': [
              {'id': 50, 'nome': 'teste', 'cabecas': 7, 'ocupacao': 'Ocupado'},
            ],
          },
          'rebanho_medio': {
            'indicadores': {
              'estoque_medio': {'qtd': 7.4},
              'total_entradas': {'qtd': 21},
              'total_saidas': {'qtd': 3},
              'saldo': {'qtd': 18},
            },
            'graficos': {'evolucao_estoque': []},
            'detalhamento': [],
          },
          'area_medida_utilizada': {
            'indicadores': {
              'area_media': {'qtd': null, 'string': 'ha', 'texto': null},
              'area_ativa': {
                'qtd': 5000,
                'string': 'ha',
                'texto': '5000.000 ha',
              },
            },
            'detalhamento': [],
          },
        },
        'desfrute_saidas': {
          'taxa_desfrute': {
            'indicadores': {
              'taxa_desfrute': {'qtd': null, 'string': '%', 'texto': null},
            },
            'detalhamento': [],
          },
          'taxa_abate': {'indicadores': {}, 'detalhamento': []},
          'taxa_giro': {'indicadores': {}, 'detalhamento': []},
          'mortalidade': {
            'indicadores': {
              'taxa_mortalidade': {
                'qtd': 13.514,
                'string': '%',
                'texto': '13.514%',
              },
              'animais_perdidos': {'qtd': 1},
              'estoque_medio': {'qtd': 7.4},
            },
            'detalhamento': [
              {'id_movimentacao': 175, 'app_animais_id': 401, 'tipo': 'morte'},
            ],
          },
        },
        'reproducao': {
          'taxa_prenhez': {
            'indicadores': {
              'valor': {'qtd': null, 'string': '%', 'texto': null},
            },
            'detalhamento': {'prenhas': 0, 'acasaladas': 0},
          },
        },
        'financeiro': {
          'custo_por_cabeca': {
            'indicadores': {
              'desembolso_cabeca_mes': {
                'qtd': 14.462,
                'string': r'R$',
                'texto': r'R$ 14.462',
              },
              'custo_producao_cabeca': {
                'qtd': 253.124,
                'string': r'R$',
                'texto': r'R$ 253.124',
              },
              'rebanho_medio': {
                'qtd': 7.4,
                'string': 'cab',
                'texto': '7.400 cab',
              },
            },
            'detalhamento': [
              {
                'id': 55,
                'descricao': 'teste',
                'classificacao': 'receita_operacional',
                'valor': 1050000,
              },
            ],
            'disponivel': true,
            'avisos': [],
          },
          'percentual_custo_fixo': {
            'indicadores': {
              'percentual_custo_fixo': {
                'qtd': 100,
                'string': '%',
                'texto': '100.000%',
              },
            },
            'disponivel': true,
          },
          'metadados': {
            'disponivel': true,
            'avaliacao_economica_disponivel': false,
          },
        },
      },
    });

    expect(lista.gmdGlobal.valor('gmd_global').temValor, isFalse);
    expect(lista.lotacao.valor('cabecas').exibir(inteiro: true), '7');
    expect(lista.rebanhoMedio.valor('estoque_medio').qtd, 7.4);
    expect(lista.areaMedia.valor('area_media').temValor, isFalse);
    expect(lista.areaMedia.valor('area_ativa').exibir(), '5000.000 ha');
    expect(lista.mortalidade.valor('taxa_mortalidade').exibir(), '13.514%');
    expect(
      lista.custoPorCabeca.valor('desembolso_cabeca_mes').exibir(),
      r'R$ 14.462',
    );
    expect(lista.custoPorCabeca.detalhamento, hasLength(1));
    expect(lista.percentualCustoFixo.valor('percentual_custo_fixo').exibir(), '100.000%');
  });
}
