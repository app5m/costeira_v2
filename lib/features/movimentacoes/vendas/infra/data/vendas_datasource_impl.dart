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
import 'package:costeira/features/movimentacoes/vendas/domain/entities/delete_venda_entity.dart';
import 'package:costeira/features/movimentacoes/vendas/domain/entities/venda_upsert_entity.dart';
import 'package:costeira/features/movimentacoes/vendas/domain/repository/vendas_datasource.dart';
import 'package:costeira/features/movimentacoes/vendas/infra/models/delete_venda_request_model.dart';
import 'package:costeira/features/movimentacoes/vendas/infra/models/venda_upsert_request_model.dart';

class VendasDatasourceImpl implements VendasDatasource {
  const VendasDatasourceImpl(
    this._offlineApiService,
    this._syncQueueService,
    this._mutationCacheService,
  );

  final OfflineApiService _offlineApiService;
  final SyncQueueService _syncQueueService;
  final OfflineMutationCacheService _mutationCacheService;

  @override
  Future<ApiMessage> createVenda(VendaUpsertEntity venda) async {
    if (venda.appUsersId == null) {
      throw ApiException('Usuario nao autenticado para cadastrar venda.');
    }

    final payload = VendaUpsertRequestModel.create(venda).data;
    AppLogger.info('VENDAS DATASOURCE: CREATE PAYLOAD=$payload');

    return _offlineApiService.postOrEnqueue(
      module: 'movimentacoes',
      action: SyncOperation.create,
      endpoint: WSConstantes.movimentacoesAdicionarVenda,
      payload: payload,
      priority: SyncPriority.movimentacoes,
      pendingMessage: 'Venda salva localmente para sincronizar.',
      rawResponseLog: 'VENDAS DATASOURCE: CREATE RAW RESPONSE',
      offlineCacheMutation: _vendasOfflineCacheMutation,
      parseResponse: (response) => _parseMutationResponse(
        response,
        operationName: 'CREATE VENDA',
        expectedSuccessMessage: 'Venda executada com sucesso',
      ),
    );
  }

  @override
  Future<ApiMessage> updateVenda(VendaUpsertEntity venda) async {
    if (venda.id == null) {
      throw ApiException('Informe o id da venda para atualizar.');
    }
    if (venda.appUsersId == null) {
      throw ApiException('Usuario nao autenticado para atualizar venda.');
    }

    final payload = VendaUpsertRequestModel.update(venda).data;
    AppLogger.info('VENDAS DATASOURCE: UPDATE PAYLOAD=$payload');

    return _offlineApiService.postOrEnqueue(
      module: 'movimentacoes',
      action: SyncOperation.update,
      endpoint: WSConstantes.movimentacoesAdicionarVenda,
      payload: payload,
      priority: SyncPriority.movimentacoes,
      pendingMessage: 'Alteracao da venda salva para sincronizar.',
      rawResponseLog: 'VENDAS DATASOURCE: UPDATE RAW RESPONSE',
      offlineCacheMutation: _vendasOfflineCacheMutation,
      parseResponse: (response) => _parseMutationResponse(
        response,
        operationName: 'UPDATE VENDA',
        expectedSuccessMessage: 'Venda atualizada com sucesso',
      ),
    );
  }

  @override
  Future<ApiMessage> deleteVenda(DeleteVendaEntity venda) async {
    final payload = DeleteVendaRequestModel.fromEntity(venda).data;
    AppLogger.info(
      'VENDAS DATASOURCE: DELETE ID=${venda.id} IS_LOCAL=${venda.id < 0} PAYLOAD=$payload',
    );

    if (venda.id < 0) {
      return _cancelPendingLocalVenda(venda, payload);
    }

    final result = await _offlineApiService.postOrEnqueue(
      module: 'movimentacoes',
      action: SyncOperation.delete,
      endpoint: WSConstantes.movimentacoesExcluirVenda,
      payload: payload,
      priority: SyncPriority.movimentacoes,
      pendingMessage: 'Exclusao da venda salva para sincronizar.',
      rawResponseLog: 'VENDAS DATASOURCE: DELETE RAW RESPONSE',
      offlineCacheMutation: _vendasOfflineCacheMutation,
      parseResponse: (response) => _parseMutationResponse(
        response,
        operationName: 'DELETE VENDA',
        expectedSuccessMessage: 'Venda excluida com sucesso',
      ),
    );

    final pendingDeleteItems = _syncQueueService
        .getPendingItems()
        .where(
          (item) =>
              item.module == 'movimentacoes' &&
              item.action == SyncOperation.delete &&
              item.endpoint == WSConstantes.movimentacoesExcluirVenda &&
              item.payload['app_users_id']?.toString() ==
                  venda.appUsersId.toString(),
        )
        .toList(growable: false);
    AppLogger.info(
      'VENDAS DATASOURCE: EXCLUSOES DE VENDA PENDENTES NA FILA=${pendingDeleteItems.length} IDS=${pendingDeleteItems.map((item) => item.payload['id']).join(',')}',
    );

    return result;
  }

