import 'package:costeira/core/common/get_list/infra/models/get_list_response_model.dart';
import 'package:costeira/features/auth/models/user_session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('login lê id_grupo do admin', () {
    final session = UserSession.fromLoginResponse({
      'id': 10,
      'nome': 'Admin',
      'email': 'admin@costeira.app',
      'id_grupo': 1,
    }, 1);

    expect(session.isAdmin, isTrue);
    expect(session.idGrupo, 1);
  });

  test('lista_clientes guarda id, nome, fantasia e cnpj', () {
    final lista = GetListResponseModel.fromJson({
      'animais_categorias': const [],
      'animais_bases_raciais': const [],
      'animais_sistemas_producoes': const [],
      'lista_clientes': [
        {
          'id': 441,
          'nome': 'Guilherme Guillii',
          'nome_fantasia': 'App5M',
          'cnpj': '67.442.354/0001-73',
        },
      ],
    });

    final cliente = lista.clientes.single;
    expect(cliente.id, 441);
    expect(cliente.combina('guilherme'), isTrue);
    expect(cliente.combina('67442354'), isTrue);
    expect(cliente.combina('outra'), isFalse);
  });
}
