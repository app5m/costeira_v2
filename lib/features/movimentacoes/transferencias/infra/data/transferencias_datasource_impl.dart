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
import 'package:costeira/features/movimentacoes/transferencias/domain/entities/delete_transferencia_entity.dart';
import 'package:costeira/features/movimentacoes/transferencias/domain/entities/transferencia_upsert_entity.dart';
import 'package:costeira/features/movimentacoes/transferencias/domain/repository/transferencias_datasource.dart';
import 'package:costeira/features/movimentacoes/transferencias/infra/models/delete_transferencia_request_model.dart';
import 'package:costeira/features/movimentacoes/transferencias/infra/models/transferencia_upsert_request_model.dart';

class TransferenciasDatasourceImpl implements TransferenciasDatasource {
  const TransferenciasDatasourceImpl(
    this._offlineApiService,
    this._syncQueueService,
    this._mutationCacheService,
  );

  final OfflineApiService _offlineApiService;
  final SyncQueueService _syncQueueService;
  final OfflineMutationCacheService _mutationCacheService;

  @override
  Future<ApiMessage> createTransferencia(
    TransferenciaUpsertEntity transferencia,
  ) async {
    if (transferencia.appUsersId == null) {
      throw ApiException(
        'Usuario nao autenticado para cadastrar transferencia.',
      );
    }

    final payload = TransferenciaUpsertRequestModel.create(transferencia).data;
    AppLogger.info('TRANSFERENCIAS DATASOURCE: CREATE PAYLOAD=$payload');

    return _offlineApiService.postOrEnqueue(
      module: 'movimentacoes',
      action: SyncOperation.create,
      endpoint: WSConstantes.movimentacoesAdicionarTransferencia,
      payload: payload,
      priority: SyncPriority.movimentacoes,
      pendingMessage: 'Transferencia salva localmente para sincronizar.',
      rawResponseLog: 'TRANSFERENCIAS DATASOURCE: CREATE RAW RESPONSE',
      offlineCacheMutation: _transferenciasOfflineCacheMutation,
      parseResponse: (response) => _parseMutationResponse(
        response,
        operationName: 'CREATE TRANSFERENCIA',
        expectedSuccessMessage: 'Transferencia cadastrada com sucesso',
      ),
    );
  }

  @override
  Future<ApiMessage> updateTransferencia(
    TransferenciaUpsertEntity transferencia,
  ) async {
    if (transferencia.id == null) {
      throw ApiException('Informe o id da transferencia para atualizar.');
    }
    if (transferencia.appUsersId == null) {
      throw ApiException(
        'Usuario nao autenticado para atualizar transferencia.',
      );
    }

    final payload = TransferenciaUpsertRequestModel.update(transferencia).data;
    AppLogger.info('TRANSFERENCIAS DATASOURCE: UPDATE PAYLOAD=$payload');

    return _offlineApiService.postOrEnqueue(
      module: 'movimentacoes',
      action: SyncOperation.update,
      endpoint: WSConstantes.movimentacoesAdicionarTransferencia,
      payload: payload,
      priority: SyncPriority.movimentacoes,
      pendingMessage: 'Alteração da transferencia salva para sincronizar.',
      rawResponseLog: 'TRANSFERENCIAS DATASOURCE: UPDATE RAW RESPONSE',
      offlineCacheMutation: _transferenciasOfflineCacheMutation,
      parseResponse: (response) => _parseMutationResponse(
        response,
        operationName: 'UPDATE TRANSFERENCIA',
        expectedSuccessMessage: 'Transferencia atualizada com sucesso',
      ),
    );
  }

  @override
  Future<ApiMessage> deleteTransferencia(
    DeleteTransferenciaEntity transferencia,
  ) async {
    final payload = DeleteTransferenciaRequestModel.fromEntity(
      transferencia,
    ).data;
    AppLogger.info('TRANSFERENCIAS DATASOURCE: DELETE PAYLOAD=$payload');

    AppLogger.info(
      'TRANSFERENCIAS DATASOURCE: DELETE ID=${transferencia.id} IS_LOCAL=${transferencia.id < 0}',
    );

    if (transferencia.id < 0) {
      return MovimentacaoOfflineDatasourceSupport.cancelPendingLocal(
        syncQueueService: _syncQueueService,
        mutationCacheService: _mutationCacheService,
        createEndpoint: WSConstantes.movimentacoesAdicionarTransferencia,
        listField: 'data.transferencias',
        moduleLabel: 'TRANSFERENCIAS',
        appUsersId: transferencia.appUsersId,
        itemId: transferencia.id,
        payload: payload,
      );
    }

    final result = await _offlineApiService.postOrEnqueue(
      module: 'movimentacoes',
      action: SyncOperation.delete,
      endpoint: WSConstantes.movimentacoesExcluirTransferencia,
      payload: payload,
      priority: SyncPriority.movimentacoes,
      pendingMessage: 'Exclusão da transferencia salva para sincronizar.',
      rawResponseLog: 'TRANSFERENCIAS DATASOURCE: DELETE RAW RESPONSE',
      offlineCacheMutation: _transferenciasOfflineCacheMutation,
      parseResponse: (response) => _parseMutationResponse(
        response,
        operationName: 'DELETE TRANSFERENCIA',
        expectedSuccessMessage: 'Transferencia excluida com sucesso',
      ),
    );

    _logPendingDeletes(transferencia.appUsersId);
    return result;
  }

  void _logPendingDeletes(int appUsersId) {
    final ids = _syncQueueService
        .getPendingItems()
        .where(
          (item) =>
              item.module == 'movimentacoes' &&
              item.action == SyncOperation.delete &&
              item.endpoint == WSConstantes.movimentacoesExcluirTransferencia &&
              item.payload['app_users_id']?.toString() == appUsersId.toString(),
        )
        .map((item) => item.payload['id'])
        .toList(growable: false);
    AppLogger.info(
      'TRANSFERENCIAS DATASOURCE: EXCLUSOES PENDENTES NA FILA=${ids.length} IDS=$ids',
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
        'TRANSFERENCIAS DATASOURCE: $operationName RETORNOU CONTRATO INVALIDO RAW=$response',
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

  static final OfflineCacheMutation _transferenciasOfflineCacheMutation =
      OfflineCacheMutation(
        listEndpoint: WSConstantes.movimentacoesListar,
        listPayloadBuilder:
            MovimentacaoOfflineDatasourceSupport.defaultListPayload,
        listField: 'data.transferencias',
        createCacheWhenMissing: true,
        emptyResponse: MovimentacaoOfflineDatasourceSupport.emptyListResponse,
        itemBuilder: _buildCachedTransferenciaItem,
      );

  static Map<String, dynamic> _buildCachedTransferenciaItem(
    Map<String, dynamic> payload,
    String idLocal,
  ) {
    final itens = payload['tipo'] == 'animais'
        ? (payload['animais'] as List<dynamic>? ?? const [])
        : (payload['lotes'] as List<dynamic>? ?? const []);

    return <String, dynamic>{
      'id': MovimentacaoOfflineDatasourceSupport.localIdFromIdLocal(idLocal),
      'app_users_id': payload['app_users_id'],
      'app_movimentacoes_categorias_id': 0,
      'data': payload['data'],
      'qtd_animais': itens.length,
      'obs': payload['obs'],
      'potreiro_destino': {'id': payload['potreiro_destino']},
      if (payload['lote_destino'] != null)
        'lote_destino': {'id': payload['lote_destino']},
    }..removeWhere((key, value) => value == null);
  }
}
