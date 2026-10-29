import 'package:costeira/features/financeiro/domain/financeiro_mock.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('lista vazia com rows:0 não vira contrato', () {
    final lista = [
      {'rows': 0, 'msg': 'Nenhum registro encontrado.'},
    ];
    final parseados = [
      for (final item in lista)
        if (item['rows'] != 0 && item['id'] != null) ParceriaFin.de(Map<String, dynamic>.from(item)),
    ];
    expect(parseados, isEmpty);
  });

  test('parceria com entradas vazias (sentinel) fica sem entradas', () {
    final parceria = ParceriaFin.de({
      'id': '1',
      'investidor_id': '2',
      'investidor_nome': 'Investidor X',
      'codigo': 'PAR-001',
      'data_inicio': '28/10/2026',
      'data_fim': null,
      'percentual_custo_investidor': '40.000000',
      'percentual_ganho_investidor': '40.000000',
      'estado': 'ativo',
      'entradas': [
        {'rows': 0, 'msg': 'Nenhum registro encontrado.'},
      ],
    });
    expect(parceria.id, 1);
    expect(parceria.ativo, isTrue);
    expect(parceria.investidorNome, 'Investidor X');
    expect(parceria.entradas, isEmpty);
    expect(parceria.qtdAnimais, 0);
  });

  test('parceria com entradas reais parseia brinco e peso', () {
    final parceria = ParceriaFin.de({
      'id': '1',
      'investidor_id': '2',
      'investidor_nome': 'Investidor Revisao',
      'codigo': 'PAR-REV',
      'data_inicio': '28/10/2026',
      'percentual_custo_investidor': '40.000000',
      'percentual_ganho_investidor': '40.000000',
      'estado': 'ativo',
      'entradas': [
        {
          'id': '2',
          'data': '28/10/2026',
          'quantidade_animais': 1,
          'animais': [
            {
              'id': '2',
              'app_animais_id': '422',
              'peso_entrada_kg': '350.000000',
              'data_saida': null,
              'brinco': 'REV123',
              'animal': {'id': '422', 'brinco': 'REV123'},
            },
          ],
        },
        {
          'rows': 0,
          'msg': 'Nenhum registro encontrado.',
        },
      ],
    });
    expect(parceria.entradas.length, 1);
    expect(parceria.entradas.first.id, 2);
    expect(parceria.entradas.first.data, '28/10/2026');
    expect(parceria.qtdAnimais, 1);
    expect(parceria.entradas.first.animais.single.brinco, 'REV123');
    expect(parceria.entradas.first.animais.single.pesoEntradaKg, '350.000000');
    expect(parceria.entradas.first.animais.single.appAnimaisId, 422);
  });

  test('parceria parseia lancamentos custos e vendas ignorando sentinel', () {
    final parceria = ParceriaFin.de({
      'id': '3',
      'investidor_id': '2',
      'investidor_nome': 'Inv',
      'codigo': 'PAR-R2',
      'data_inicio': '28/10/2026',
      'percentual_custo_investidor': '40',
      'percentual_ganho_investidor': '40',
      'estado': 'ativo',
      'entradas': [
        {'rows': 0, 'msg': 'Nenhum registro encontrado.'},
      ],
      'lancamentos': [
        {
          'id': '10',
          'descricao': 'Sanitário',
          'categoria_id': '19',
          'valor': '180.00',
          'valor_liquidado': '0.00',
          'saldo_pendente': '180.00',
          'estado': 'confirmado',
          'data_competencia': '28/10/2026',
        },
        {
          'id': '11',
          'descricao': 'Venda bruta',
          'categoria_id': '7',
          'valor': '1440.00',
          'valor_liquidado': '0.00',
          'saldo_pendente': '1440.00',
          'estado': 'confirmado',
          'data_competencia': '28/10/2026',
          'fluxo': 'entrada',
        },
        {'rows': 0, 'msg': 'Nenhum registro encontrado.'},
      ],
      'custos': [
        {
          'lancamento_id': '10',
          'app_animais_id': '422',
          'valor': '180.00',
          'descricao': 'Sanitário',
          'data_competencia': '28/10/2026',
          'brinco': 'REV123',
        },
        {'rows': 0},
      ],
      'vendas': [
        {
          'id': '5',
          'data': '28/10/2026',
          'preco_kg': '3.20',
          'comprador_nome': 'Frigo',
          'quantidade_animais': 1,
          'apuracao_id': null,
        },
        {'rows': 0},
      ],
    });
    expect(parceria.despesas.length, 1);
    expect(parceria.despesas.first.descricao, 'Sanitário');
    expect(parceria.aReceber, 1440);
    expect(parceria.aPagar, 180);
    expect(parceria.custos.single.brinco, 'REV123');
    expect(parceria.vendas.single.id, 5);
    expect(parceria.vendas.single.acertoConfirmado, isFalse);
  });

  test('venda com apuracao_id fica acertada', () {
    final venda = VendaParceriaFin.de({
      'id': '9',
      'data': '29/10/2026',
      'preco_kg': '10.00',
      'apuracao_id': '3',
    });
    expect(venda.acertoConfirmado, isTrue);
  });

  test('apuracoes da parceria marcam venda como acertada', () {
    final parceria = ParceriaFin.de({
      'id': '5',
      'investidor_id': '3',
      'investidor_nome': 'Thiagoo',
      'codigo': '1005K',
      'data_inicio': '28/10/2026',
      'percentual_custo_investidor': '50',
      'percentual_ganho_investidor': '50',
      'estado': 'ativo',
      'vendas': [
        {
          'id': '3',
          'data': '29/10/2026',
          'preco_kg': '10.00',
          'quantidade_animais': 1,
        },
      ],
      'apuracoes': [
        {'id': '8', 'venda_id': '3', 'estado': 'confirmado'},
        {'rows': 0, 'msg': 'Nenhum registro encontrado.'},
      ],
    });
    expect(parceria.vendas.single.acertoConfirmado, isTrue);
  });

  test('apuracao com venda_id só no parametros_snapshot marca venda', () {
    final parceria = ParceriaFin.de({
      'id': '5',
      'investidor_id': '3',
      'investidor_nome': 'Thiagoo',
      'codigo': '1005K',
      'data_inicio': '28/10/2026',
      'percentual_custo_investidor': '50',
      'percentual_ganho_investidor': '50',
      'estado': 'ativo',
      'vendas': [
        {'id': '4', 'data': '2026-10-29', 'preco_kg': '50.00'},
        {'id': '1', 'data': '2026-10-29', 'preco_kg': '50.00'},
      ],
      'apuracoes': [
        {
          'id': '4',
          'estado': 'confirmado',
          'parametros_snapshot':
              '{"venda_id":"4","parceria_id":"5","hash_simulacao":"abc"}',
        },
      ],
    });
    expect(parceria.vendas.where((v) => v.id == 4).single.acertoConfirmado, isTrue);
    expect(parceria.vendas.where((v) => v.id == 1).single.acertoConfirmado, isFalse);
  });
}
