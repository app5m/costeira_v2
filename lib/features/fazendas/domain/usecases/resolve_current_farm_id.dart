import 'package:costeira/core/storage/sub_user_payload.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/features/fazendas/domain/entities/fazenda_filter_entity.dart';
import 'package:costeira/features/fazendas/domain/usecases/get_fazendas_usecase.dart';
import 'package:flutter/foundation.dart';

class ResolveCurrentFarmId {
  const ResolveCurrentFarmId(this._getFazendasUsecase);

  final GetFazendasUsecase _getFazendasUsecase;

  Future<int?> call({int? preferred, int? userId}) async {
    if (preferred != null && preferred > 0) {
      return preferred;
    }

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
    return selected;
  }
}
