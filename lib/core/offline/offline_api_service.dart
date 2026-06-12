import 'dart:async';

import 'package:costeira/core/api/api_client.dart';
import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/core/offline/cache/api_cache_service.dart';
import 'package:costeira/core/offline/cache/offline_mutation_cache_service.dart';
import 'package:costeira/core/offline/network/network_status_service.dart';
import 'package:costeira/core/offline/sync/sync_operation.dart';
import 'package:costeira/core/offline/sync/sync_queue_service.dart';
import 'package:costeira/core/utils/app_logger.dart';

class OfflineApiService {
  const OfflineApiService(
    this._apiClient,
    this._networkStatusService,
    this._apiCacheService,
    this._syncQueueService,
    this._mutationCacheService,
  );

  final ApiClient _apiClient;
  final NetworkStatusService _networkStatusService;
  final ApiCacheService _apiCacheService;
  final SyncQueueService _syncQueueService;
  final OfflineMutationCacheService _mutationCacheService;

  Future<T> postCached<T>({
    required String endpoint,
    required Map<String, dynamic> payload,
    required T Function(dynamic response) parser,
    required String missingCacheMessage,
    required String rawResponseLog,
    int? userId,
    bool useLatestCacheFallback = false,
  }) async {
    if (!await _networkStatusService.hasConnection()) {
      return _getCachedOrThrow(
        endpoint: endpoint,
        payload: payload,
        userId: userId,
        parser: parser,
        missingCacheMessage: missingCacheMessage,
        useLatestFallback: useLatestCacheFallback,
      );
    }

    try {
      final response = await _apiClient.post(endpoint, data: payload);
      AppLogger.success('$rawResponseLog=$response');

      await _apiCacheService.saveCache(
        endpoint: endpoint,
        requestPayload: payload,
        response: response,
        userId: userId,
      );

      return parser(response);
    } catch (error) {
      final canUseCacheFallback =
          !await _networkStatusService.hasConnection() ||
          _isConnectionFailure(error);

      if (canUseCacheFallback) {
        final cached = _getCached(
          endpoint: endpoint,
          payload: payload,
          userId: userId,
          parser: parser,
        );
        if (cached != null) {
          return cached;
        }
      }
      rethrow;
    }
  }

  Future<ApiMessage> postOrEnqueue({
    required String module,
    required String action,
    required String endpoint,
    required Map<String, dynamic> payload,
    required int priority,
    required String pendingMessage,
    required FutureOr<ApiMessage> Function(dynamic response) parseResponse,
    required String rawResponseLog,
    OfflineCacheMutation? offlineCacheMutation,
  }) async {
    if (!await _networkStatusService.hasConnection()) {
      return _enqueue(
        module: module,
        action: action,
        endpoint: endpoint,
        payload: payload,
        priority: priority,
        message: pendingMessage,
        offlineCacheMutation: offlineCacheMutation,
      );
    }

    try {
      final response = await _apiClient.post(endpoint, data: payload);
      AppLogger.success('$rawResponseLog=$response');
      return await parseResponse(response);
    } catch (error) {
      if (_isConnectionFailure(error)) {
        return _enqueue(
          module: module,
          action: action,
          endpoint: endpoint,
          payload: payload,
          priority: priority,
          message: pendingMessage,
          offlineCacheMutation: offlineCacheMutation,
        );
      }
      rethrow;
    }
  }

  T _getCachedOrThrow<T>({
    required String endpoint,
    required Map<String, dynamic> payload,
    required int? userId,
    required T Function(dynamic response) parser,
    required String missingCacheMessage,
    bool useLatestFallback = false,
  }) {
    final cached = _getCached(
      endpoint: endpoint,
      payload: payload,
      userId: userId,
      parser: parser,
      useLatestFallback: useLatestFallback,
    );
    if (cached != null) {
      return cached;
    }

    AppLogger.warning('OFFLINE API SERVICE: CACHE NAO ENCONTRADO');
    throw ApiException(missingCacheMessage);
  }

  T? _getCached<T>({
    required String endpoint,
    required Map<String, dynamic> payload,
    required int? userId,
    required T Function(dynamic response) parser,
    bool useLatestFallback = false,
  }) {
    final cache = _apiCacheService.getCache(
      endpoint: endpoint,
      requestPayload: payload,
      userId: userId,
    );

    if (cache == null) {
      if (!useLatestFallback) {
        return null;
      }

      final latestCache = _apiCacheService.getLatestCacheForEndpoint(
        endpoint: endpoint,
        userId: userId,
      );
      if (latestCache != null) {
        AppLogger.success(
          'OFFLINE API SERVICE: USANDO ULTIMO CACHE DO ENDPOINT KEY=${latestCache.key}',
        );
        return parser(latestCache.response);
      }

      return null;
    }

    AppLogger.success('OFFLINE API SERVICE: USANDO CACHE KEY=${cache.key}');
    return parser(cache.response);
  }

