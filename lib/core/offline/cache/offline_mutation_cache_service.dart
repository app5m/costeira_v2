import 'dart:convert';

import 'package:costeira/core/offline/cache/api_cache_service.dart';
import 'package:costeira/core/offline/sync/sync_operation.dart';
import 'package:costeira/core/offline/sync/sync_status.dart';
import 'package:costeira/core/utils/app_logger.dart';

class OfflineMutationCacheService {
  const OfflineMutationCacheService(this._apiCacheService);

  final ApiCacheService _apiCacheService;

  Future<bool> insertPendingItem({
    required String listEndpoint,
    required Map<String, dynamic> item,
    required String idLocal,
    Map<String, dynamic>? listPayload,
    int? userId,
    String listField = OfflineCacheFields.data,
    String rowsField = OfflineCacheFields.rows,
    bool insertAtStart = true,
    bool createCacheWhenMissing = false,
    dynamic emptyResponse,
    bool allowLatestCacheFallback = true,
  }) {
    final pendingItem = OfflineCacheMetadata.apply(
      item,
      idLocal: idLocal,
      pendingAction: SyncOperation.create,
      isLocalOnly: true,
    );

    return _mutateCachedList(
      listEndpoint: listEndpoint,
      listPayload: listPayload,
      userId: userId,
      listField: listField,
      rowsField: rowsField,
      operationDescription: SyncOperation.create,
      createCacheWhenMissing: createCacheWhenMissing,
      emptyResponse: emptyResponse,
      allowLatestCacheFallback: allowLatestCacheFallback,
      mutate: (items) {
        final existingIndex = _indexByLocalOrServerId(
          items,
          idLocal: idLocal,
          itemId: pendingItem[OfflineCacheFields.id],
        );

        if (existingIndex >= 0) {
          items[existingIndex] = pendingItem;
        } else if (insertAtStart) {
          items.insert(0, pendingItem);
        } else {
          items.add(pendingItem);
        }
        return true;
      },
    );
  }

  Future<bool> updatePendingItem({
    required String listEndpoint,
    required Map<String, dynamic> item,
    Object? itemId,
    String? idLocal,
    Map<String, dynamic>? listPayload,
    int? userId,
    String idField = OfflineCacheFields.id,
    String listField = OfflineCacheFields.data,
    String rowsField = OfflineCacheFields.rows,
    bool mergeWithCachedItem = true,
    bool allowLatestCacheFallback = true,
  }) {
    final resolvedItemId = itemId ?? item[idField];
    final pendingItem = OfflineCacheMetadata.apply(
      item,
      idLocal: idLocal,
      pendingAction: SyncOperation.update,
      isLocalOnly: item[OfflineCacheFields.isLocalOnly] == true,
    );

    return _mutateCachedList(
      listEndpoint: listEndpoint,
      listPayload: listPayload,
      userId: userId,
      listField: listField,
      rowsField: rowsField,
      operationDescription: SyncOperation.update,
      allowLatestCacheFallback: allowLatestCacheFallback,
      mutate: (items) {
        final index = _indexByLocalOrServerId(
          items,
          idField: idField,
          idLocal: idLocal ?? pendingItem[OfflineCacheFields.idLocal],
          itemId: resolvedItemId,
        );

        if (index < 0) {
          return false;
        }

        final current = items[index];
        items[index] = mergeWithCachedItem
            ? <String, dynamic>{...current, ...pendingItem}
            : pendingItem;
        return true;
      },
    );
  }

  Future<bool> removePendingItem({
    required String listEndpoint,
    Object? itemId,
    String? idLocal,
    Map<String, dynamic>? listPayload,
    int? userId,
    String idField = OfflineCacheFields.id,
    String listField = OfflineCacheFields.data,
    String rowsField = OfflineCacheFields.rows,
    bool allowLatestCacheFallback = true,
  }) {
    return _mutateCachedList(
      listEndpoint: listEndpoint,
      listPayload: listPayload,
      userId: userId,
      listField: listField,
      rowsField: rowsField,
      operationDescription: SyncOperation.delete,
      allowLatestCacheFallback: allowLatestCacheFallback,
      mutate: (items) {
        final initialLength = items.length;
        items.removeWhere(
          (item) => _matchesItem(
            item,
            idField: idField,
            idLocal: idLocal,
            itemId: itemId,
          ),
        );
        return items.length != initialLength;
      },
    );
  }

