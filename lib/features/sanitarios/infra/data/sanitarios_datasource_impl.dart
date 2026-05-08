import 'package:costeira/core/api/api_client.dart';
import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/api/api_response_utils.dart';
import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/features/sanitarios/domain/entities/sanitario.dart';
import 'package:costeira/features/sanitarios/domain/repository/sanitarios_datasource.dart';
import 'package:costeira/features/sanitarios/infra/models/sanitario_models.dart';

class SanitariosDatasourceImpl implements SanitariosDatasource {
  const SanitariosDatasourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<SanitariosListEntity> getSanitarios(
    SanitariosFilterEntity filter,
  ) async {
    final payload = SanitariosFilterRequestModel.fromEntity(filter).data;
    AppLogger.info('SANITARIOS DATASOURCE: LIST PAYLOAD=$payload');

    final response = await _apiClient.post(
      WSConstantes.sanitariosListar,
      data: payload,
    );
    AppLogger.success('SANITARIOS DATASOURCE: LIST RAW RESPONSE=$response');

    final wrappers = responseAsList(response);
    if (wrappers.isEmpty) {
      return const SanitariosListEntity(rows: 0, lista: []);
    }

    return SanitariosListResponseModel.fromWrapper(wrappers.first);
  }

  @override
  Future<ApiMessage> createSanitario(SanitarioUpsertEntity sanitario) async {
    if (sanitario.appUsersId == null) {
      throw ApiException('Usuário não autenticado para cadastrar sanitário.');
    }

    final payload = SanitarioUpsertRequestModel.create(sanitario).data;
    AppLogger.info('SANITARIOS DATASOURCE: CREATE PAYLOAD=$payload');

    final response = await _apiClient.post(
      WSConstantes.sanitariosAdicionar,
      data: payload,
    );
    AppLogger.success('SANITARIOS DATASOURCE: CREATE RAW RESPONSE=$response');

    return _parseMutationResponse(
      response,
      operationName: 'CREATE SANITARIO',
      expectedSuccessMessage: 'Sanitário cadastrado com sucesso',
    );
  }

  @override
  Future<ApiMessage> updateSanitario(SanitarioUpsertEntity sanitario) async {
    if (sanitario.id == null) {
      throw ApiException('Informe o id do sanitário para atualizar.');
    }
    if (sanitario.appUsersId == null) {
      throw ApiException('Usuário não autenticado para atualizar sanitário.');
    }

    final payload = SanitarioUpsertRequestModel.update(sanitario).data;
    AppLogger.info('SANITARIOS DATASOURCE: UPDATE PAYLOAD=$payload');

    final response = await _apiClient.post(
      WSConstantes.sanitariosAdicionar,
      data: payload,
    );
    AppLogger.success('SANITARIOS DATASOURCE: UPDATE RAW RESPONSE=$response');

    return _parseMutationResponse(
      response,
      operationName: 'UPDATE SANITARIO',
      expectedSuccessMessage: 'Sanitário atualizada com sucesso',
    );
  }

  ApiMessage _parseMutationResponse(
    dynamic response, {
    required String operationName,
    required String expectedSuccessMessage,
  }) {
    final map = responseAsMap(response);
    final hasMutationContract =
        map.containsKey('status') || map.containsKey('msg');

    if (!hasMutationContract) {
      throw ApiException(
        'Resposta inesperada da API ao executar $operationName.',
      );
    }

    final message = ApiMessage.fromResponse(response);
    if (!message.isSuccess) {
      throw ApiException(message.message);
    }

    if (message.message.trim().isEmpty) {
      return ApiMessage(
        status: message.status,
        message: expectedSuccessMessage,
      );
    }

    return message;
  }
}
