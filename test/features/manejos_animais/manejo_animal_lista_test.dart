import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/features/animals/infra/models/animal_lot_model.dart';
import 'package:costeira/features/manejos_animais/infra/models/manejo_animal_lista_request_model.dart';
import 'package:costeira/features/manejos_animais/infra/models/manejo_animal_lista_response_model.dart';
import 'package:costeira/features/manejos_animais/presentation/page_controllers/manejo_reprodutivo_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('lista manda id_categoria da fazenda', () {
    final data = ManejoAnimalListaRequestModel.create(
      appUsersId: 450,
      appFazendasId: 451,
      idCategoria: 1,
    ).data;

    expect(data['id_categoria'], 1);
    expect(data['app_fazendas_id'], 451);
    expect(data.containsKey('id_potreiro'), isFalse);
    expect(data.containsKey('estacao_ativa'), isFalse);
    expect(data.containsKey('data_referencia'), isFalse);
  });

  test('estação ativa manda data de referência', () {
    final data = ManejoAnimalListaRequestModel.create(
      appUsersId: 450,
      appFazendasId: 451,
      idCategoria: 8,
      estacaoAtiva: true,
      dataReferencia: '13/10/2026',
    ).data;

    expect(data['id_categoria'], 8);
    expect(data['estacao_ativa'], isTrue);
    expect(data['data_referencia'], '13/10/2026');
  });

  test('lista lê data e animais do envelope', () {
    final lista = ManejoAnimalListaResponseModel.fromResponse([
      {
        'rows': 1,
        'data': [
          {
            'id': 10,
            'id_categoria': 1,
            'data': '12/10/2026',
            'obs': 'lote aaaa',
            'animais': [
              {'id': 232},
              {'id': 231},
            ],
          },
        ],
      },
    ]);

    expect(lista.itens, hasLength(1));
    expect(lista.itens.first.data, '12/10/2026');
    expect(lista.itens.first.detalhe, '2 animal(is) · lote aaaa');
  });

  test('estação lê lote, duração e brinco', () {
    final lista = ManejoAnimalListaResponseModel.fromResponse([
      {
        'data': [
          {
            'id': 4,
            'id_categoria': 8,
            'data': '01/09/2026',
            'duracao_estacao': 90,
            'lote_nome': 'Vacas',
            'animais': [
              {'id': 132, 'brinco': '1500'},
            ],
          },
        ],
      },
    ]);

    final item = lista.itens.single;
    expect(item.lote, 'Vacas');
    expect(item.duracao, '90');
    expect(item.brinco, '1500');
    expect(item.detalhe, contains('90 dias'));
  });

  test('mês previsto desconta o tempo de prenhez', () {
    expect(mesPrevistoParto(DateTime(2026, 10, 13), tardia: false), 'Junho de 2027');
    expect(mesPrevistoParto(DateTime(2026, 10, 13), tardia: true), 'Maio de 2027');
  });

  test('lote guarda ids e marca ausência de brinco', () {
    final lote = AnimalLotModel.fromJson({
      'id': 18,
      'nome': 'Vaca',
      'animais': [
        {'id': 132, 'sexo': 2, 'brinco': null, 'categoria_nome': 'Vaca'},
      ],
    });

    expect(lote.sexo, 2);
    expect(lote.animalIds, [132]);
    expect(lote.temBrinco, isFalse);
  });

  test('lista com status 02 vira erro', () {
    expect(
      () => ManejoAnimalListaResponseModel.fromResponse([
        {'status': '02', 'msg': 'app_fazendas_id é obrigatório'},
      ]),
      throwsA(isA<ApiException>()),
    );
  });
}
