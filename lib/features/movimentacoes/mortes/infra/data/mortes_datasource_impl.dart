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
import 'package:costeira/features/movimentacoes/domain/entities/movimentacao_filter_entity.dart';
import 'package:costeira/features/movimentacoes/infra/models/movimentacao_filter_request_model.dart';
import 'package:costeira/features/movimentacoes/mortes/domain/entities/delete_morte_entity.dart';
import 'package:costeira/features/movimentacoes/mortes/domain/entities/morte_upsert_entity.dart';
import 'package:costeira/features/movimentacoes/mortes/domain/repository/mortes_datasource.dart';
import 'package:costeira/features/movimentacoes/mortes/infra/models/delete_morte_request_model.dart';
import 'package:costeira/features/movimentacoes/mortes/infra/models/morte_upsert_request_model.dart';

class MortesDatasourceImpl implements MortesDatasource {
  const MortesDatasourceImpl(
    this._offlineApiService,
    this._syncQueueService,
    this._mutationCacheService,
  );

  final OfflineApiService _offlineApiService;
  final SyncQueueService _syncQueueService;
  final OfflineMutationCacheService _mutationCacheService;

  @override
  Future<ApiMessage> createMorte(MorteUpsertEntity morte) async {
    if (morte.appUsersId == null) {
      throw ApiException('Usuario nao autenticado para cadastrar morte.');
    }

    final payload = MorteUpsertRequestModel.create(morte).data;
    AppLogger.info('MORTES DATASOURCE: CREATE PAYLOAD=$payload');

    return _offlineApiService.postOrEnqueue(
      module: 'movimentacoes',
      action: SyncOperation.create,
      endpoint: WSConstantes.movimentacoesAdicionarMorte,
      payload: payload,
      priority: SyncPriority.movimentacoes,
      pendingMessage: 'Morte salva localmente para sincronizar.',
      rawResponseLog: 'MORTES DATASOURCE: CREATE RAW RESPONSE',
      offlineCacheMutation: _mortesOfflineCacheMutation,
      parseResponse: (response) => _parseMutationResponse(
        response,
        operationName: 'CREATE MORTE',
        expectedSuccessMessage: 'Morte cadastrada com sucesso',
      ),
    );
  }

  @override
  Future<ApiMessage> updateMorte(MorteUpsertEntity morte) async {
    if (morte.id == null) {
      throw ApiException('Informe o id da morte para atualizar.');
    }
    if (morte.appUsersId == null) {
      throw ApiException('Usuario nao autenticado para atualizar morte.');
    }

    final payload = MorteUpsertRequestModel.update(morte).data;
    AppLogger.info('MORTES DATASOURCE: UPDATE PAYLOAD=$payload');

    return _offlineApiService.postOrEnqueue(
      module: 'movimentacoes',
      action: SyncOperation.update,
      endpoint: WSConstantes.movimentacoesAdicionarMorte,
      payload: payload,
      priority: SyncPriority.movimentacoes,
      pendingMessage: 'Alteracao da morte salva para sincronizar.',
      rawResponseLog: 'MORTES DATASOURCE: UPDATE RAW RESPONSE',
      offlineCacheMutation: _mortesOfflineCacheMutation,
      parseResponse: (response) => _parseMutationResponse(
        response,
        operationName: 'UPDATE MORTE',
        expectedSuccessMessage: 'Morte atualizada com sucesso',
      ),
    );
  }

  @override
  Future<ApiMessage> deleteMorte(DeleteMorteEntity morte) async {
    final payload = DeleteMorteRequestModel.fromEntity(morte).data;
    AppLogger.info(
      'MORTES DATASOURCE: DELETE ID=${morte.id} IS_LOCAL=${morte.id < 0} PAYLOAD=$payload',
    );

    if (morte.id < 0) {
      return _cancelPendingLocalMorte(morte, payload);
    }

    final result = await _offlineApiService.postOrEnqueue(
      module: 'movimentacoes',
      action: SyncOperation.delete,
      endpoint: WSConstantes.movimentacoesExcluirMorte,
      payload: payload,
      priority: SyncPriority.movimentacoes,
      pendingMessage: 'Exclusao da morte salva para sincronizar.',
      rawResponseLog: 'MORTES DATASOURCE: DELETE RAW RESPONSE',
      offlineCacheMutation: _mortesOfflineCacheMutation,
      parseResponse: (response) => _parseMutationResponse(
        response,
        operationName: 'DELETE MORTE',
        expectedSuccessMessage: 'Morte excluida com sucesso',
      ),
    );

    final pendingDeleteItems = _syncQueueService
        .getPendingItems()
        .where(
          (item) =>
              item.module == 'movimentacoes' &&
              item.action == SyncOperation.delete &&
              item.endpoint == WSConstantes.movimentacoesExcluirMorte &&
              item.payload['app_users_id']?.toString() ==
                  morte.appUsersId.toString(),
        )
        .toList(growable: false);
    AppLogger.info(
      'MORTES DATASOURCE: EXCLUSOES DE MORTE PENDENTES NA FILA=${pendingDeleteItems.length} IDS=${pendingDeleteItems.map((item) => item.payload['id']).join(',')}',
    );

    return result;
  }