  Future<ApiMessage> _cancelPendingLocalVenda(
    DeleteVendaEntity venda,
    Map<String, dynamic> payload,
  ) async {
    final pendingCreate = _syncQueueService
        .getPendingItems()
        .where(
          (item) =>
              item.module == 'movimentacoes' &&
              item.action == SyncOperation.create &&
              item.endpoint == WSConstantes.movimentacoesAdicionarVenda &&
              item.payload['app_users_id']?.toString() ==
                  venda.appUsersId.toString() &&
              _localIdFromIdLocal(item.idLocal) == venda.id,
        )
        .firstOrNull;

    await _mutationCacheService.applyMutation(
      action: SyncOperation.delete,
      listEndpoint: WSConstantes.movimentacoesListar,
      listPayload: _defaultListPayload(payload),
      userId: venda.appUsersId,
      itemId: venda.id,
      idLocal: pendingCreate?.idLocal,
      listField: 'data.vendas',
      allowLatestCacheFallback: true,
    );

    if (pendingCreate != null) {
      await _syncQueueService.removeItem(pendingCreate.idLocal);
      AppLogger.success(
        'VENDAS DATASOURCE: VENDA LOCAL PENDENTE CANCELADA ID_LOCAL=${pendingCreate.idLocal}',
      );
    } else {
      AppLogger.warning(
        'VENDAS DATASOURCE: VENDA LOCAL SEM FILA REMOVIDA DO CACHE ID=${venda.id}',
      );
    }

    return const ApiMessage(status: '01', message: 'Venda local removida.');
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
        'VENDAS DATASOURCE: $operationName RETORNOU CONTRATO INVALIDO RAW=$response',
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

  static final OfflineCacheMutation _vendasOfflineCacheMutation =
      OfflineCacheMutation(
        listEndpoint: WSConstantes.movimentacoesListar,
        listPayloadBuilder: _defaultListPayload,
        listField: 'data.vendas',
        createCacheWhenMissing: true,
        emptyResponse: _emptyListResponse,
        itemBuilder: _buildCachedVendaItem,
      );

  static Map<String, dynamic> _defaultListPayload(
    Map<String, dynamic> payload,
  ) {
    final userId = int.tryParse(payload['app_users_id']?.toString() ?? '');
    if (userId == null) {
      return <String, dynamic>{};
    }

    return MovimentacaoFilterRequestModel.fromEntity(
      MovimentacaoFilterEntity(appUsersId: userId),
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

  static Map<String, dynamic> _buildCachedVendaItem(
    Map<String, dynamic> payload,
    String idLocal,
  ) {
    final animais = (payload['animais'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((animal) {
          return <String, dynamic>{
            ...Map<String, dynamic>.from(animal),
            'app_users_id': payload['app_users_id'],
            'tipo': 'venda',
          }..removeWhere((key, value) => value == null);
        })
        .toList(growable: false);
    final destinos = (payload['destinos'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((destino) => Map<String, dynamic>.from(destino))
        .toList(growable: false);
    final valorUnitario = _toDouble(payload['valor_unitario']);
    final valorTotal = valorUnitario == null
        ? null
        : valorUnitario * animais.length;

    return <String, dynamic>{
      'id': _localIdFromIdLocal(idLocal),
      'app_users_id': payload['app_users_id'],
      'app_movimentacoes_categorias_id': 0,
      'data': payload['data'],
      'valor_unitario': payload['valor_unitario'],
      'valor_unitario_raw': valorUnitario,
      'valor_total': valorTotal?.toStringAsFixed(2),
      'valor_total_raw': valorTotal,
      'comprador': payload['comprador'],
      'municipio': payload['municipio'],
      'obs': payload['obs'],
      'qtd_animais': animais.length,
      'animais': animais,
      'destinos': destinos,
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
