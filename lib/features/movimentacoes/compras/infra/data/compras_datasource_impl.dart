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
import 'package:costeira/features/movimentacoes/compras/domain/entities/compra_upsert_entity.dart';
import 'package:costeira/features/movimentacoes/compras/domain/entities/delete_compra_entity.dart';
import 'package:costeira/features/movimentacoes/compras/domain/repository/compras_datasource.dart';
import 'package:costeira/features/movimentacoes/compras/infra/models/compra_upsert_request_model.dart';
import 'package:costeira/features/movimentacoes/compras/infra/models/delete_compra_request_model.dart';
import 'package:costeira/features/movimentacoes/domain/entities/movimentacao_filter_entity.dart';
import 'package:costeira/features/movimentacoes/infra/models/movimentacao_filter_request_model.dart';

class ComprasDatasourceImpl implements ComprasDatasource {
  const ComprasDatasourceImpl(
    this._offlineApiService,
    this._syncQueueService,
    this._mutationCacheService,
  );

  final OfflineApiService _offlineApiService;
  final SyncQueueService _syncQueueService;
  final OfflineMutationCacheService _mutationCacheService;

  @override
  Future<ApiMessage> createCompra(CompraUpsertEntity compra) async {
    if (compra.appUsersId == null) {
      throw ApiException('Usuario nao autenticado para cadastrar compra.');
    }

    final payload = CompraUpsertRequestModel.create(compra).data;
    AppLogger.info('COMPRAS DATASOURCE: CREATE PAYLOAD=$payload');

    return _offlineApiService.postOrEnqueue(
      module: 'movimentacoes',
      action: SyncOperation.create,
      endpoint: WSConstantes.movimentacoesAdicionarCompra,
      payload: payload,
      priority: SyncPriority.movimentacoes,
      pendingMessage: 'Compra salva localmente para sincronizar.',
      rawResponseLog: 'COMPRAS DATASOURCE: CREATE RAW RESPONSE',
      offlineCacheMutation: _comprasOfflineCacheMutation,
      parseResponse: (response) => _parseMutationResponse(
        response,
        operationName: 'CREATE COMPRA',
        expectedSuccessMessage: 'Compra cadastrada com sucesso',
      ),
    );
  }

  @override
  Future<ApiMessage> updateCompra(CompraUpsertEntity compra) async {
    if (compra.id == null) {
      throw ApiException('Informe o id da compra para atualizar.');
    }
    if (compra.appUsersId == null) {
      throw ApiException('Usuario nao autenticado para atualizar compra.');
    }

    final payload = CompraUpsertRequestModel.update(compra).data;
    AppLogger.info('COMPRAS DATASOURCE: UPDATE PAYLOAD=$payload');

    return _offlineApiService.postOrEnqueue(
      module: 'movimentacoes',
      action: SyncOperation.update,
      endpoint: WSConstantes.movimentacoesAdicionarCompra,
      payload: payload,
      priority: SyncPriority.movimentacoes,
      pendingMessage: 'Alteração da compra salva para sincronizar.',
      rawResponseLog: 'COMPRAS DATASOURCE: UPDATE RAW RESPONSE',
      offlineCacheMutation: _comprasOfflineCacheMutation,
      parseResponse: (response) => _parseMutationResponse(
        response,
        operationName: 'UPDATE COMPRA',
        expectedSuccessMessage: 'Compra atualizada com sucesso',
      ),
    );
  }

  @override
  Future<ApiMessage> deleteCompra(DeleteCompraEntity compra) async {
    final payload = DeleteCompraRequestModel.fromEntity(compra).data;
    AppLogger.info('COMPRAS DATASOURCE: DELETE PAYLOAD=$payload');

    if (compra.id < 0) {
      return _cancelPendingLocalCompra(compra, payload);
    }

    final result = await _offlineApiService.postOrEnqueue(
      module: 'movimentacoes',
      action: SyncOperation.delete,
      endpoint: WSConstantes.movimentacoesExcluirCompra,
      payload: payload,
      priority: SyncPriority.movimentacoes,
      pendingMessage: 'Exclusão da compra salva para sincronizar.',
      rawResponseLog: 'COMPRAS DATASOURCE: DELETE RAW RESPONSE',
      offlineCacheMutation: _comprasOfflineCacheMutation,
      parseResponse: (response) => _parseMutationResponse(
        response,
        operationName: 'DELETE COMPRA',
        expectedSuccessMessage: 'Compra excluida com sucesso',
      ),
    );

    final pendingDeleteCount = _syncQueueService
        .getPendingItems()
        .where(
          (item) =>
              item.module == 'movimentacoes' &&
              item.action == SyncOperation.delete &&
              item.endpoint == WSConstantes.movimentacoesExcluirCompra &&
              item.payload['app_users_id']?.toString() ==
                  compra.appUsersId.toString(),
        )
        .length;
    AppLogger.info(
      'COMPRAS DATASOURCE: EXCLUSOES DE COMPRA PENDENTES NA FILA=$pendingDeleteCount',
    );

    return result;
  }

