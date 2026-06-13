import 'package:costeira/core/offline/network/network_status_service.dart';
import 'package:costeira/core/offline/sync/sync_item.dart';
import 'package:costeira/core/offline/sync/sync_queue_service.dart';
import 'package:costeira/core/offline/sync/sync_result.dart';
import 'package:costeira/core/offline/sync/sync_service.dart';
import 'package:costeira/core/offline/sync/sync_status.dart';
import 'package:flutter/foundation.dart';

class SyncController extends ChangeNotifier {
  SyncController(this._networkStatusService, this._syncQueueService, this._syncService);

  final NetworkStatusService _networkStatusService;
  final SyncQueueService _syncQueueService;
  final SyncService _syncService;

  bool _isLoading = false;
  bool _isSyncing = false;
  bool _isOnline = false;
  String? _message;
  SyncResult? _lastResult;
  List<SyncItem> _items = const [];

  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;
  bool get isOnline => _isOnline;
  String? get message => _message;
  SyncResult? get lastResult => _lastResult;
  List<SyncItem> get items => _items;

  int get pendingCount => _items.where((item) => item.status == SyncStatus.pending).length;

  int get syncingCount => _items.where((item) => item.status == SyncStatus.syncing).length;

  int get errorCount => _items.where((item) => item.status == SyncStatus.error).length;

  int get visibleCount => _items.length;

  bool get hasItems => _items.isNotEmpty;

  bool get canSyncNow => _isOnline && pendingCount > 0 && !_isSyncing && !_isLoading;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    try {
      _isOnline = await _networkStatusService.hasConnection();
      _items = _syncQueueService.getAllItems();
      _message = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshConnectionStatus() async {
    _isOnline = await _networkStatusService.hasConnection();
    notifyListeners();
  }

  Future<void> syncNow() async {
    if (_isSyncing || _isLoading) {
      return;
    }

    _isOnline = await _networkStatusService.hasConnection();
    if (!_isOnline) {
      _message = 'Conecte-se a internet para enviar as alterações pendentes.';
      notifyListeners();
      return;
    }

    _items = _syncQueueService.getAllItems();
    if (pendingCount == 0) {
      _message = 'Nenhuma alteração pendente para sincronizar.';
      notifyListeners();
      return;
    }

    _isSyncing = true;
    _message = null;
    _lastResult = null;
    notifyListeners();

    try {
      final result = await _syncService.syncPendingItems();
      _lastResult = result;
      _items = _syncQueueService.getAllItems();
      _message = _resultMessage(result);
    } finally {
      _isSyncing = false;
      _isOnline = await _networkStatusService.hasConnection();
      _items = _syncQueueService.getAllItems();
      notifyListeners();
    }
  }

  String _resultMessage(SyncResult result) {
    if (result.noConnection) {
      return 'Sem conexão para sincronizar.';
    }
    if (errorCount > 0 || result.errorCount > 0) {
      return 'Alguns itens não puderam ser sincronizados.';
    }
    if (result.isEmpty) {
      return 'Tudo sincronizado.';
    }
    return '${result.successCount} de ${result.totalItems} alterações sincronizadas.';
  }
}
