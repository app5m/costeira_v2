import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/core/api/api_client.dart';

class UtilsRepository {
  UtilsRepository({ApiClient? client}) : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  Future<Map<String, dynamic>> fetchLista({required int sexo}) async {
    final response = await _client.post(
      WSConstantes.utilLista,
      data: {'sexo': sexo, 'token': WSConstantes.token},
    );

    if (response is Map<String, dynamic>) {
      return response;
    }

    return <String, dynamic>{};
  }
}
