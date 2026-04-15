import 'dart:io';

import 'package:costeira/config/ws_constantes.dart';
import 'package:costeira/core/api/api_client.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/core/api/api_response_utils.dart';
import 'package:costeira/features/account/models/account_profile.dart';
import 'package:dio/dio.dart';

class AccountRepository {
  AccountRepository({ApiClient? client})
    : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  Future<AccountProfile> fetchProfile({required int userId}) async {
    final response = await _client.post(
      WSConstantes.perfil,
      data: {'id_user': userId, 'token': WSConstantes.token},
    );
    return AccountProfile.fromJson(responseAsMap(response));
  }

  Future<ApiMessage> deactivateAccount(int id) async {
    final response = await _client.post(
      WSConstantes.desativarConta,
      data: {'id': id, 'token': WSConstantes.token},
    );
    return ApiMessage.fromResponse(response);
  }

  Future<ApiMessage> updatePassword({
    required int id,
    required String password,
  }) async {
    final response = await _client.post(
      WSConstantes.updatePassword,
      data: {'id': id, 'password': password, 'token': WSConstantes.token},
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

  Future<ApiMessage> updateUser({
    required int id,
    required int tipoPessoa,
    required String name,
    required String phone,
    required String birthDate,
    required String cpf,
  }) async {
    final response = await _client.post(
      WSConstantes.updateUser,
      data: {
        'id': id,
        'tipo_pessoa': tipoPessoa,
        'nome': name,
        'celular': phone,
        'data_nascimento': birthDate,
        'cpf': cpf,
        'token': WSConstantes.token,
      },
    );
    return ApiMessage.fromResponse(response);
  }
}
