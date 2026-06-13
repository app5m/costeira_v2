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
import 'package:costeira/features/movimentacoes/abigeatos/domain/entities/abigeato_upsert_entity.dart';
import 'package:costeira/features/movimentacoes/abigeatos/domain/entities/delete_abigeato_entity.dart';
import 'package:costeira/features/movimentacoes/abigeatos/domain/repository/abigeatos_datasource.dart';
import 'package:costeira/features/movimentacoes/abigeatos/infra/models/abigeato_upsert_request_model.dart';
import 'package:costeira/features/movimentacoes/abigeatos/infra/models/delete_abigeato_request_model.dart';

class AbigeatosDatasourceImpl implements AbigeatosDatasource {
  const AbigeatosDatasourceImpl(
    this._offlineApiService,
    this._syncQueueService,
    this._mutationCacheService,
  );

  final OfflineApiService _offlineApiService;
  final SyncQueueService _syncQueueService;
  final OfflineMutationCacheService _mutationCacheService;

  @override
  Future<ApiMessage> createAbigeato(AbigeatoUpsertEntity abigeato) async {
    if (abigeato.appUsersId == null) {
      throw ApiException('Usuario nao autenticado para cadastrar abigeato.');
    }

    final payload = AbigeatoUpsertRequestModel.create(abigeato).data;
    AppLogger.info('ABIGEATOS DATASOURCE: CREATE PAYLOAD=$payload');

    return _offlineApiService.postOrEnqueue(
      module: 'movimentacoes',
      action: SyncOperation.create,
      endpoint: WSConstantes.movimentacoesAdicionarAbigeato,
      payload: payload,
      priority: SyncPriority.movimentacoes,
      pendingMessage: 'Abigeato salvo localmente para sincronizar.',
      rawResponseLog: 'ABIGEATOS DATASOURCE: CREATE RAW RESPONSE',
      offlineCacheMutation: _abigeatosOfflineCacheMutation,
      parseResponse: (response) => _parseMutationResponse(
        response,
        operationName: 'CREATE ABIGEATO',
        expectedSuccessMessage: 'Abigeato cadastrado com sucesso',
      ),
    );
  }

  @override
  Future<ApiMessage> updateAbigeato(AbigeatoUpsertEntity abigeato) async {
    if (abigeato.id == null) {
      throw ApiException('Informe o id do abigeato para atualizar.');
    }
    if (abigeato.appUsersId == null) {
      throw ApiException('Usuario nao autenticado para atualizar abigeato.');
    }

    final payload = AbigeatoUpsertRequestModel.update(abigeato).data;
    AppLogger.info('ABIGEATOS DATASOURCE: UPDATE PAYLOAD=$payload');

    return _offlineApiService.postOrEnqueue(
      module: 'movimentacoes',
      action: SyncOperation.update,
      endpoint: WSConstantes.movimentacoesAdicionarAbigeato,
      payload: payload,
      priority: SyncPriority.movimentacoes,
      pendingMessage: 'Alteração do abigeato salva para sincronizar.',
      rawResponseLog: 'ABIGEATOS DATASOURCE: UPDATE RAW RESPONSE',
      offlineCacheMutation: _abigeatosOfflineCacheMutation,
      parseResponse: (response) => _parseMutationResponse(
        response,
        operationName: 'UPDATE ABIGEATO',
        expectedSuccessMessage: 'Abigeato atualizado com sucesso',
      ),
    );
  }

  @override
  Future<ApiMessage> deleteAbigeato(DeleteAbigeatoEntity abigeato) async {
    final payload = DeleteAbigeatoRequestModel.fromEntity(abigeato).data;
    AppLogger.info('ABIGEATOS DATASOURCE: DELETE PAYLOAD=$payload');

    AppLogger.info(
      'ABIGEATOS DATASOURCE: DELETE ID=${abigeato.id} IS_LOCAL=${abigeato.id < 0}',
    );

    if (abigeato.id < 0) {
      return MovimentacaoOfflineDatasourceSupport.cancelPendingLocal(
        syncQueueService: _syncQueueService,
        mutationCacheService: _mutationCacheService,
        createEndpoint: WSConstantes.movimentacoesAdicionarAbigeato,
        listField: 'data.abigeatos',
        moduleLabel: 'ABIGEATOS',
        appUsersId: abigeato.appUsersId,
        itemId: abigeato.id,
        payload: payload,
      );
    }

    final result = await _offlineApiService.postOrEnqueue(
      module: 'movimentacoes',
      action: SyncOperation.delete,
      endpoint: WSConstantes.movimentacoesExcluirAbigeato,
      payload: payload,
      priority: SyncPriority.movimentacoes,
      pendingMessage: 'Exclusão do abigeato salva para sincronizar.',
      rawResponseLog: 'ABIGEATOS DATASOURCE: DELETE RAW RESPONSE',
      offlineCacheMutation: _abigeatosOfflineCacheMutation,
      parseResponse: (response) => _parseMutationResponse(
        response,
        operationName: 'DELETE ABIGEATO',
        expectedSuccessMessage: 'Abigeato excluido com sucesso',
      ),
    );

    _logPendingDeletes(abigeato.appUsersId);
    return result;
  }

  void _logPendingDeletes(int appUsersId) {
    final ids = _syncQueueService
        .getPendingItems()
        .where(
          (item) =>
              item.module == 'movimentacoes' &&
              item.action == SyncOperation.delete &&
              item.endpoint == WSConstantes.movimentacoesExcluirAbigeato &&
              item.payload['app_users_id']?.toString() == appUsersId.toString(),
        )
        .map((item) => item.payload['id'])
        .toList(growable: false);
    AppLogger.info(
      'ABIGEATOS DATASOURCE: EXCLUSOES PENDENTES NA FILA=${ids.length} IDS=$ids',
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
      AppLogger.error(
        'ABIGEATOS DATASOURCE: $operationName RETORNOU CONTRATO INVALIDO RAW=$response',
      );
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

  static final OfflineCacheMutation _abigeatosOfflineCacheMutation =
      OfflineCacheMutation(
        listEndpoint: WSConstantes.movimentacoesListar,
        listPayloadBuilder:
            MovimentacaoOfflineDatasourceSupport.defaultListPayload,
        listField: 'data.abigeatos',
        createCacheWhenMissing: true,
        emptyResponse: MovimentacaoOfflineDatasourceSupport.emptyListResponse,
        itemBuilder: _buildCachedAbigeatoItem,
      );

  static Map<String, dynamic> _buildCachedAbigeatoItem(
    Map<String, dynamic> payload,
    String idLocal,
  ) {
    final animais = (payload['animais'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((animal) {
          return <String, dynamic>{
            ...Map<String, dynamic>.from(animal),
            'app_users_id': payload['app_users_id'],
            'tipo': 'abigeato',
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