  Future<ApiMessage> _cancelPendingLocalMorte(
    DeleteMorteEntity morte,
    Map<String, dynamic> payload,
  ) async {
    final pendingCreate = _syncQueueService
        .getPendingItems()
        .where(
          (item) =>
              item.module == 'movimentacoes' &&
              item.action == SyncOperation.create &&
              item.endpoint == WSConstantes.movimentacoesAdicionarMorte &&
              item.payload['app_users_id']?.toString() ==
                  morte.appUsersId.toString() &&
              _localIdFromIdLocal(item.idLocal) == morte.id,
        )
        .firstOrNull;

    await _mutationCacheService.applyMutation(
      action: SyncOperation.delete,
      listEndpoint: WSConstantes.movimentacoesListar,
      listPayload: _defaultListPayload(payload),
      userId: morte.appUsersId,
      itemId: morte.id,
      idLocal: pendingCreate?.idLocal,
      listField: 'data.mortes',
      allowLatestCacheFallback: true,
    );

    if (pendingCreate != null) {
      await _syncQueueService.removeItem(pendingCreate.idLocal);
      AppLogger.success(
        'MORTES DATASOURCE: MORTE LOCAL PENDENTE CANCELADA ID_LOCAL=${pendingCreate.idLocal}',
      );
    } else {
      AppLogger.warning(
        'MORTES DATASOURCE: MORTE LOCAL SEM FILA REMOVIDA DO CACHE ID=${morte.id}',
      );
    }

    return const ApiMessage(status: '01', message: 'Morte local removida.');
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
        'MORTES DATASOURCE: $operationName RETORNOU CONTRATO INVALIDO RAW=$response',
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

  static final OfflineCacheMutation _mortesOfflineCacheMutation =
      OfflineCacheMutation(
        listEndpoint: WSConstantes.movimentacoesListar,
        listPayloadBuilder: _defaultListPayload,
        listField: 'data.mortes',
        createCacheWhenMissing: true,
        emptyResponse: _emptyListResponse,
        itemBuilder: _buildCachedMorteItem,
      );

  static Map<String, dynamic> _defaultListPayload(
    Map<String, dynamic> payload,
  ) {
    final userId = int.tryParse(payload['app_users_id']?.toString() ?? '');
    if (userId == null) {
      return <String, dynamic>{};
    }

    return MovimentacaoFilterRequestModel.fromEntity(
      MovimentacaoFilterEntity(
        appUsersId: userId,
        appFazendasId: int.tryParse(
          payload['app_fazendas_id']?.toString() ?? '',
        ),
      ),
    ).data;
  }

  static const Map<String, dynamic> _emptyListResponse = {
    'rows': 0,
    'data': {
      'compras': <Map<String, dynamic>>[],
      'vendas': <Map<String, dynamic>>[],
      'mortes': <Map<String, dynamic>>[],
      'nascimentos': <Map<String, dynamic>>[],
      'troca_categoria': <Map<String, dynamic>>[],
      'transferencias': <Map<String, dynamic>>[],
      'abigeatos': <Map<String, dynamic>>[],
      'abortos': <Map<String, dynamic>>[],
      'consumos': <Map<String, dynamic>>[],
    },
  };

  static Map<String, dynamic> _buildCachedMorteItem(
    Map<String, dynamic> payload,
    String idLocal,
  ) {
    final animais = (payload['animais'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((animal) {
          return <String, dynamic>{
            ...Map<String, dynamic>.from(animal),
            'app_users_id': payload['app_users_id'],
            'app_potreiros_id': payload['app_potreiros_id'],
            'tipo': 'morte',
          }..removeWhere((key, value) => value == null);
        })
        .toList(growable: false);
    final pesoTotal = animais.fold<double>(
      0,
      (sum, animal) => sum + (_toDouble(animal['peso_total']) ?? 0),
    );

    return <String, dynamic>{
      'id': _localIdFromIdLocal(idLocal),
      'app_users_id': payload['app_users_id'],
      'app_movimentacoes_categorias_id': 0,
      'app_potreiros_id': payload['app_potreiros_id'],
      'data': payload['data'],
      'qtd_animais': animais.length,
      'peso_total': pesoTotal == 0 ? null : pesoTotal,
      'peso_medio': animais.isEmpty || pesoTotal == 0
          ? null
          : pesoTotal / animais.length,
      'animais': animais,
    }..removeWhere((key, value) => value == null);
  }

  static double? _toDouble(dynamic value) {
    if (value == null) {
      return null;
    }
    final normalized = value
        .toString()
        .replaceAll('R\$', '')
        .replaceAll(',', '.')
        .trim();
    return double.tryParse(normalized);
  }

  static int _localIdFromIdLocal(String idLocal) {
    var hash = 0;
    for (final codeUnit in idLocal.codeUnits) {
      hash = (hash * 31 + codeUnit) & 0x3fffffff;
    }
    return -hash.abs();
  }
}
