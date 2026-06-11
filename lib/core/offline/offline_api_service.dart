import 'dart:async';

import 'package:costeira/core/api/api_client.dart';
import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/core/offline/cache/api_cache_service.dart';
import 'package:costeira/core/offline/network/network_status_service.dart';
import 'package:costeira/core/offline/sync/sync_queue_service.dart';
import 'package:costeira/core/utils/app_logger.dart';

class OfflineApiService {
  const OfflineApiService(
    this._apiClient,
    this._networkStatusService,
    this._apiCacheService,
    this._syncQueueService,
  );

  final ApiClient _apiClient;
  final NetworkStatusService _networkStatusService;
  final ApiCacheService _apiCacheService;
  final SyncQueueService _syncQueueService;

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
  }) async {
    if (!await _networkStatusService.hasConnection()) {
      return _enqueue(
        module: module,
        action: action,
        endpoint: endpoint,
        payload: payload,
        priority: priority,
        message: pendingMessage,
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
  }) async {
    final item = await _syncQueueService.addItem(
      module: module,
      action: action,
      endpoint: endpoint,
      payload: payload,
      priority: priority,
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
}
