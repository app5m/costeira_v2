import 'package:costeira/core/storage/sub_user_payload.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/features/fazendas/domain/entities/fazenda_filter_entity.dart';
import 'package:costeira/features/fazendas/domain/usecases/get_fazendas_usecase.dart';

class ResolveCurrentFarmId {
  ResolveCurrentFarmId(this._getFazendasUsecase);

  final GetFazendasUsecase _getFazendasUsecase;

  int? _cache;
  int? _cacheAccountId;
  Future<int?>? _inflight;

  /// Limpa cache em memória (ex.: troca de fazenda / cliente / logout).
  void limparCache() {
    _cache = null;
    _cacheAccountId = null;
    _inflight = null;
  }

  Future<int?> call({int? preferred, int? userId}) async {
    final accountId = await _resolveAccountId(userId);
    if (_cacheAccountId != null &&
        accountId != null &&
        _cacheAccountId != accountId) {
      limparCache();
    }

    if (preferred != null && preferred > 0) {
      _cache = preferred;
      _cacheAccountId = accountId;
      await SessionStorage.saveSelectedFarmId(preferred);
      return preferred;
    }
    if (_cache != null && _cache! > 0 && _cacheAccountId == accountId) {
      return _cache;
    }

    final pending = _inflight;
    if (pending != null) return pending;

    final future = _resolverDaApi(accountId);
    _inflight = future;
    try {
      return await future;
    } finally {
      if (identical(_inflight, future)) {
        _inflight = null;
      }
    }
  }

  Future<int?> _resolveAccountId(int? userId) async {
    final managedId = SessionStorage.cachedManagedClientId;
    final sessionUserId =
        managedId ?? userId ?? (await SessionStorage.getUserSession())?.id;
    if (sessionUserId == null || sessionUserId <= 0) {
      return null;
    }
    return sessionAccountUserId(sessionUserId);
  }

  Future<int?> _resolverDaApi(int? resolvedUserId) async {
    if (resolvedUserId == null || resolvedUserId <= 0) {
      return null;
    }

    final result = await _getFazendasUsecase(
      FazendaFilterEntity(appUsersId: resolvedUserId),
    );
    if (result.data.isEmpty) {
      await SessionStorage.clearSelectedFarmId();
      limparCache();
      return null;
    }
    final saved = await SessionStorage.getSelectedFarmId();
    // A API devolve a fazenda principal da conta na primeira posição.
    final fallbackFarmId = result.data.first.id;
    final selected =
        saved != null && result.data.any((farm) => farm.id == saved)
        ? saved
        : fallbackFarmId;
    if (selected != saved) {
      await SessionStorage.saveSelectedFarmId(selected);
    }
    _cache = selected;
    _cacheAccountId = resolvedUserId;
    return selected;
  }
}
