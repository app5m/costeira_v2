import 'package:costeira/core/offline/cache/api_cache_storage.dart';
import 'package:costeira/core/offline/cache/cache_entry.dart';
import 'package:costeira/core/offline/cache/cache_key_builder.dart';

class ApiCacheService {
  ApiCacheService(this._storage);

  final ApiCacheStorage _storage;

  Future<CacheEntry> saveCache({
    required String endpoint,
    required dynamic response,
    Map<String, dynamic>? requestPayload,
    int? userId,
  }) async {
    final key = CacheKeyBuilder.build(
      endpoint: endpoint,
      requestPayload: requestPayload,
      userId: userId,
    );
    final entry = CacheEntry(
      key: key,
      endpoint: endpoint,
      requestPayload: requestPayload,
      response: response,
      userId: userId,
      updatedAt: DateTime.now(),
    );

    await _storage.save(key, entry.toJson());
    return entry;
  }

  CacheEntry? getCache({
    required String endpoint,
    Map<String, dynamic>? requestPayload,
    int? userId,
  }) {
    final key = CacheKeyBuilder.build(
      endpoint: endpoint,
      requestPayload: requestPayload,
      userId: userId,
    );
    final data = _storage.read(key);
    return data == null ? null : CacheEntry.fromJson(data);
  }

  Future<void> removeCache({
    required String endpoint,
    Map<String, dynamic>? requestPayload,
    int? userId,
  }) async {
    final key = CacheKeyBuilder.build(
      endpoint: endpoint,
      requestPayload: requestPayload,
      userId: userId,
    );
    await _storage.remove(key);
  }

  Future<void> clearCache() async {
    await _storage.clear();
  }

  bool hasCache({
    required String endpoint,
    Map<String, dynamic>? requestPayload,
    int? userId,
  }) {
    final key = CacheKeyBuilder.build(
      endpoint: endpoint,
      requestPayload: requestPayload,
      userId: userId,
    );
    return _storage.contains(key);
  }
}
