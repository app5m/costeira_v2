import 'package:costeira/core/storage/sub_user_payload.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/features/fazendas/domain/entities/fazenda_filter_entity.dart';
import 'package:costeira/features/fazendas/domain/usecases/get_fazendas_usecase.dart';
import 'package:flutter/foundation.dart';

class ResolveCurrentFarmId {
  ResolveCurrentFarmId(this._getFazendasUsecase);

  final GetFazendasUsecase _getFazendasUsecase;

  int? _cache;
  Future<int?>? _inflight;

  /// Limpa cache em memória (ex.: troca de fazenda / logout).
  void limparCache() {
    _cache = null;
    _inflight = null;
  }

  Future<int?> call({int? preferred, int? userId}) async {
    if (preferred != null && preferred > 0) {
      _cache = preferred;
      return preferred;
    }
    if (_cache != null && _cache! > 0) {
      return _cache;
    }

    // Preferir fazenda já salva — evita N× /fazendas/listar (FinanceiroApi._base).
    final saved = await SessionStorage.getSelectedFarmId();
    if (saved != null && saved > 0) {
      _cache = saved;
      return saved;
    }

    final pending = _inflight;
    if (pending != null) return pending;

    final future = _resolverDaApi(userId);
    _inflight = future;
    try {
      return await future;
    } finally {
      if (identical(_inflight, future)) {
        _inflight = null;
      }
    }
  }

  Future<int?> _resolverDaApi(int? userId) async {
    final managedId = SessionStorage.cachedManagedClientId;
    final sessionUserId =
        managedId ?? userId ?? (await SessionStorage.getUserSession())?.id;
    final resolvedUserId = sessionUserId == null
        ? null
        : kIsWeb
        ? sessionAccountUserId(sessionUserId)
        : sessionUserId;
    if (resolvedUserId == null || resolvedUserId <= 0) {
      return null;
    }

    final result = await _getFazendasUsecase(
      FazendaFilterEntity(appUsersId: resolvedUserId),
    );
    if (result.data.isEmpty) {
      if (kIsWeb) {
        await SessionStorage.clearSelectedFarmId();
      }
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
    return selected;
  }
}
