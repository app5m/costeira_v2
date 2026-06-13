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
import 'package:costeira/features/movimentacoes/abortos/domain/entities/aborto_upsert_entity.dart';
import 'package:costeira/features/movimentacoes/abortos/domain/entities/delete_aborto_entity.dart';
import 'package:costeira/features/movimentacoes/abortos/domain/repository/abortos_datasource.dart';
import 'package:costeira/features/movimentacoes/abortos/infra/models/aborto_upsert_request_model.dart';
import 'package:costeira/features/movimentacoes/abortos/infra/models/delete_aborto_request_model.dart';

class AbortosDatasourceImpl implements AbortosDatasource {
  const AbortosDatasourceImpl(
    this._offlineApiService,
    this._syncQueueService,
    this._mutationCacheService,
  );

  final OfflineApiService _offlineApiService;
  final SyncQueueService _syncQueueService;
  final OfflineMutationCacheService _mutationCacheService;

  @override
  Future<ApiMessage> createAborto(AbortoUpsertEntity aborto) async {
    if (aborto.appUsersId == null) {
      throw ApiException('Usuario nao autenticado para cadastrar aborto.');
    }

    final payload = AbortoUpsertRequestModel.create(aborto).data;
    AppLogger.info('ABORTOS DATASOURCE: CREATE PAYLOAD=$payload');

    return _offlineApiService.postOrEnqueue(
      module: 'movimentacoes',
      action: SyncOperation.create,
      endpoint: WSConstantes.movimentacoesAdicionarAborto,
      payload: payload,
      priority: SyncPriority.movimentacoes,
      pendingMessage: 'Aborto salvo localmente para sincronizar.',
      rawResponseLog: 'ABORTOS DATASOURCE: CREATE RAW RESPONSE',
      offlineCacheMutation: _abortosOfflineCacheMutation,
      parseResponse: (response) => _parseMutationResponse(
        response,
        operationName: 'CREATE ABORTO',
        expectedSuccessMessage: 'Aborto cadastrado com sucesso',
      ),
    );
  }

  @override
  Future<ApiMessage> updateAborto(AbortoUpsertEntity aborto) async {
    if (aborto.id == null) {
      throw ApiException('Informe o id do aborto para atualizar.');
    }
    if (aborto.appUsersId == null) {
      throw ApiException('Usuario nao autenticado para atualizar aborto.');
    }

    final payload = AbortoUpsertRequestModel.update(aborto).data;
    AppLogger.info('ABORTOS DATASOURCE: UPDATE PAYLOAD=$payload');

    return _offlineApiService.postOrEnqueue(
      module: 'movimentacoes',
      action: SyncOperation.update,
      endpoint: WSConstantes.movimentacoesAdicionarAborto,
      payload: payload,
      priority: SyncPriority.movimentacoes,
      pendingMessage: 'Alteração do aborto salva para sincronizar.',
      rawResponseLog: 'ABORTOS DATASOURCE: UPDATE RAW RESPONSE',
      offlineCacheMutation: _abortosOfflineCacheMutation,
      parseResponse: (response) => _parseMutationResponse(
        response,
        operationName: 'UPDATE ABORTO',
        expectedSuccessMessage: 'Aborto atualizado com sucesso',
      ),
    );
  }

  @override
  Future<ApiMessage> deleteAborto(DeleteAbortoEntity aborto) async {
    final payload = DeleteAbortoRequestModel.fromEntity(aborto).data;
    AppLogger.info('ABORTOS DATASOURCE: DELETE PAYLOAD=$payload');

    AppLogger.info(
      'ABORTOS DATASOURCE: DELETE ID=${aborto.id} IS_LOCAL=${aborto.id < 0}',
    );

    if (aborto.id < 0) {
      return MovimentacaoOfflineDatasourceSupport.cancelPendingLocal(
        syncQueueService: _syncQueueService,
        mutationCacheService: _mutationCacheService,
        createEndpoint: WSConstantes.movimentacoesAdicionarAborto,
        listField: 'data.abortos',
        moduleLabel: 'ABORTOS',
        appUsersId: aborto.appUsersId,
        itemId: aborto.id,
        payload: payload,
      );
    }

    final result = await _offlineApiService.postOrEnqueue(
      module: 'movimentacoes',
      action: SyncOperation.delete,
      endpoint: WSConstantes.movimentacoesExcluirAborto,
      payload: payload,
      priority: SyncPriority.movimentacoes,
      pendingMessage: 'Exclusão do aborto salva para sincronizar.',
      rawResponseLog: 'ABORTOS DATASOURCE: DELETE RAW RESPONSE',
      offlineCacheMutation: _abortosOfflineCacheMutation,
      parseResponse: (response) => _parseMutationResponse(
        response,
        operationName: 'DELETE ABORTO',
        expectedSuccessMessage: 'Aborto excluido com sucesso',
      ),
    );

    _logPendingDeletes(aborto.appUsersId);
    return result;
  }

  void _logPendingDeletes(int appUsersId) {
    final ids = _syncQueueService
        .getPendingItems()
        .where(
          (item) =>
              item.module == 'movimentacoes' &&
              item.action == SyncOperation.delete &&
              item.endpoint == WSConstantes.movimentacoesExcluirAborto &&
              item.payload['app_users_id']?.toString() == appUsersId.toString(),
        )
        .map((item) => item.payload['id'])
        .toList(growable: false);
    AppLogger.info(
      'ABORTOS DATASOURCE: EXCLUSOES PENDENTES NA FILA=${ids.length} IDS=$ids',
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

  static final OfflineCacheMutation _abortosOfflineCacheMutation =
      OfflineCacheMutation(
        listEndpoint: WSConstantes.movimentacoesListar,
        listPayloadBuilder:
            MovimentacaoOfflineDatasourceSupport.defaultListPayload,
        listField: 'data.abortos',
        createCacheWhenMissing: true,
        emptyResponse: MovimentacaoOfflineDatasourceSupport.emptyListResponse,
        itemBuilder: _buildCachedAbortoItem,
      );

  static Map<String, dynamic> _buildCachedAbortoItem(
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
            'tipo': 'aborto',
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