  Future<bool> markAsPendingDelete({
    required String listEndpoint,
    Object? itemId,
    String? idLocal,
    Map<String, dynamic>? listPayload,
    int? userId,
    String idField = OfflineCacheFields.id,
    String listField = OfflineCacheFields.data,
    String rowsField = OfflineCacheFields.rows,
    bool allowLatestCacheFallback = true,
  }) {
    return _mutateCachedList(
      listEndpoint: listEndpoint,
      listPayload: listPayload,
      userId: userId,
      listField: listField,
      rowsField: rowsField,
      operationDescription: 'pending_delete',
      allowLatestCacheFallback: allowLatestCacheFallback,
      mutate: (items) {
        final index = _indexByLocalOrServerId(
          items,
          idField: idField,
          idLocal: idLocal,
          itemId: itemId,
        );

        if (index < 0) {
          return false;
        }

        items[index] = OfflineCacheMetadata.apply(
          items[index],
          idLocal: idLocal,
          pendingAction: SyncOperation.delete,
          isLocalOnly: items[index][OfflineCacheFields.isLocalOnly] == true,
          pendingDelete: true,
        );
        return true;
      },
    );
  }

  Future<bool> applyMutation({
    required String action,
    required String listEndpoint,
    Map<String, dynamic>? item,
    Object? itemId,
    String? idLocal,
    Map<String, dynamic>? listPayload,
    int? userId,
    String idField = OfflineCacheFields.id,
    String listField = OfflineCacheFields.data,
    String rowsField = OfflineCacheFields.rows,
    bool markDeleteInsteadOfRemove = false,
    bool createCacheWhenMissing = false,
    dynamic emptyResponse,
    bool allowLatestCacheFallback = true,
  }) {
    switch (action) {
      case SyncOperation.create:
        if (item == null || idLocal == null) {
          return Future.value(false);
        }
        return insertPendingItem(
          listEndpoint: listEndpoint,
          listPayload: listPayload,
          userId: userId,
          item: item,
          idLocal: idLocal,
          listField: listField,
          rowsField: rowsField,
          createCacheWhenMissing: createCacheWhenMissing,
          emptyResponse: emptyResponse,
          allowLatestCacheFallback: allowLatestCacheFallback,
        );
      case SyncOperation.update:
        if (item == null) {
          return Future.value(false);
        }
        return updatePendingItem(
          listEndpoint: listEndpoint,
          listPayload: listPayload,
          userId: userId,
          item: item,
          itemId: itemId,
          idLocal: idLocal,
          idField: idField,
          listField: listField,
          rowsField: rowsField,
          allowLatestCacheFallback: allowLatestCacheFallback,
        );
      case SyncOperation.delete:
        if (markDeleteInsteadOfRemove) {
          return markAsPendingDelete(
            listEndpoint: listEndpoint,
            listPayload: listPayload,
            userId: userId,
            itemId: itemId,
            idLocal: idLocal,
            idField: idField,
            listField: listField,
            rowsField: rowsField,
            allowLatestCacheFallback: allowLatestCacheFallback,
          );
        }
        return removePendingItem(
          listEndpoint: listEndpoint,
          listPayload: listPayload,
          userId: userId,
          itemId: itemId,
          idLocal: idLocal,
          idField: idField,
          listField: listField,
          rowsField: rowsField,
          allowLatestCacheFallback: allowLatestCacheFallback,
        );
      default:
        return Future.value(false);
    }
  }

