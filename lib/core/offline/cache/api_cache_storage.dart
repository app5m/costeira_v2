import 'package:costeira/core/offline/storage/offline_box_names.dart';
import 'package:hive/hive.dart';

class ApiCacheStorage {
  ApiCacheStorage({Box<dynamic>? box})
    : _box = box ?? Hive.box<dynamic>(OfflineBoxNames.apiCache);

  final Box<dynamic> _box;

  Future<void> save(String key, Map<String, dynamic> value) async {
    await _box.put(key, value);
  }

  Map<String, dynamic>? read(String key) {
    final value = _box.get(key);
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return null;
  }

  List<Map<String, dynamic>> readAll() {
    return _box.values
        .whereType<Map>()
        .map((value) => Map<String, dynamic>.from(value))
        .toList(growable: false);
  }

  Future<void> remove(String key) async {
    await _box.delete(key);
  }

  Future<void> clear() async {
    await _box.clear();
  }

  bool contains(String key) {
    return _box.containsKey(key);
  }
}
