import 'package:costeira/core/api/api_client.dart';
import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/core/offline/offline_api_service.dart';
import 'package:costeira/core/storage/session_storage.dart';

class UtilsRepository {
  UtilsRepository({ApiClient? client, OfflineApiService? offlineApiService})
    : _client = client ?? ApiClient.instance,
      _offlineApiService = offlineApiService;

  final ApiClient _client;
  final OfflineApiService? _offlineApiService;

  Future<Map<String, dynamic>> fetchLista({required int sexo}) async {
    final user = await SessionStorage.getUserSession();
    final payload = {
      'sexo': sexo,
      'token': WSConstantes.token,
      if (user != null) 'id_user': user.id,
    };
    final offlineApiService = _offlineApiService;
    if (offlineApiService != null) {
      return offlineApiService.postCached<Map<String, dynamic>>(
        endpoint: WSConstantes.utilLista,
        payload: payload,
        parser: _asMap,
        missingCacheMessage: 'Sem conexão e sem dados salvos para listas auxiliares.',
        rawResponseLog: 'UTILS REPOSITORY: LISTA RAW RESPONSE',
      );
    }

    final response = await _client.post(WSConstantes.utilLista, data: payload);

    return _asMap(response);
  }

  Map<String, dynamic> _asMap(dynamic response) {
    if (response is Map<String, dynamic>) {
      return response;
    }

    return <String, dynamic>{};
  }
}
