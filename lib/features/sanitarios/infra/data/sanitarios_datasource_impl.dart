import 'package:costeira/core/api/api_client.dart';
import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/api/api_response_utils.dart';
import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/core/offline/offline_api_service.dart';
import 'package:costeira/core/offline/sync/sync_operation.dart';
import 'package:costeira/core/offline/sync/sync_priority.dart';
import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/features/sanitarios/domain/entities/sanitario.dart';
import 'package:costeira/features/sanitarios/domain/repository/sanitarios_datasource.dart';
import 'package:costeira/features/sanitarios/infra/models/sanitario_models.dart';

class SanitariosDatasourceImpl implements SanitariosDatasource {
  const SanitariosDatasourceImpl(this._apiClient, this._offlineApiService);

  final ApiClient _apiClient;
  final OfflineApiService _offlineApiService;

  @override
  Future<SanitariosListEntity> getSanitarios(SanitariosFilterEntity filter) async {
    final payload = SanitariosFilterRequestModel.fromEntity(filter).data;
    AppLogger.info('SANITARIOS DATASOURCE: LIST PAYLOAD=$payload');

    return _offlineApiService.postCached<SanitariosListEntity>(
      endpoint: WSConstantes.sanitariosListar,
      payload: payload,
      userId: filter.appUsersId,
      parser: _parseSanitariosList,
      missingCacheMessage: 'Sem conexão e sem dados salvos para sanitarios.',
      rawResponseLog: 'SANITARIOS DATASOURCE: LIST RAW RESPONSE',
    );
  }

  @override
  Future<ApiMessage> createSanitario(SanitarioUpsertEntity sanitario) async {
    if (sanitario.appUsersId == null) {
      throw ApiException('Usuario nao autenticado para cadastrar sanitario.');
    }

    final payload = SanitarioUpsertRequestModel.create(sanitario).data;
    AppLogger.info('SANITARIOS DATASOURCE: CREATE PAYLOAD=$payload');

    return _offlineApiService.postOrEnqueue(
      module: 'sanitarios',
      action: SyncOperation.create,
      endpoint: WSConstantes.sanitariosAdicionar,
      payload: payload,
      priority: SyncPriority.sanitarios,
      pendingMessage: 'Sanitario salvo localmente para sincronizar.',
      rawResponseLog: 'SANITARIOS DATASOURCE: CREATE RAW RESPONSE',
      parseResponse: (response) => _parseMutationResponse(
        response,
        operationName: 'CREATE SANITARIO',
        expectedSuccessMessage: 'Sanitario cadastrado com sucesso',
      ),
    );
  }

  @override
  Future<ApiMessage> updateSanitario(SanitarioUpsertEntity sanitario) async {
    if (sanitario.id == null) {
      throw ApiException('Informe o id do sanitario para atualizar.');
    }
    if (sanitario.appUsersId == null) {
      throw ApiException('Usuario nao autenticado para atualizar sanitario.');
    }

    final payload = SanitarioUpsertRequestModel.update(sanitario).data;
    AppLogger.info('SANITARIOS DATASOURCE: UPDATE PAYLOAD=$payload');

    return _offlineApiService.postOrEnqueue(
      module: 'sanitarios',
      action: SyncOperation.update,
      endpoint: WSConstantes.sanitariosAdicionar,
      payload: payload,
      priority: SyncPriority.sanitarios,
      pendingMessage: 'Alteracao do sanitario salva para sincronizar.',
      rawResponseLog: 'SANITARIOS DATASOURCE: UPDATE RAW RESPONSE',
      parseResponse: (response) => _parseMutationResponse(
        response,
        operationName: 'UPDATE SANITARIO',
        expectedSuccessMessage: 'Sanitario atualizado com sucesso',
      ),
    );
  }

  @override
  Future<ApiMessage> deleteSanitario(DeleteSanitarioEntity sanitario) async {
    final payload = DeleteSanitarioRequestModel.fromEntity(sanitario).data;
    AppLogger.info('SANITARIOS DATASOURCE: DELETE PAYLOAD=$payload');

    return _offlineApiService.postOrEnqueue(
      module: 'sanitarios',
      action: SyncOperation.delete,
      endpoint: WSConstantes.sanitariosExcluir,
      payload: payload,
      priority: SyncPriority.sanitarios,
      pendingMessage: 'Exclusao do sanitario salva para sincronizar.',
      rawResponseLog: 'SANITARIOS DATASOURCE: DELETE RAW RESPONSE',
      parseResponse: (response) => _parseMutationResponse(
        response,
        operationName: 'DELETE SANITARIO',
        expectedSuccessMessage: 'Sanitario excluido com sucesso',
      ),
    );
  }

  @override
  Future<ApiMessage> executarSanitario(SanitarioExecucaoEntity execucao) async {
    if (execucao.appUsersId == null) {
      throw ApiException('Usuario nao autenticado para executar sanitario.');
    }
    if (execucao.insumos.isEmpty) {
      throw ApiException('Informe ao menos um insumo utilizado.');
    }

    final payload = SanitarioExecucaoRequestModel.fromEntity(execucao).data;
    AppLogger.info('SANITARIOS DATASOURCE: EXECUTAR PAYLOAD=$payload');

    return _offlineApiService.postOrEnqueue(
      module: 'sanitarios',
      action: SyncOperation.update,
      endpoint: WSConstantes.sanitariosSetExecutar,
      payload: payload,
      priority: SyncPriority.sanitarios,
      pendingMessage: 'Execucao do sanitario salva para sincronizar.',
      rawResponseLog: 'SANITARIOS DATASOURCE: EXECUTAR RAW RESPONSE',
      parseResponse: (response) => _parseMutationResponse(
        response,
        operationName: 'EXECUTAR SANITARIO',
        expectedSuccessMessage: 'Sanitario executado com sucesso',
      ),
    );
  }

  @override
  Future<SanitarioChartsEntity> getSanitarioCharts(SanitarioChartsFilterEntity filter) async {
    final payload = SanitarioChartsFilterRequestModel.fromEntity(filter).data;
    AppLogger.info('SANITARIOS DATASOURCE: CHARTS PAYLOAD=$payload');

    final response = await _apiClient.post(WSConstantes.sanitariosGraficos, data: payload);
    AppLogger.success('SANITARIOS DATASOURCE: CHARTS RAW RESPONSE=$response');

    final wrappers = responseAsList(response);
    if (wrappers.isEmpty) {
      return SanitarioChartsEntity.empty;
    }

    return SanitarioChartsResponseModel.fromWrapper(wrappers.first);
  }

  SanitariosListEntity _parseSanitariosList(dynamic response) {
    final wrappers = responseAsList(response);
    if (wrappers.isEmpty) {
      return const SanitariosListEntity(rows: 0, lista: []);
    }

    return SanitariosListResponseModel.fromWrapper(wrappers.first);
  }

  ApiMessage _parseMutationResponse(
    dynamic response, {
    required String operationName,
    required String expectedSuccessMessage,
  }) {
    final map = responseAsMap(response);
    final hasMutationContract = map.containsKey('status') || map.containsKey('msg');

    if (!hasMutationContract) {
      throw ApiException('Resposta inesperada da API ao executar $operationName.');
    }

    final message = ApiMessage.fromResponse(response);
    if (!message.isSuccess) {
      throw ApiException(message.message);
    }

    if (message.message.trim().isEmpty) {
      return ApiMessage(status: message.status, message: expectedSuccessMessage);
    }

    return message;
  }
}
