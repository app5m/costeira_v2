import 'package:costeira/core/api/api_client.dart';
import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/api/api_response_utils.dart';
import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/features/usuarios/domain/entities/sub_usuario_entity.dart';
import 'package:costeira/features/usuarios/domain/entities/sub_usuario_upsert_entity.dart';
import 'package:costeira/features/usuarios/domain/entities/usuario_permissao_entity.dart';
import 'package:costeira/features/usuarios/domain/repository/usuarios_datasource.dart';
import 'package:costeira/features/usuarios/infra/models/sub_usuario_model.dart';
import 'package:costeira/features/usuarios/infra/models/sub_usuario_upsert_request_model.dart';
import 'package:costeira/features/usuarios/infra/models/usuario_permissao_model.dart';

class UsuariosDatasourceImpl implements UsuariosDatasource {
  const UsuariosDatasourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<SubUsuarioEntity>> listUsuarios(int ownerUserId) async {
    final payload = {
      'token': WSConstantes.token,
      'id_vinculo_usuario': ownerUserId,
    };
    AppLogger.info('USUARIOS DATASOURCE: LIST PAYLOAD=$payload');
    final response = await _apiClient.post(
      WSConstantes.usuariosListar,
      data: payload,
    );
    AppLogger.success('USUARIOS DATASOURCE: LIST RAW RESPONSE=$response');
    return _parseUsers(response);
  }

  @override
  Future<List<UsuarioPermissaoEntity>> listPermissoes() async {
    final payload = {'token': WSConstantes.token};
    AppLogger.info('USUARIOS DATASOURCE: PERMISSOES PAYLOAD=$payload');
    final response = await _apiClient.post(
      WSConstantes.usuariosListarPermissoes,
      data: payload,
    );
    AppLogger.success('USUARIOS DATASOURCE: PERMISSOES RAW RESPONSE=$response');
    return _parsePermissoes(response);
  }

  @override
  Future<ApiMessage> saveUsuario(SubUsuarioUpsertEntity usuario) async {
    final payload = SubUsuarioUpsertRequestModel.fromEntity(usuario).data;
    AppLogger.info('USUARIOS DATASOURCE: SAVE PAYLOAD=$payload');
    final response = await _apiClient.post(
      WSConstantes.usuariosAdicionar,
      data: payload,
    );
    AppLogger.success('USUARIOS DATASOURCE: SAVE RAW RESPONSE=$response');
    return _parseMutation(
      response,
      fallbackMessage: usuario.id == null
          ? 'Usuario cadastrado com sucesso'
          : 'Usuario atualizado com sucesso',
    );
  }

  List<SubUsuarioEntity> _parseUsers(dynamic response) {
    return _entityMaps(response)
        .map(SubUsuarioModel.fromJson)
        .where((item) => item.id > 0 || item.nome.isNotEmpty)
        .toList(growable: false);
  }

  List<UsuarioPermissaoEntity> _parsePermissoes(dynamic response) {
    return _entityMaps(response)
        .map(UsuarioPermissaoModel.fromJson)
        .where((item) => item.id > 0 && item.isEnabled)
        .toList(growable: false);
  }

  List<Map<String, dynamic>> _entityMaps(dynamic response) {
    final list = responseAsList(
      response,
    ).where((item) => !_looksLikeStatusEnvelope(item)).toList(growable: false);
    if (list.isNotEmpty) {
      return list;
    }

    final map = responseAsMap(response);
    for (final key in ['data', 'usuarios', 'rows', 'items', 'permissoes']) {
      final nested = map[key];
      if (nested is List) {
        return nested
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList(growable: false);
      }
    }
    return const [];
  }

  bool _looksLikeStatusEnvelope(Map<String, dynamic> map) {
    final hasStatusOrMsg = map.containsKey('status') || map.containsKey('msg');
    final hasEntity =
        map['id'] != null ||
        (map['nome']?.toString().trim().isNotEmpty ?? false);
    return hasStatusOrMsg && !hasEntity;
  }

  ApiMessage _parseMutation(
    dynamic response, {
    required String fallbackMessage,
  }) {
    final parsed = ApiMessage.fromResponse(response);
    if (!parsed.isSuccess) {
      throw ApiException(parsed.message);
    }
    return parsed.message.trim().isEmpty
        ? ApiMessage(status: parsed.status, message: fallbackMessage)
        : parsed;
  }
}
