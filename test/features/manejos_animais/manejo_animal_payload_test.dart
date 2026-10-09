import 'package:costeira/features/animals/infra/models/animal_model.dart';
import 'package:costeira/features/manejos_animais/infra/models/manejo_animal_request_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ultimo peso vazio quando rows é 0', () {
    final animal = AnimalModel.fromJson({
      'id': 133,
      'peso': '320',
      'ultimo_peso': {'rows': 0},
    });

    expect(animal.ultimoPeso?.temPesagem, isFalse);
    expect(animal.peso, 320);
  });

  test('ultimo peso traz peso, data e dias', () {
    final animal = AnimalModel.fromJson({
      'id': 132,
      'ultimo_peso': {
        'rows': 1,
        'data_br': '01/09/2026',
        'peso': '350',
        'qtd_dias': 30,
      },
    });

    expect(animal.ultimoPeso?.temPesagem, isTrue);
    expect(animal.ultimoPeso?.peso, 350);
    expect(animal.ultimoPeso?.dataBr, '01/09/2026');
    expect(animal.ultimoPeso?.qtdDias, 30);
  });

  test('payload manda categoria, dosagem total e tipo 2', () {
    final data = ManejoAnimalRequestModel.create(
      appUsersId: 450,
      appFazendasId: 451,
      fields: {
        'id_categoria': 2,
        'id_estoque': 10,
        'tipo_dosagem': 2,
        'dosagem': 80,
        'animais': [
          {'id': 133},
        ],
      },
    ).data;

    expect(data['app_users_id'], 450);
    expect(data['app_fazendas_id'], 451);
    expect(data['id_categoria'], 2);
    expect(data['tipo_dosagem'], 2);
    expect(data['dosagem'], 80);
    expect(data['token'], isNotEmpty);
  });
}
