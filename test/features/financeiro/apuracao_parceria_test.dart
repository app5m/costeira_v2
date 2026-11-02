import 'package:costeira/features/financeiro/domain/apuracao_parceria.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('soma totais a partir de itens quando API não manda resumo', () {
    final flat = flattenApuracaoParceria({
      'venda_id': '3',
      'parceria_id': '5',
      'hash_simulacao': 'abc',
      'itens': [
        {
          'brinco': 'DFWDF',
          'receita_bruta': '2000.00',
          'capital_investidor': '2000.00',
          'ganho_valor': '0.00',
          'ganho_fazenda': '0.00',
          'ganho_investidor': '0.00',
          'custo_operacional': '125.00',
          'reembolso_custo': '62.50',
          'margem_fazenda': '-62.50',
          'receita_bruta_string': ' R\$ 2.000,00',
          'capital_investidor_string': ' R\$ 2.000,00',
          'custo_operacional_string': ' R\$ 125,00',
          'reembolso_custo_string': ' R\$ 62,50',
          'margem_fazenda_string': ' R\$ -62,50',
        },
      ],
    });

    expect(flat['receita_bruta'], 2000.0);
    expect(flat['capital_investidor'], 2000.0);
    expect(flat['capital'], 2000.0);
    expect(flat['ganho_valor'], 0.0);
    expect(flat['ganho_investidor'], 0.0);
    expect(flat['ganho_fazenda'], 0.0);
    expect(flat['custo_operacional'], 125.0);
    expect(flat['reembolso_custo'], 62.5);
    expect(flat['reembolso'], 62.5);
    expect(flat['margem_fazenda'], -62.5);
  });

  test('soma vários itens', () {
    final flat = flattenApuracaoParceria({
      'itens': [
        {
          'receita_bruta': '1000.00',
          'capital_investidor': '500.00',
          'custo_operacional': '10.00',
          'reembolso_custo': '5.00',
          'margem_fazenda': '-5.00',
          'ganho_valor': '100.00',
          'ganho_investidor': '40.00',
          'ganho_fazenda': '60.00',
        },
        {
          'receita_bruta': '500.00',
          'capital_investidor': '250.00',
          'custo_operacional': '20.00',
          'reembolso_custo': '10.00',
          'margem_fazenda': '-10.00',
          'ganho_valor': '50.00',
          'ganho_investidor': '20.00',
          'ganho_fazenda': '30.00',
        },
      ],
    });

    expect(flat['receita_bruta'], 1500.0);
    expect(flat['capital'], 750.0);
    expect(flat['custo_operacional'], 30.0);
    expect(flat['reembolso'], 15.0);
    expect(flat['ganho_valor'], 150.0);
    expect(flat['margem_fazenda'], -15.0);
  });
}
