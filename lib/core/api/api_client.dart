import 'package:costeira/config/ws_constantes.dart';
import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/api/api_response_utils.dart';
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
      final response = await _dio.post<dynamic>(
        path,
        data: formData ?? data,
        options: formData != null
            ? Options(headers: const {'Content-Type': 'multipart/form-data'})
            : null,
      );
      return response.data;
    } on DioException catch (error) {
      throw ApiException(
        _resolveMessage(error),
        statusCode: error.response?.statusCode,
      );
    } catch (_) {
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
