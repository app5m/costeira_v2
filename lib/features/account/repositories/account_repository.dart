import 'dart:io';

import 'package:costeira/config/ws_constantes.dart';
import 'package:costeira/core/api/api_client.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:dio/dio.dart';

class AccountRepository {
  AccountRepository({ApiClient? client}) : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  Future<ApiMessage> deactivateAccount(int id) async {
    final response = await _client.post(
      WSConstantes.desativarConta,
      data: {
        'id': id,
        'token': WSConstantes.token,
      },
    );
    return ApiMessage.fromResponse(response);
  }

  Future<ApiMessage> updatePassword({
    required int id,
    required String password,
  }) async {
    final response = await _client.post(
      WSConstantes.updatePassword,
      data: {
        'id': id,
        'password': password,
        'token': WSConstantes.token,
      },
    );
    return ApiMessage.fromResponse(response);
  }

  Future<ApiMessage> updateAvatar({
    required int userId,
    required File imageFile,
  }) async {
    final formData = FormData.fromMap({
      'id_user': userId.toString(),
      'url': await MultipartFile.fromFile(imageFile.path),
      'token': WSConstantes.token,
    });

    final response = await _client.post(
      WSConstantes.updateAvatar,
      formData: formData,
    );
    return ApiMessage.fromResponse(response);
  }
}
