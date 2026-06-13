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
import 'package:costeira/features/movimentacoes/troca_categoria/domain/entities/delete_troca_categoria_entity.dart';
import 'package:costeira/features/movimentacoes/troca_categoria/domain/entities/troca_categoria_upsert_entity.dart';
import 'package:costeira/features/movimentacoes/troca_categoria/domain/repository/troca_categoria_datasource.dart';
import 'package:costeira/features/movimentacoes/troca_categoria/infra/models/delete_troca_categoria_request_model.dart';
import 'package:costeira/features/movimentacoes/troca_categoria/infra/models/troca_categoria_upsert_request_model.dart';

class TrocaCategoriaDatasourceImpl implements TrocaCategoriaDatasource {
  const TrocaCategoriaDatasourceImpl(
    this._offlineApiService,
    this._syncQueueService,
    this._mutationCacheService,
  );

  final OfflineApiService _offlineApiService;
  final SyncQueueService _syncQueueService;
  final OfflineMutationCacheService _mutationCacheService;

  @override
  Future<ApiMessage> createTrocaCategoria(
    TrocaCategoriaUpsertEntity troca,
  ) async {
    if (troca.appUsersId == null) {
      throw ApiException('Usuario nao autenticado para cadastrar troca.');
    }

    final payload = TrocaCategoriaUpsertRequestModel.create(troca).data;
    AppLogger.info('TROCA CATEGORIA DATASOURCE: CREATE PAYLOAD=$payload');

    return _offlineApiService.postOrEnqueue(
      module: 'movimentacoes',
      action: SyncOperation.create,
      endpoint: WSConstantes.movimentacoesAdicionarTrocaCategoria,
      payload: payload,
      priority: SyncPriority.movimentacoes,
      pendingMessage: 'Troca de categoria salva localmente para sincronizar.',
      rawResponseLog: 'TROCA CATEGORIA DATASOURCE: CREATE RAW RESPONSE',
      offlineCacheMutation: _trocaCategoriaOfflineCacheMutation,
      parseResponse: (response) => _parseMutationResponse(
        response,
        operationName: 'CREATE TROCA CATEGORIA',
        expectedSuccessMessage: 'Troca de categoria cadastrada com sucesso',
      ),
    );
  }

  @override
  Future<ApiMessage> updateTrocaCategoria(
    TrocaCategoriaUpsertEntity troca,
  ) async {
    if (troca.id == null) {
      throw ApiException('Informe o id da troca para atualizar.');
    }
    if (troca.appUsersId == null) {
      throw ApiException('Usuario nao autenticado para atualizar troca.');
    }

    final payload = TrocaCategoriaUpsertRequestModel.update(troca).data;
    AppLogger.info('TROCA CATEGORIA DATASOURCE: UPDATE PAYLOAD=$payload');

    return _offlineApiService.postOrEnqueue(
      module: 'movimentacoes',
      action: SyncOperation.update,
      endpoint: WSConstantes.movimentacoesAdicionarTrocaCategoria,
      payload: payload,
      priority: SyncPriority.movimentacoes,
      pendingMessage: 'Alteração da troca de categoria salva para sincronizar.',
      rawResponseLog: 'TROCA CATEGORIA DATASOURCE: UPDATE RAW RESPONSE',
      offlineCacheMutation: _trocaCategoriaOfflineCacheMutation,
      parseResponse: (response) => _parseMutationResponse(
        response,
        operationName: 'UPDATE TROCA CATEGORIA',
        expectedSuccessMessage: 'Troca de categoria atualizada com sucesso',
      ),
    );
  }

