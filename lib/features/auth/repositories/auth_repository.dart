import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/core/api/api_client.dart';
import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/api/api_response_utils.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/core/models/user_coordinates.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/features/auth/auth_bypass.dart';
import 'package:costeira/features/auth/models/auth_result.dart';
import 'package:costeira/features/auth/models/cnpj_lookup_result.dart';
import 'package:costeira/features/auth/models/register_draft.dart';
import 'package:costeira/features/auth/models/user_session.dart';

class AuthRepository {
  AuthRepository({ApiClient? client}) : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  Future<CnpjLookupResult> lookupCnpj(String cnpj) async {
    final response = await _client.post(
      WSConstantes.listCnpj,
      data: {'cnpj': cnpj, 'token': WSConstantes.token},
      timeout: const Duration(seconds: 60),
    );

    final message = ApiMessage.fromResponse(response);
    final map = responseAsMap(response);
    if (map['status'] != null && !message.isSuccess) {
      throw ApiException(message.message);
    }

    return CnpjLookupResult.fromJson(map);
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
    final parsed = UserSession.fromLoginResponse(map, tipo);
    var user = parsed.id > 0 ? parsed : null;
    if (user == null &&
        AuthBypass.shouldBypass(message.status, message.message)) {
      user = await SessionStorage.getPendingUser(email: email);
    }

    return AuthResult(message: message, user: user);
  }

  Future<AuthResult> register({
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

    final responseMap = responseAsMap(response);
    final message = ApiMessage.fromResponse(response);
    final tipo =
        int.tryParse(responseMap['tipo']?.toString() ?? '') ??
        draft.tipoPessoa;
    final parsed = UserSession.fromLoginResponse(responseMap, tipo);
    final user = parsed.id > 0 ? parsed : null;
    if (user != null) {
      await SessionStorage.savePendingUser(user);
    }

    AppLogger.success('AUTH CADASTRO: RETORNO BRUTO=$response');
    AppLogger.success(
      'AUTH CADASTRO: POSSIVEL USER_ID=${_extractRegisteredUserId(responseMap)} MAP=$responseMap',
    );

    return AuthResult(message: message, user: user);
  }

  String _extractRegisteredUserId(Map<String, dynamic> map) {
    const keys = [
      'id',
      'user_id',
      'app_users_id',
      'app_user_id',
      'id_user',
      'usuarios_id',
    ];

    for (final key in keys) {
      final value = map[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }

    final data = map['data'];
    if (data is Map) {
      return _extractRegisteredUserId(Map<String, dynamic>.from(data));
    }

    return 'nao encontrado';
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