  Future<bool> applyNestedListMutation({
    required String action,
    required String listEndpoint,
    required String nestedListField,
    required String parentIdField,
    Map<String, dynamic>? item,
    Object? parentId,
    Object? itemId,
    String? idLocal,
    Map<String, dynamic>? listPayload,
    int? userId,
    String idField = OfflineCacheFields.id,
    String listField = OfflineCacheFields.data,
    String rowsField = OfflineCacheFields.rows,
    bool allowLatestCacheFallback = true,
  }) {
    return _mutateCachedList(
      listEndpoint: listEndpoint,
      listPayload: listPayload,
      userId: userId,
      listField: listField,
      rowsField: rowsField,
      operationDescription: 'nested_$action',
      allowLatestCacheFallback: allowLatestCacheFallback,
      mutate: (parents) {
        var didMutate = false;
        final pendingItem = item == null
            ? null
            : OfflineCacheMetadata.apply(
                item,
                idLocal: idLocal,
                pendingAction: action,
                isLocalOnly: action == SyncOperation.create,
              );

        for (final parent in parents) {
          final isTargetParent =
              parentId == null ||
              parent[parentIdField]?.toString() == parentId.toString();
          final nestedRaw = parent[nestedListField];
          if (!isTargetParent && action != SyncOperation.delete) {
            continue;
          }
          if (nestedRaw is! List) {
            if (isTargetParent &&
                action == SyncOperation.create &&
                pendingItem != null) {
              parent[nestedListField] = [pendingItem];
              didMutate = true;
            }
            continue;
          }

          final nested = nestedRaw
              .whereType<Map>()
              .map((child) => Map<String, dynamic>.from(child))
              .toList();

          if (action == SyncOperation.delete) {
            final before = nested.length;
            nested.removeWhere(
              (child) => _matchesItem(
                child,
                idField: idField,
                idLocal: idLocal,
                itemId: itemId,
              ),
            );
            didMutate = didMutate || nested.length != before;
          } else if (pendingItem != null && isTargetParent) {
            final index = _indexByLocalOrServerId(
              nested,
              idField: idField,
              idLocal: idLocal,
              itemId: itemId ?? pendingItem[idField],
            );
            if (index >= 0) {
              nested[index] = <String, dynamic>{
                ...nested[index],
                ...pendingItem,
              };
            } else {
              nested.insert(0, pendingItem);
            }
            didMutate = true;
          }

          parent[nestedListField] = nested;
        }

        return didMutate;
      },
    );
  }

  Future<bool> _mutateCachedList({
    required String listEndpoint,
    required Map<String, dynamic>? listPayload,
    required int? userId,
    required String listField,
    required String rowsField,
    required String operationDescription,
    bool createCacheWhenMissing = false,
    dynamic emptyResponse,
    bool allowLatestCacheFallback = true,
    required bool Function(List<Map<String, dynamic>> items) mutate,
  }) async {
    var cache = _apiCacheService.getCache(
      endpoint: listEndpoint,
      requestPayload: listPayload,
      userId: userId,
    );
    if (cache == null && allowLatestCacheFallback) {
      cache = _apiCacheService.getLatestCacheForEndpoint(
        endpoint: listEndpoint,
        userId: userId,
      );
    }

    if (cache == null) {
      if (createCacheWhenMissing && emptyResponse != null) {
        await _apiCacheService.saveCache(
          endpoint: listEndpoint,
          requestPayload: listPayload,
          response: emptyResponse,
          userId: userId,
        );
        cache = _apiCacheService.getCache(
          endpoint: listEndpoint,
          requestPayload: listPayload,
          userId: userId,
        );
      }
    }

    if (cache == null) {
      AppLogger.warning(
        'OFFLINE MUTATION CACHE: cache nao encontrado endpoint=$listEndpoint action=$operationDescription',
      );
      return false;
    }

    final normalized = _NormalizedCacheResponse.from(cache.response);
    final response = _cloneJson(normalized.value);
    final target = _resolveListTarget(response, listField);
    if (target == null) {
      AppLogger.warning(
        'OFFLINE MUTATION CACHE: lista nao encontrada endpoint=$listEndpoint action=$operationDescription listField=$listField',
      );
      return false;
    }

    final items = _readItemsFromTarget(response, target);
    final initialLength = items.length;

    final didMutate = mutate(items);

    if (!didMutate) {
      AppLogger.warning(
        'OFFLINE MUTATION CACHE: nenhum item alterado endpoint=$listEndpoint action=$operationDescription',
      );
      return false;
    }

    final updatedResponse = _writeItems(
      response,
      target: target,
      rowsField: rowsField,
      items: items,
    );

    await _apiCacheService.saveCache(
      endpoint: listEndpoint,
      requestPayload: cache.requestPayload,
      response: normalized.restore(updatedResponse),
      userId: userId,
    );

    AppLogger.success(
      'OFFLINE MUTATION CACHE: cache atualizado endpoint=$listEndpoint action=$operationDescription before=$initialLength after=${items.length}',
    );
    return true;
  }

