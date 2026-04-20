import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/api/api_response_utils.dart';
import 'package:costeira/core/config/ws_constantes.dart';
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
  }) async {
    try {
      AppLogger.info('API CLIENT: INICIANDO POST PATH=$path');
      AppLogger.debug('API CLIENT: PAYLOAD=$data');

      final response = await _dio.post<dynamic>(
        path,
        data: formData ?? data,
        options: Options(
          responseType: ResponseType.plain,
          headers: formData != null
              ? const {'Content-Type': 'multipart/form-data'}
              : null,
        ),
      );

      AppLogger.success('API CLIENT: RESPOSTA BRUTA PATH=$path');
      AppLogger.success('API CLIENT RAW RESPONSE: ${response.data}');

      return response.data;
    } on DioException catch (error) {
      AppLogger.error(
        'API CLIENT: ERRO PATH=$path STATUS=${error.response?.statusCode} RAW=${error.response?.data}',
      );
      throw ApiException(
        _resolveMessage(error),
        statusCode: error.response?.statusCode,
      );
    } catch (error) {
      AppLogger.error('API CLIENT: ERRO INESPERADO PATH=$path ERROR=$error');
      throw ApiException('Ocorreu um erro inesperado.');
    }
  }

  String _resolveMessage(DioException error) {
    final map = responseAsMap(error.response?.data);
    if (map['msg'] != null) {
      return map['msg'].toString();
    }
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return 'Tempo de conexão esgotado.';
    }
    return 'Não foi possível concluir a requisição.';
  }
}
