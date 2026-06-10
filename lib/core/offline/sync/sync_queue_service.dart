import 'package:costeira/core/offline/sync/sync_item.dart';
import 'package:costeira/core/offline/sync/sync_queue_storage.dart';
import 'package:costeira/core/offline/sync/sync_status.dart';
import 'package:uuid/uuid.dart';

class SyncQueueService {
  SyncQueueService(this._storage, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final SyncQueueStorage _storage;
  final Uuid _uuid;

  Future<SyncItem> addItem({
    required String module,
    required String action,
    required String endpoint,
    required Map<String, dynamic> payload,
    required int priority,
    String? idLocal,
  }) async {
    final now = DateTime.now();
    final item = SyncItem(
      idLocal: idLocal ?? _uuid.v4(),
      module: module,
      action: action,
      endpoint: endpoint,
      payload: payload,
      status: SyncStatus.pending,
      attempts: 0,
      priority: priority,
      createdAt: now,
      updatedAt: now,
    );

    await _storage.save(item);
    return item;
  }

  List<SyncItem> getPendingItems() {
    return _sortItems(
      _storage
          .readAll()
          .where((item) => item.status == SyncStatus.pending)
          .toList(growable: false),
    );
  }

  List<SyncItem> getAllItems() {
    return _sortItems(_storage.readAll());
  }

  Future<void> markAsSyncing(String idLocal) async {
    final item = _storage.read(idLocal);
    if (item == null) {
      return;
    }

    await _storage.save(
      item.copyWith(
        status: SyncStatus.syncing,
        attempts: item.attempts + 1,
        error: null,
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> markAsError(String idLocal, String error) async {
    final item = _storage.read(idLocal);
    if (item == null) {
      return;
    }

    await _storage.save(
      item.copyWith(
        status: SyncStatus.error,
        error: error,
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> markAsPending(String idLocal) async {
    final item = _storage.read(idLocal);
    if (item == null) {
      return;
    }

    await _storage.save(
      item.copyWith(
        status: SyncStatus.pending,
        error: null,
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> removeItem(String idLocal) async {
    await _storage.remove(idLocal);
  }

  Future<void> clearQueue() async {
    await _storage.clear();
  }

  int countPendingItems() {
    return _storage
        .readAll()
        .where((item) => item.status == SyncStatus.pending)
        .length;
  }

  int countErrorItems() {
    return _storage
        .readAll()
        .where((item) => item.status == SyncStatus.error)
        .length;
  }

  List<SyncItem> _sortItems(List<SyncItem> items) {
    return items..sort((left, right) {
      final priorityComparison = left.priority.compareTo(right.priority);
      if (priorityComparison != 0) {
        return priorityComparison;
      }
      return left.createdAt.compareTo(right.createdAt);
    });
  }
}
