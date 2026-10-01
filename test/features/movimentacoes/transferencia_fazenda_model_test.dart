import 'package:costeira/features/movimentacoes/transferencias/infra/models/transferencia_fazenda_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('mapeia transferência enviada', () {
    final item = TransferenciaFazendaModel.fromJson({
      'id': 161,
      'app_fazendas_id': 451,
      'app_fazendas_id_dest': 454,
      'data': '01/10/2026',
      'gta_documento': '5465465',
      'status_transferencia': 2,
      'status_string': 'Pendente',
      'valor_total': '0.00',
      'valor_unitario': '0.00',
      'valor_total_string': ' R\$ 0,00',
      'valor_unitario_string': ' R\$ 0,00',
      'fazenda_origem': {'id': 451, 'nome': 'Thiago farm', 'cnpj': '26056565000184'},
      'fazenda_destino': {'id': 454, 'nome': 'farm 02', 'cnpj': '26056565000184'},
      'animais': [
        {
          'id': 321,
          'app_animais_id': 190,
          'brinco': '0001',
          'peso_total': 30,
          'categoria': {'id': 5, 'nome': 'Terneira'},
          'lote': {'id': 22, 'nome': 'lote teste aaaabb'},
          'potreiro': {'id': 42, 'nome': 'teste piquete'},
        },
        {'id': 322, 'app_animais_id': 176, 'brinco': '0003'},
      ],
    });

    expect(item.id, 161);
    expect(item.pendente, isTrue);
    expect(item.fazendaDestino?.nome, 'farm 02');
    expect(item.valorTotal, 'R\$ 0,00');
    expect(item.brincos, ['0001', '0003']);
    expect(item.animais.first.appAnimaisId, 190);
    expect(item.animais.first.categoria, 'Terneira');
    expect(item.animais.first.piquete, 'teste piquete');
    expect(item.animais.first.peso, 30);
  });
}
