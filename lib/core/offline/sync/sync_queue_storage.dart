import 'package:costeira/core/offline/storage/offline_box_names.dart';
import 'package:costeira/core/offline/sync/sync_item.dart';
import 'package:costeira/core/offline/sync/sync_status.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

class SyncQueueStorage {
  SyncQueueStorage({Box<dynamic>? box, Uuid? uuid})
    : _box = box ?? Hive.box<dynamic>(OfflineBoxNames.syncQueue),
      _uuid = uuid ?? const Uuid();

  final Box<dynamic> _box;
  final Uuid _uuid;

  Future<void> save(SyncItem item) async {
    await _box.put(item.idLocal, item.toJson());
  }

  SyncItem? read(String idLocal) {
    final value = _box.get(idLocal);
    if (value is Map) {
      return SyncItem.fromJson(Map<String, dynamic>.from(value));
    }
    return null;
  }

  List<SyncItem> readAll() {
    return _box.values
        .whereType<Map>()
        .map((item) => SyncItem.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  Future<String> enqueue(Map<String, dynamic> item) async {
    final id =
        item['id_local']?.toString() ?? item['id']?.toString() ?? _uuid.v4();
    final now = DateTime.now().toIso8601String();
    await _box.put(id, {
      ...item,
      'id_local': id,
      'status': item['status'] ?? SyncStatus.pending,
      'created_at': item['created_at'] ?? now,
      'updated_at': item['updated_at'] ?? now,
    });
    return id;
  }

  List<Map<String, dynamic>> pendingItems() {
    return _box.values
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .where((item) => item['status'] == SyncStatus.pending)
        .toList(growable: false);
  }

  Future<void> remove(String id) async {
    await _box.delete(id);
  }

  Future<void> clear() async {
    await _box.clear();
  }
}
