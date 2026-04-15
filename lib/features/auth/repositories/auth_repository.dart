import 'package:costeira/config/ws_constantes.dart';
import 'package:costeira/core/api/api_client.dart';
import 'package:costeira/core/api/api_response_utils.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/core/models/user_coordinates.dart';
import 'package:costeira/features/auth/models/auth_result.dart';
import 'package:costeira/features/auth/models/register_draft.dart';
import 'package:costeira/features/auth/models/user_session.dart';

class AuthRepository {
  AuthRepository({ApiClient? client}) : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  Future<ApiMessage> validateCnpj(String cnpj) async {
    final response = await _client.post(
      WSConstantes.listCnpj,
      data: {'cnpj': cnpj, 'token': WSConstantes.token},
    );

    return ApiMessage.fromResponse(response);
  }

  Future<ApiMessage> sendTwoFactor({
    required String email,
    required String password,
    required UserCoordinates coordinates,
  }) async {
    final response = await _client.post(
      WSConstantes.doisFatores,
      data: {
        'email': email,
        'password': password,
        'latitude': coordinates.latitude,
        'longitude': coordinates.longitude,
        'token': WSConstantes.token,
      },
    );

    return ApiMessage.fromResponse(response);
  }

  Future<AuthResult> login({
    required String email,
    required String password,
    required String code,
    required int tipo,
  }) async {
    final response = await _client.post(
      WSConstantes.login,
      data: {
        'email': email,
        'password': password,
        'codigo': code,
        'token': WSConstantes.token,
      },
    );

    final message = ApiMessage.fromResponse(response);
    final map = responseAsMap(response);
    final user = message.isSuccess
        ? UserSession.fromLoginResponse(map, tipo)
        : null;

    return AuthResult(message: message, user: user);
  }

  Future<ApiMessage> register({
    required RegisterDraft draft,
    required UserCoordinates coordinates,
  }) async {
    final response = await _client.post(
      WSConstantes.cadastroApp,
      data: {
        'tipo_pessoa': draft.tipoPessoa,
        'nome': draft.nome,
        'celular': draft.celular,
        'email': draft.email,
        'documento': draft.documento,
        'cnpj': draft.cnpj,
        'razao_social': draft.razaoSocial,
        'nome_fantasia': draft.nomeFantasia,
        'ie': draft.ie,
        'password': draft.password,
        'latitude': coordinates.latitude,
        'longitude': coordinates.longitude,
        'token': WSConstantes.token,
      },
    );

    return ApiMessage.fromResponse(response);
  }

  Future<ApiMessage> recoverPassword(String email) async {
    final response = await _client.post(
      WSConstantes.recuperarSenha,
      data: {'email': email, 'token': WSConstantes.token},
    );

    return ApiMessage.fromResponse(response);
  }

  Future<ApiMessage> saveFcm({
    required int userId,
    required int type,
    required String registrationId,
  }) async {
    final response = await _client.post(
      WSConstantes.saveFcm,
      data: {
        'id_user': userId,
        'type': type,
        'registration_id': registrationId,
        'token': WSConstantes.token,
      },
    );

    return ApiMessage.fromResponse(response);
  }
}
