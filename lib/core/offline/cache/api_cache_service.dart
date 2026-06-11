import 'package:costeira/core/offline/cache/api_cache_storage.dart';
import 'package:costeira/core/offline/cache/cache_entry.dart';
import 'package:costeira/core/offline/cache/cache_key_builder.dart';
import 'package:costeira/core/utils/app_logger.dart';

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
    AppLogger.success(
      'API CACHE: SAVE endpoint=$endpoint userId=${userId ?? 'anonymous'} key=$key payload=$requestPayload',
    );
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
    AppLogger.info(
      'API CACHE: ${data == null ? 'MISS' : 'HIT'} endpoint=$endpoint userId=${userId ?? 'anonymous'} key=$key payload=$requestPayload',
    );
    return data == null ? null : CacheEntry.fromJson(data);
  }

  CacheEntry? getLatestCacheForEndpoint({
    required String endpoint,
    int? userId,
  }) {
    final entries =
        _storage
            .readAll()
            .map(CacheEntry.fromJson)
            .where((entry) => entry.endpoint == endpoint)
            .where((entry) => userId == null || entry.userId == userId)
            .toList(growable: false)
          ..sort((left, right) => right.updatedAt.compareTo(left.updatedAt));

    final entry = entries.isEmpty ? null : entries.first;
    AppLogger.info(
      'API CACHE: ${entry == null ? 'MISS' : 'HIT'} latest endpoint=$endpoint userId=${userId ?? 'anonymous'} key=${entry?.key}',
    );
    return entry;
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
