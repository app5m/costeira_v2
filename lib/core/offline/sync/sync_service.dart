import 'package:costeira/core/api/api_client.dart';
import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/api/api_response_utils.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/core/offline/network/network_status_service.dart';
import 'package:costeira/core/offline/sync/post_sync_cache_refresh_service.dart';
import 'package:costeira/core/offline/sync/sync_item.dart';
import 'package:costeira/core/offline/sync/sync_queue_service.dart';
import 'package:costeira/core/offline/sync/sync_result.dart';

class SyncService {
  SyncService(
    this._queueService,
    this._networkStatusService,
    this._apiClient,
    this._postSyncCacheRefreshService,
  );

  final SyncQueueService _queueService;
  final NetworkStatusService _networkStatusService;
  final ApiClient _apiClient;
  final PostSyncCacheRefreshService _postSyncCacheRefreshService;

  Future<SyncResult> syncPendingItems() async {
    if (!await _networkStatusService.hasConnection()) {
      return SyncResult.noConnection();
    }

    final pendingItems = _queueService.getPendingItems();
    if (pendingItems.isEmpty) {
      await _refreshMainCaches();
      return SyncResult.empty();
    }

    var successCount = 0;
    var errorCount = 0;
    var noConnection = false;
    final successfulItems = <SyncItem>[];

    for (final item in pendingItems) {
      if (!await _networkStatusService.hasConnection()) {
        noConnection = true;
        break;
      }

      await _queueService.markAsSyncing(item.idLocal);

      try {
        final response = await _apiClient.post(
          item.endpoint,
          data: item.payload,
        );
        _throwIfMutationFailed(response);
        await _queueService.removeItem(item.idLocal);
        successfulItems.add(item);
        successCount++;
      } catch (error) {
        if (!await _networkStatusService.hasConnection()) {
          await _queueService.markAsPending(item.idLocal);
          noConnection = true;
          break;
        }

        await _queueService.markAsError(item.idLocal, _errorMessage(error));
        errorCount++;
      }
    }

    final result = SyncResult(
      totalItems: pendingItems.length,
      successCount: successCount,
      errorCount: errorCount,
      noConnection: noConnection,
      isEmpty: false,
    );

    if (!noConnection) {
      await _refreshMainCaches(successfulItems);
    }

    return result;
  }

  Future<void> _refreshMainCaches([List<SyncItem> successfulItems = const []]) {
    return _postSyncCacheRefreshService.refreshMainCaches(
      successfulItems: successfulItems,
    );
  }

  void _throwIfMutationFailed(dynamic response) {
    final map = responseAsMap(response);
    final hasMutationContract =
        map.containsKey('status') || map.containsKey('msg');
    if (!hasMutationContract) {
      return;
    }

    final message = ApiMessage.fromResponse(response);
    if (!message.isSuccess) {
      throw ApiException(message.message);
    }
  }

  String _errorMessage(Object error) {
    if (error is ApiException) {
      return error.message;
    }
    return error.toString();
  }
}