  Future<ApiMessage> _enqueue({
    required String module,
    required String action,
    required String endpoint,
    required Map<String, dynamic> payload,
    required int priority,
    required String message,
    OfflineCacheMutation? offlineCacheMutation,
  }) async {
    final item = await _syncQueueService.addItem(
      module: module,
      action: action,
      endpoint: endpoint,
      payload: payload,
      priority: priority,
    );
    await _applyOfflineCacheMutation(
      action: action,
      payload: payload,
      idLocal: item.idLocal,
      mutation: offlineCacheMutation,
    );

    AppLogger.success(
      'OFFLINE API SERVICE: MUTATION ENFILEIRADA ID=${item.idLocal} MODULE=$module ACTION=$action',
    );

    return ApiMessage(
      status: '01',
      message: message,
      extra: {'sync_pending': true, 'id_local': item.idLocal},
    );
  }

  bool _isConnectionFailure(Object error) {
    return error is ApiException && error.statusCode == null;
  }

  Future<void> _applyOfflineCacheMutation({
    required String action,
    required Map<String, dynamic> payload,
    required String idLocal,
    required OfflineCacheMutation? mutation,
  }) async {
    if (mutation == null) {
      return;
    }

    final item =
        mutation.itemBuilder?.call(payload, idLocal) ??
        _defaultCachedItem(payload);
    final itemId = mutation.itemId ?? payload[mutation.idField];
    final userId =
        mutation.userId ??
        int.tryParse(payload['app_users_id']?.toString() ?? '');
    final listPayload =
        mutation.listPayloadBuilder?.call(payload) ?? mutation.listPayload;
    final emptyResponse =
        mutation.emptyResponseBuilder?.call(payload) ?? mutation.emptyResponse;

    if (mutation.nestedListField != null && mutation.parentIdField != null) {
      await _mutationCacheService.applyNestedListMutation(
        action: action,
        listEndpoint: mutation.listEndpoint,
        listPayload: listPayload,
        userId: userId,
        item: action == SyncOperation.delete ? null : item,
        parentId: mutation.parentId ?? payload[mutation.parentIdField],
        parentIdField: mutation.parentIdField!,
        nestedListField: mutation.nestedListField!,
        itemId: itemId,
        idLocal: idLocal,
        idField: mutation.idField,
        listField: mutation.listField,
        rowsField: mutation.rowsField,
        allowLatestCacheFallback: mutation.allowLatestCacheFallback,
      );
      return;
    }

    await _mutationCacheService.applyMutation(
      action: action,
      listEndpoint: mutation.listEndpoint,
      listPayload: listPayload,
      userId: userId,
      item: action == SyncOperation.delete ? null : item,
      itemId: itemId,
      idLocal: idLocal,
      idField: mutation.idField,
      listField: mutation.listField,
      rowsField: mutation.rowsField,
      markDeleteInsteadOfRemove: mutation.markDeleteInsteadOfRemove,
      createCacheWhenMissing:
          mutation.createCacheWhenMissing && action == SyncOperation.create,
      emptyResponse: action == SyncOperation.create ? emptyResponse : null,
      allowLatestCacheFallback: mutation.allowLatestCacheFallback,
    );
  }

  Map<String, dynamic> _defaultCachedItem(Map<String, dynamic> payload) {
    final item = Map<String, dynamic>.from(payload)..remove('token');
    final animais = item['animais'];
    if (animais is List && item['qtd_animais'] == null) {
      item['qtd_animais'] = animais.length;
    }
    return item;
  }
}

class OfflineCacheMutation {
  const OfflineCacheMutation({
    required this.listEndpoint,
    this.listPayload,
    this.listPayloadBuilder,
    this.userId,
    this.itemId,
    this.parentId,
    this.parentIdField,
    this.nestedListField,
    this.idField = OfflineCacheFields.id,
    this.listField = OfflineCacheFields.data,
    this.rowsField = OfflineCacheFields.rows,
    this.markDeleteInsteadOfRemove = false,
    this.createCacheWhenMissing = false,
    this.emptyResponse,
    this.emptyResponseBuilder,
    this.allowLatestCacheFallback = true,
    this.itemBuilder,
  });

  final String listEndpoint;
  final Map<String, dynamic>? listPayload;
  final Map<String, dynamic>? Function(Map<String, dynamic> payload)?
  listPayloadBuilder;
  final int? userId;
  final Object? itemId;
  final Object? parentId;
  final String? parentIdField;
  final String? nestedListField;
  final String idField;
  final String listField;
  final String rowsField;
  final bool markDeleteInsteadOfRemove;
  final bool createCacheWhenMissing;
  final dynamic emptyResponse;
  final dynamic Function(Map<String, dynamic> payload)? emptyResponseBuilder;
  final bool allowLatestCacheFallback;
  final Map<String, dynamic> Function(
    Map<String, dynamic> payload,
    String idLocal,
  )?
  itemBuilder;
}