  @override
  Future<ApiMessage> deleteTrocaCategoria(
    DeleteTrocaCategoriaEntity troca,
  ) async {
    final payload = DeleteTrocaCategoriaRequestModel.fromEntity(troca).data;
    AppLogger.info('TROCA CATEGORIA DATASOURCE: DELETE PAYLOAD=$payload');

    AppLogger.info(
      'TROCA CATEGORIA DATASOURCE: DELETE ID=${troca.id} IS_LOCAL=${troca.id < 0}',
    );

    if (troca.id < 0) {
      return MovimentacaoOfflineDatasourceSupport.cancelPendingLocal(
        syncQueueService: _syncQueueService,
        mutationCacheService: _mutationCacheService,
        createEndpoint: WSConstantes.movimentacoesAdicionarTrocaCategoria,
        listField: 'data.troca_categoria',
        moduleLabel: 'TROCA CATEGORIA',
        appUsersId: troca.appUsersId,
        itemId: troca.id,
        payload: payload,
      );
    }

    final result = await _offlineApiService.postOrEnqueue(
      module: 'movimentacoes',
      action: SyncOperation.delete,
      endpoint: WSConstantes.movimentacoesExcluirTrocaCategoria,
      payload: payload,
      priority: SyncPriority.movimentacoes,
      pendingMessage: 'Exclusão da troca de categoria salva para sincronizar.',
      rawResponseLog: 'TROCA CATEGORIA DATASOURCE: DELETE RAW RESPONSE',
      offlineCacheMutation: _trocaCategoriaOfflineCacheMutation,
      parseResponse: (response) => _parseMutationResponse(
        response,
        operationName: 'DELETE TROCA CATEGORIA',
        expectedSuccessMessage: 'Troca de categoria excluida com sucesso',
      ),
    );

    _logPendingDeletes(troca.appUsersId);
    return result;
  }

  void _logPendingDeletes(int appUsersId) {
    final ids = _syncQueueService
        .getPendingItems()
        .where(
          (item) =>
              item.module == 'movimentacoes' &&
              item.action == SyncOperation.delete &&
              item.endpoint ==
                  WSConstantes.movimentacoesExcluirTrocaCategoria &&
              item.payload['app_users_id']?.toString() == appUsersId.toString(),
        )
        .map((item) => item.payload['id'])
        .toList(growable: false);
    AppLogger.info(
      'TROCA CATEGORIA DATASOURCE: EXCLUSOES PENDENTES NA FILA=${ids.length} IDS=$ids',
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

  static final OfflineCacheMutation _trocaCategoriaOfflineCacheMutation =
      OfflineCacheMutation(
        listEndpoint: WSConstantes.movimentacoesListar,
        listPayloadBuilder:
            MovimentacaoOfflineDatasourceSupport.defaultListPayload,
        listField: 'data.troca_categoria',
        createCacheWhenMissing: true,
        emptyResponse: MovimentacaoOfflineDatasourceSupport.emptyListResponse,
        itemBuilder: _buildCachedTrocaCategoriaItem,
      );

  static Map<String, dynamic> _buildCachedTrocaCategoriaItem(
    Map<String, dynamic> payload,
    String idLocal,
  ) {
    final animais = (payload['animais'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((animal) {
          return <String, dynamic>{
            ...Map<String, dynamic>.from(animal),
            'app_users_id': payload['app_users_id'],
            'app_animais_lotes_id': payload['app_animais_lotes_id'],
            'app_potreiros_id': payload['app_potreiros_id'],
            'tipo': 'troca_categoria',
          }..removeWhere((key, value) => value == null);
        })
        .toList(growable: false);

    return <String, dynamic>{
      'id': MovimentacaoOfflineDatasourceSupport.localIdFromIdLocal(idLocal),
      'app_users_id': payload['app_users_id'],
      'app_movimentacoes_categorias_id': 0,
      'app_potreiros_id': payload['app_potreiros_id'],
      'app_animais_lotes_id': payload['app_animais_lotes_id'],
      'data': payload['data'],
      'qtd_animais': animais.length,
      'obs': payload['obs'],
      'animais': animais,
    }..removeWhere((key, value) => value == null);
  }
}