  static _ListTarget? _resolveListTarget(dynamic response, String listField) {
    final explicitPath = listField.split('.');
    final explicitValue = _readPath(response, explicitPath);
    if (explicitValue is List) {
      return _ListTarget.path(explicitPath);
    }

    if (response is List) {
      final first = response.firstOrNull;
      if (first is Map) {
        final nestedPath = _firstListPath(Map<String, dynamic>.from(first));
        if (nestedPath != null && nestedPath.isNotEmpty) {
          return _ListTarget.path(nestedPath);
        }
      }
      return const _ListTarget.root();
    }

    final detectedPath = _detectListPath(response, preferredPath: explicitPath);
    return detectedPath == null ? null : _ListTarget.path(detectedPath);
  }

  static List<Map<String, dynamic>> _readItemsFromTarget(
    dynamic response,
    _ListTarget target,
  ) {
    if (target.isRoot && response is List) {
      return response
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    final list = _readPath(response, target.path);
    if (list is List) {
      return list
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    return <Map<String, dynamic>>[];
  }

  static dynamic _writeItems(
    dynamic response, {
    required _ListTarget target,
    required String rowsField,
    required List<Map<String, dynamic>> items,
  }) {
    if (target.isRoot) {
      return items;
    }

    final updated = _cloneJson(response);
    if (!_writePath(updated, target.path, items)) {
      return response;
    }

    _updateExistingRows(updated, target.path, rowsField, items.length);
    return updated;
  }

  static dynamic _readPath(dynamic root, List<String> path) {
    dynamic current = root;
    for (final segment in path) {
      if (current is List) {
        current = current.whereType<Map>().cast<Map>().firstOrNull;
      }

      if (current is Map) {
        current = current[segment];
      } else {
        return null;
      }
    }

    return current;
  }

  static bool _writePath(dynamic root, List<String> path, dynamic value) {
    final segments = path;
    dynamic current = root;

    for (var index = 0; index < segments.length - 1; index++) {
      if (current is List) {
        if (current.isEmpty || current.first is! Map) {
          return false;
        }
        current = current.first;
      }

      if (current is Map) {
        current = current[segments[index]];
      } else {
        return false;
      }
    }

    if (current is List) {
      if (current.isEmpty || current.first is! Map) {
        return false;
      }
      current = current.first;
    }

    if (current is Map) {
      current[segments.last] = value;
      return true;
    }

    return false;
  }

  static List<String>? _detectListPath(
    dynamic response, {
    required List<String> preferredPath,
  }) {
    final preferredContainer = _readPath(
      response,
      preferredPath.length <= 1
          ? const <String>[]
          : preferredPath.take(preferredPath.length - 1).toList(),
    );
    final fromPreferredContainer = _firstListPath(
      preferredContainer,
      prefix: preferredPath.length <= 1
          ? const <String>[]
          : preferredPath.take(preferredPath.length - 1).toList(),
    );
    if (fromPreferredContainer != null) {
      return fromPreferredContainer;
    }

    return _firstListPath(response);
  }

  static List<String>? _firstListPath(
    dynamic value, {
    List<String> prefix = const [],
  }) {
    if (value is List) {
      return prefix;
    }

    if (value is! Map) {
      return null;
    }

    for (final key in OfflineCacheFields.commonListFields) {
      final child = value[key];
      if (child is List) {
        return [...prefix, key];
      }
    }

    for (final key in OfflineCacheFields.commonListFields) {
      final child = value[key];
      if (child is Map) {
        final nested = _firstListPath(child, prefix: [...prefix, key]);
        if (nested != null) {
          return nested;
        }
      }
    }

    return null;
  }

  static void _updateExistingRows(
    dynamic root,
    List<String> listPath,
    String rowsField,
    int itemCount,
  ) {
    if (rowsField.isEmpty) {
      return;
    }

    final parentPath = listPath.isEmpty
        ? const <String>[]
        : listPath.take(listPath.length - 1).toList();
    final parent = _readPath(root, parentPath);
    if (parent is Map && parent.containsKey(rowsField)) {
      parent[rowsField] = itemCount;
    }

    if (root is Map &&
        root.containsKey(rowsField) &&
        _isPrimaryListPath(listPath)) {
      root[rowsField] = itemCount;
    }

    if (root is List &&
        root.firstOrNull is Map &&
        _isPrimaryListPath(listPath)) {
      final first = root.first as Map;
      if (first.containsKey(rowsField)) {
        first[rowsField] = itemCount;
      }
    }
  }

  static bool _isPrimaryListPath(List<String> listPath) {
    if (listPath.isEmpty) {
      return true;
    }

    final leaf = listPath.last;
    return leaf == OfflineCacheFields.data ||
        leaf == OfflineCacheFields.list ||
        leaf == OfflineCacheFields.lista ||
        leaf == OfflineCacheFields.items ||
        leaf == OfflineCacheFields.results;
  }

  static int _indexByLocalOrServerId(
    List<Map<String, dynamic>> items, {
    String idField = OfflineCacheFields.id,
    String? idLocal,
    Object? itemId,
  }) {
    return items.indexWhere(
      (item) => _matchesItem(
        item,
        idField: idField,
        idLocal: idLocal,
        itemId: itemId,
      ),
    );
  }

  static bool _matchesItem(
    Map<String, dynamic> item, {
    required String idField,
    String? idLocal,
    Object? itemId,
  }) {
    final hasLocalMatch =
        idLocal != null &&
        item[OfflineCacheFields.idLocal]?.toString() == idLocal;
    final hasServerMatch =
        itemId != null && item[idField]?.toString() == itemId.toString();

    return hasLocalMatch || hasServerMatch;
  }

  static dynamic _cloneJson(dynamic value) {
    if (value is Map) {
      return {
        for (final entry in value.entries)
          entry.key.toString(): _cloneJson(entry.value),
      };
    }

    if (value is List) {
      return value.map(_cloneJson).toList();
    }

    return value;
  }
}

class OfflineCacheMetadata {
  const OfflineCacheMetadata._();

  static Map<String, dynamic> apply(
    Map<String, dynamic> item, {
    String? idLocal,
    required String pendingAction,
    bool isLocalOnly = false,
    bool pendingDelete = false,
  }) {
    return <String, dynamic>{
      ...item,
      if (idLocal != null && item[OfflineCacheFields.id] == null)
        OfflineCacheFields.id: -idLocal.hashCode.abs(),
      if (idLocal != null) OfflineCacheFields.idLocal: idLocal,
      OfflineCacheFields.syncStatus: SyncStatus.pending,
      OfflineCacheFields.pendingAction: pendingAction,
      OfflineCacheFields.isLocalOnly: isLocalOnly,
      if (pendingDelete) OfflineCacheFields.pendingDelete: true,
    };
  }
}

class OfflineCacheFields {
  const OfflineCacheFields._();

  static const String data = 'data';
  static const String list = 'list';
  static const String lista = 'lista';
  static const String items = 'items';
  static const String results = 'results';
  static const String rows = 'rows';
  static const String id = 'id';
  static const String idLocal = 'idLocal';
  static const String syncStatus = 'syncStatus';
  static const String pendingAction = 'pendingAction';
  static const String isLocalOnly = 'isLocalOnly';
  static const String pendingDelete = 'pendingDelete';

  static const List<String> commonListFields = [
    data,
    list,
    lista,
    items,
    results,
  ];
}

class _NormalizedCacheResponse {
  const _NormalizedCacheResponse(this.value, {required this.wasJsonString});

  final dynamic value;
  final bool wasJsonString;

  factory _NormalizedCacheResponse.from(dynamic raw) {
    if (raw is String) {
      final trimmed = raw.trim();
      if (trimmed.isNotEmpty) {
        try {
          return _NormalizedCacheResponse(
            jsonDecode(trimmed),
            wasJsonString: true,
          );
        } catch (_) {}
      }
    }

    return _NormalizedCacheResponse(raw, wasJsonString: false);
  }

  dynamic restore(dynamic updatedValue) {
    return wasJsonString ? jsonEncode(updatedValue) : updatedValue;
  }
}

class _ListTarget {
  const _ListTarget.root() : path = const [], isRoot = true;
  const _ListTarget.path(this.path) : isRoot = false;

  final List<String> path;
  final bool isRoot;
}
