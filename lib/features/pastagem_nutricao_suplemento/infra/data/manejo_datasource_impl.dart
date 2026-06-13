import 'package:costeira/core/api/api_client.dart';
import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/api/api_response_utils.dart';
import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/core/offline/offline_api_service.dart';
import 'package:costeira/core/offline/sync/sync_operation.dart';
import 'package:costeira/core/offline/sync/sync_priority.dart';
import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/entities/manejo.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/entities/manejo_filter.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/entities/manejos_list.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/repository/manejo_datasource.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/infra/models/delete_manejo_request_model.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/infra/models/manejo_charts_filter_request_model.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/infra/models/manejo_charts_response_model.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/infra/models/manejo_filter_request_model.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/infra/models/manejo_upsert_request_model.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/infra/models/manejos_list_response_model.dart';

class ManejoDataSourceImpl implements ManejoDataSource {
  const ManejoDataSourceImpl(this._apiClient, this._offlineApiService);

  final ApiClient _apiClient;
  final OfflineApiService _offlineApiService;

  @override
  Future<ManejosListEntity> getManejos(ManejoFilterEntity filter) async {
    final payload = ManejoFilterRequestModel.fromEntity(filter).data;
    AppLogger.info('MANEJO DATASOURCE: LIST PAYLOAD=$payload');

    return _offlineApiService.postCached<ManejosListEntity>(
      endpoint: WSConstantes.pastagensListar,
      payload: payload,
      userId: filter.appUsersId,
      parser: (response) => ManejosListResponseModel.fromJson(responseAsMap(response)),
      missingCacheMessage: 'Sem conexão e sem dados salvos para pastagens.',
      rawResponseLog: 'MANEJO DATASOURCE: LIST RAW RESPONSE',
    );
  }

  @override
  Future<ApiMessage> createManejo(ManejoUpsertEntity manejo) async {
    if (manejo.appUsersId == null) {
      throw ApiException('Usuario nao autenticado para cadastrar manejo.');
    }

    final payload = ManejoUpsertRequestModel.fromEntity(manejo).data;
    AppLogger.info('MANEJO DATASOURCE: CREATE PAYLOAD=$payload');

    return _mutation(
      action: SyncOperation.create,
      endpoint: WSConstantes.pastagensAdicionar,
      payload: payload,
      pendingMessage: 'Pastagem salva localmente para sincronizar.',
      rawResponseLog: 'MANEJO DATASOURCE: CREATE RESPONSE',
      operationName: 'CREATE MANEJO',
      expectedSuccessMessage: 'Pastagem cadastrada com sucesso',
    );
  }

  @override
  Future<ApiMessage> updateManejo(ManejoUpsertEntity manejo) async {
    if (manejo.id == null) {
      throw ApiException('Informe o id do manejo para atualizar.');
    }
    if (manejo.appUsersId == null) {
      throw ApiException('Usuario nao autenticado para atualizar manejo.');
    }

    final payload = ManejoUpsertRequestModel.fromEntity(manejo).data;
    AppLogger.info('MANEJO DATASOURCE: UPDATE PAYLOAD=$payload');

    return _mutation(
      action: SyncOperation.update,
      endpoint: WSConstantes.pastagensAdicionar,
      payload: payload,
      pendingMessage: 'Alteração da pastagem salva para sincronizar.',
      rawResponseLog: 'MANEJO DATASOURCE: UPDATE RESPONSE',
      operationName: 'UPDATE MANEJO',
      expectedSuccessMessage: 'Pastagem atualizada com sucesso',
    );
  }

  @override
  Future<ApiMessage> deleteManejo(DeleteManejoEntity manejo) async {
    final payload = DeleteManejoRequestModel.fromEntity(manejo).data;
    AppLogger.info('MANEJO DATASOURCE: DELETE PAYLOAD=$payload');

    return _mutation(
      action: SyncOperation.delete,
      endpoint: WSConstantes.pastagensExcluir,
      payload: payload,
      pendingMessage: 'Exclusão da pastagem salva para sincronizar.',
      rawResponseLog: 'MANEJO DATASOURCE: DELETE RESPONSE',
      operationName: 'DELETE MANEJO',
      expectedSuccessMessage: 'Pastagem excluida com sucesso',
    );
  }

  @override
  Future<ManejoChartsEntity> getCharts(ManejoChartsFilterEntity filter) async {
    final payload = ManejoChartsFilterRequestModel.fromEntity(filter).data;
    AppLogger.info('MANEJO CHARTS: PAYLOAD=$payload');

    final response = await _apiClient.post(WSConstantes.pastagensGraficos, data: payload);
    AppLogger.success('MANEJO CHARTS: RESPONSE=$response');

    final wrapper = responseAsMap(response);
    final dataList = wrapper['data'] as List<dynamic>? ?? const [];
    final first = dataList.whereType<Map>().cast<Map>().firstOrNull;

    if (first == null) {
      return ManejoChartsEntity.empty;
    }

    return ManejoChartsResponseModel.fromJson(Map<String, dynamic>.from(first));
  }

  Future<ApiMessage> _mutation({
    required String action,
    required String endpoint,
    required Map<String, dynamic> payload,
    required String pendingMessage,
    required String rawResponseLog,
    required String operationName,
    required String expectedSuccessMessage,
  }) {
    return _offlineApiService.postOrEnqueue(
      module: 'pastagem_nutricao_suplemento',
      action: action,
      endpoint: endpoint,
      payload: payload,
      priority: SyncPriority.pastagemNutricaoSuplemento,
      pendingMessage: pendingMessage,
      rawResponseLog: rawResponseLog,
      offlineCacheMutation: OfflineCacheMutation(
        listEndpoint: WSConstantes.pastagensListar,
        listPayloadBuilder: _defaultManejoListPayload,
        listField: 'data.lista',
        createCacheWhenMissing: true,
        emptyResponse: _emptyManejoListResponse,
        allowLatestCacheFallback: false,
      ),
      parseResponse: (response) => _parseMutationResponse(
        response,
        operationName: operationName,
        expectedSuccessMessage: expectedSuccessMessage,
      ),
    );
  }

  ApiMessage _parseMutationResponse(
    dynamic response, {
    required String operationName,
    required String expectedSuccessMessage,
  }) {
    final map = responseAsMap(response);
    final hasMutationContract = map.containsKey('status') || map.containsKey('msg');

    if (!hasMutationContract) {
      throw ApiException(
        'Resposta inesperada da API ao executar $operationName. '
        'Esperado status/msg, recebido: $response',
      );
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

Map<String, dynamic> _defaultManejoListPayload(Map<String, dynamic> payload) {
  final userId = int.tryParse(payload['app_users_id']?.toString() ?? '');
  if (userId == null) {
    return <String, dynamic>{};
  }

  return ManejoFilterRequestModel.fromEntity(ManejoFilterEntity(appUsersId: userId)).data;
}

const Map<String, dynamic> _emptyManejoListResponse = {
  'rows': 0,
  'data': [
    {'lista': <Map<String, dynamic>>[], 'tipos_manejo': <Map<String, dynamic>>[]},
  ],
};
