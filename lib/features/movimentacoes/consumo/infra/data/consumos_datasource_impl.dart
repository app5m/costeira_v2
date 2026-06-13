import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/api/api_response_utils.dart';
import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/core/offline/cache/offline_mutation_cache_service.dart';
import 'package:costeira/core/offline/offline_api_service.dart';
import 'package:costeira/core/offline/sync/sync_operation.dart';
import 'package:costeira/core/offline/sync/sync_priority.dart';
import 'package:costeira/core/offline/sync/sync_queue_service.dart';
import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/features/movimentacoes/infra/data/movimentacao_offline_datasource_support.dart';
import 'package:costeira/features/movimentacoes/consumo/domain/entities/consumo_upsert_entity.dart';
import 'package:costeira/features/movimentacoes/consumo/domain/entities/delete_consumo_entity.dart';
import 'package:costeira/features/movimentacoes/consumo/domain/repository/consumos_datasource.dart';
import 'package:costeira/features/movimentacoes/consumo/infra/models/consumo_upsert_request_model.dart';
import 'package:costeira/features/movimentacoes/consumo/infra/models/delete_consumo_request_model.dart';

class ConsumosDatasourceImpl implements ConsumosDatasource {
  const ConsumosDatasourceImpl(
    this._offlineApiService,
    this._syncQueueService,
    this._mutationCacheService,
  );

  final OfflineApiService _offlineApiService;
  final SyncQueueService _syncQueueService;
  final OfflineMutationCacheService _mutationCacheService;

  @override
  Future<ApiMessage> createConsumo(ConsumoUpsertEntity consumo) async {
    if (consumo.appUsersId == null) {
      throw ApiException('Usuario nao autenticado para cadastrar consumo.');
    }

    final payload = ConsumoUpsertRequestModel.create(consumo).data;
    AppLogger.info('CONSUMOS DATASOURCE: CREATE PAYLOAD=$payload');

    return _offlineApiService.postOrEnqueue(
      module: 'movimentacoes',
      action: SyncOperation.create,
      endpoint: WSConstantes.movimentacoesAdicionarConsumo,
      payload: payload,
      priority: SyncPriority.movimentacoes,
      pendingMessage: 'Consumo salvo localmente para sincronizar.',
      rawResponseLog: 'CONSUMOS DATASOURCE: CREATE RAW RESPONSE',
      offlineCacheMutation: _consumosOfflineCacheMutation,
      parseResponse: (response) => _parseMutationResponse(
        response,
        operationName: 'CREATE CONSUMO',
        expectedSuccessMessage: 'Consumo cadastrado com sucesso',
      ),
    );
  }

  @override
  Future<ApiMessage> updateConsumo(ConsumoUpsertEntity consumo) async {
    if (consumo.id == null) {
      throw ApiException('Informe o id do consumo para atualizar.');
    }
    if (consumo.appUsersId == null) {
      throw ApiException('Usuario nao autenticado para atualizar consumo.');
    }

    final payload = ConsumoUpsertRequestModel.update(consumo).data;
    AppLogger.info('CONSUMOS DATASOURCE: UPDATE PAYLOAD=$payload');

    return _offlineApiService.postOrEnqueue(
      module: 'movimentacoes',
      action: SyncOperation.update,
      endpoint: WSConstantes.movimentacoesAdicionarConsumo,
      payload: payload,
      priority: SyncPriority.movimentacoes,
      pendingMessage: 'Alteração do consumo salva para sincronizar.',
      rawResponseLog: 'CONSUMOS DATASOURCE: UPDATE RAW RESPONSE',
      offlineCacheMutation: _consumosOfflineCacheMutation,
      parseResponse: (response) => _parseMutationResponse(
        response,
        operationName: 'UPDATE CONSUMO',
        expectedSuccessMessage: 'Consumo atualizado com sucesso',
      ),
    );
  }

  @override
  Future<ApiMessage> deleteConsumo(DeleteConsumoEntity consumo) async {
    final payload = DeleteConsumoRequestModel.fromEntity(consumo).data;
    AppLogger.info('CONSUMOS DATASOURCE: DELETE PAYLOAD=$payload');

    AppLogger.info(
      'CONSUMOS DATASOURCE: DELETE ID=${consumo.id} IS_LOCAL=${consumo.id < 0}',
    );

    if (consumo.id < 0) {
      return MovimentacaoOfflineDatasourceSupport.cancelPendingLocal(
        syncQueueService: _syncQueueService,
        mutationCacheService: _mutationCacheService,
        createEndpoint: WSConstantes.movimentacoesAdicionarConsumo,
        listField: 'data.consumos',
        moduleLabel: 'CONSUMOS',
        appUsersId: consumo.appUsersId,
        itemId: consumo.id,
        payload: payload,
      );
    }

    final result = await _offlineApiService.postOrEnqueue(
      module: 'movimentacoes',
      action: SyncOperation.delete,
      endpoint: WSConstantes.movimentacoesExcluirConsumo,
      payload: payload,
      priority: SyncPriority.movimentacoes,
      pendingMessage: 'Exclusão do consumo salva para sincronizar.',
      rawResponseLog: 'CONSUMOS DATASOURCE: DELETE RAW RESPONSE',
      offlineCacheMutation: _consumosOfflineCacheMutation,
      parseResponse: (response) => _parseMutationResponse(
        response,
        operationName: 'DELETE CONSUMO',
        expectedSuccessMessage: 'Consumo excluido com sucesso',
      ),
    );

    _logPendingDeletes(consumo.appUsersId);
    return result;
  }

  void _logPendingDeletes(int appUsersId) {
    final ids = _syncQueueService
        .getPendingItems()
        .where(
          (item) =>
              item.module == 'movimentacoes' &&
              item.action == SyncOperation.delete &&
              item.endpoint == WSConstantes.movimentacoesExcluirConsumo &&
              item.payload['app_users_id']?.toString() == appUsersId.toString(),
        )
        .map((item) => item.payload['id'])
        .toList(growable: false);
    AppLogger.info(
      'CONSUMOS DATASOURCE: EXCLUSOES PENDENTES NA FILA=${ids.length} IDS=$ids',
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

  static final OfflineCacheMutation _consumosOfflineCacheMutation =
      OfflineCacheMutation(
        listEndpoint: WSConstantes.movimentacoesListar,
        listPayloadBuilder:
            MovimentacaoOfflineDatasourceSupport.defaultListPayload,
        listField: 'data.consumos',
        createCacheWhenMissing: true,
        emptyResponse: MovimentacaoOfflineDatasourceSupport.emptyListResponse,
        itemBuilder: _buildCachedConsumoItem,
      );

  static Map<String, dynamic> _buildCachedConsumoItem(
    Map<String, dynamic> payload,
    String idLocal,
  ) {
    final animais = (payload['animais'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((animal) {
          return <String, dynamic>{
            ...Map<String, dynamic>.from(animal),
            'app_users_id': payload['app_users_id'],
            'tipo': 'consumo',
          }..removeWhere((key, value) => value == null);
        })
        .toList(growable: false);

    return <String, dynamic>{
      'id': MovimentacaoOfflineDatasourceSupport.localIdFromIdLocal(idLocal),
      'app_users_id': payload['app_users_id'],
      'app_movimentacoes_categorias_id': 0,
      'data': payload['data'],
      'qtd_animais': animais.length,
      'obs': payload['obs'],
      'animais': animais,
    }..removeWhere((key, value) => value == null);
  }
}