  Future<ApiMessage> _cancelPendingLocalCompra(
    DeleteCompraEntity compra,
    Map<String, dynamic> payload,
  ) async {
    final pendingCreate = _syncQueueService
        .getPendingItems()
        .where(
          (item) =>
              item.module == 'movimentacoes' &&
              item.action == SyncOperation.create &&
              item.endpoint == WSConstantes.movimentacoesAdicionarCompra &&
              item.payload['app_users_id']?.toString() ==
                  compra.appUsersId.toString() &&
              _localIdFromIdLocal(item.idLocal) == compra.id,
        )
        .firstOrNull;

    if (pendingCreate == null) {
      await _mutationCacheService.applyMutation(
        action: SyncOperation.delete,
        listEndpoint: WSConstantes.movimentacoesListar,
        listPayload: _defaultListPayload(payload),
        userId: compra.appUsersId,
        itemId: compra.id,
        listField: 'data.compras',
        allowLatestCacheFallback: true,
      );
      AppLogger.warning(
        'COMPRAS DATASOURCE: COMPRA LOCAL SEM FILA REMOVIDA DO CACHE ID=${compra.id}',
      );
      return const ApiMessage(status: '01', message: 'Compra local removida.');
    }

    await _mutationCacheService.applyMutation(
      action: SyncOperation.delete,
      listEndpoint: WSConstantes.movimentacoesListar,
      listPayload: _defaultListPayload(payload),
      userId: compra.appUsersId,
      itemId: compra.id,
      idLocal: pendingCreate.idLocal,
      listField: 'data.compras',
      allowLatestCacheFallback: true,
    );
    await _syncQueueService.removeItem(pendingCreate.idLocal);

    AppLogger.success(
      'COMPRAS DATASOURCE: COMPRA LOCAL PENDENTE CANCELADA ID_LOCAL=${pendingCreate.idLocal}',
    );

    return const ApiMessage(status: '01', message: 'Compra local removida.');
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
        'COMPRAS DATASOURCE: $operationName RETORNOU CONTRATO INVALIDO RAW=$response',
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

  static final OfflineCacheMutation _comprasOfflineCacheMutation =
      OfflineCacheMutation(
        listEndpoint: WSConstantes.movimentacoesListar,
        listPayloadBuilder: _defaultListPayload,
        listField: 'data.compras',
        createCacheWhenMissing: true,
        emptyResponse: _emptyListResponse,
        itemBuilder: _buildCachedCompraItem,
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

  static Map<String, dynamic> _buildCachedCompraItem(
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
            'tipo': 'compra',
          }..removeWhere((key, value) => value == null);
        })
        .toList(growable: false);

    final pesoTotal = animais.fold<double>(
      0,
      (sum, animal) => sum + (_toDouble(animal['peso_total']) ?? 0),
    );
    final valorUnitario = _toDouble(payload['valor_unitario']);
    final valorTotal = valorUnitario == null
        ? null
        : valorUnitario * animais.length;

    return <String, dynamic>{
      'id': _localIdFromIdLocal(idLocal),
      'app_users_id': payload['app_users_id'],
      'app_movimentacoes_categorias_id': 0,
      'app_potreiros_id': payload['app_potreiros_id'],
      'app_animais_lotes_id': payload['app_animais_lotes_id'],
      'data': payload['data'],
      'tipo_compra': payload['tipo_compra'],
      'valor_unitario': payload['valor_unitario'],
      'valor_unitario_raw': valorUnitario,
      'valor_total': valorTotal?.toStringAsFixed(2),
      'valor_total_raw': valorTotal,
      'fornecedor': payload['fornecedor'],
      'municipio': payload['municipio'],
      'obs': payload['obs'],
      'qtd_animais': animais.length,
      'peso_total': pesoTotal == 0 ? null : pesoTotal,
      'peso_medio': animais.isEmpty ? null : pesoTotal / animais.length,
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
