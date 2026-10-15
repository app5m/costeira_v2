import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/api/api_response_utils.dart';
import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/core/utils/app_logger.dart';
import 'package:dio/dio.dart';

class ApiClient {
  ApiClient._internal()
    : _dio = Dio(
        BaseOptions(
          baseUrl: WSConstantes.urlBase,
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 20),
          sendTimeout: const Duration(seconds: 20),
          headers: const {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );

  static final ApiClient instance = ApiClient._internal();

  final Dio _dio;

  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? data,
    FormData? formData,
    String? baseUrl,
    Duration? timeout,
  }) async {
    try {
      final resolvedPath = _resolvePath(path, baseUrl);
      final payload = _payloadDoCliente(path, data);
      AppLogger.info('API CLIENT: INICIANDO POST PATH=$resolvedPath');
      AppLogger.debug('API CLIENT: PAYLOAD=$payload');

      final response = await _dio.post<dynamic>(
        resolvedPath,
        data: formData ?? payload,
        options: Options(
          responseType: ResponseType.plain,
          sendTimeout: timeout,
          receiveTimeout: timeout,
          headers: formData != null
              ? const {'Content-Type': 'multipart/form-data'}
              : null,
        ),
      );

      AppLogger.success('API CLIENT: RESPOSTA BRUTA PATH=$path');
      AppLogger.success('API CLIENT RAW RESPONSE: ${response.data}');

      return recoverEmbeddedJson(response.data);
    } on DioException catch (error) {
      AppLogger.error(
        'API CLIENT: ERRO PATH=$path STATUS=${error.response?.statusCode} RAW=${error.response?.data}',
      );
      throw ApiException(
        _resolveMessage(error),
        statusCode: error.response?.statusCode,
        isTimeout: _isTimeout(error),
        isOfflineEligible: error.response == null,
      );
    } catch (error) {
      AppLogger.error('API CLIENT: ERRO INESPERADO PATH=$path ERROR=$error');
      throw ApiException('Ocorreu um erro inesperado.');
    }
  }

  Map<String, dynamic>? _payloadDoCliente(
    String path,
    Map<String, dynamic>? data,
  ) {
    final clientId = SessionStorage.cachedManagedClientId;
    if (data == null || clientId == null || _mantemAdmin(path)) {
      return data;
    }
    final payload = Map<String, dynamic>.from(data);
    if (payload.containsKey('app_users_id')) {
      payload['app_users_id'] = clientId;
    }
    if (payload.containsKey('id_user')) {
      payload['id_user'] = clientId;
    }
    if (payload.containsKey('id_vinculo_usuario')) {
      payload['id_vinculo_usuario'] = clientId;
    }
    return payload;
  }

  bool _mantemAdmin(String path) {
    const livres = [
      WSConstantes.login,
      WSConstantes.doisFatores,
      WSConstantes.perfil,
      WSConstantes.utilLista,
      WSConstantes.saveFcm,
    ];
    return livres.any(path.contains);
  }

  String _resolvePath(String path, String? baseUrl) {
    if (baseUrl == null || baseUrl.trim().isEmpty) {
      return path;
    }

    final normalizedBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return '$normalizedBase$normalizedPath';
  }

  String _resolveMessage(DioException error) {
    final map = responseAsMap(error.response?.data);
    if (map['msg'] != null) {
      return map['msg'].toString();
    }
    if (_isTimeout(error)) {
      return 'Tempo de conexão esgotado.';
    }
    return 'Não foi possível concluir a requisição.';
  }

  bool _isTimeout(DioException error) {
    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout;
  }
}
