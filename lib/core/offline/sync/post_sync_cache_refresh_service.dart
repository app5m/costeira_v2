import 'package:costeira/core/offline/cache/offline_mutation_cache_service.dart';
import 'package:costeira/core/offline/sync/sync_item.dart';
import 'package:costeira/core/offline/sync/sync_operation.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/features/auth/models/user_session.dart';
import 'package:costeira/features/animals/domain/entities/animal_lots_filter_entity.dart';
import 'package:costeira/features/animals/domain/entities/animals_filter_entity.dart';
import 'package:costeira/features/animals/domain/usecases/get_animal_lots_usecase.dart';
import 'package:costeira/features/animals/domain/usecases/get_animals_usecase.dart';
import 'package:costeira/features/movimentacoes/domain/entities/movimentacao_filter_entity.dart';
import 'package:costeira/features/movimentacoes/domain/usecases/get_compras_usecase.dart';
import 'package:costeira/features/movimentacoes/infra/data/movimentacao_offline_cache_mutation.dart';
import 'package:costeira/features/fazendas/domain/usecases/resolve_current_farm_id.dart';
import 'package:costeira/features/potreiros/domain/entities/potreiros_filter_entity.dart';
import 'package:costeira/features/potreiros/domain/usecases/get_potreiros_usecase.dart';

class PostSyncCacheRefreshService {
  const PostSyncCacheRefreshService(
    this._getPotreirosUsecase,
    this._getAnimalLotsUsecase,
    this._getAnimalsUsecase,
    this._getComprasUsecase,
    this._mutationCacheService,
    this._resolveCurrentFarmId,
  );

  final GetPotreirosUsecase _getPotreirosUsecase;
  final GetAnimalLotsUsecase _getAnimalLotsUsecase;
  final GetAnimalsUsecase _getAnimalsUsecase;
  final GetComprasUsecase _getComprasUsecase;
  final OfflineMutationCacheService _mutationCacheService;
  final ResolveCurrentFarmId _resolveCurrentFarmId;

  Future<void> refreshMainCaches({
    List<SyncItem> successfulItems = const [],
  }) async {
    final session = await _getSession();
    final userId = session?.id ?? 0;
    if (userId <= 0) {
      AppLogger.warning(
        'POST SYNC CACHE REFRESH: usuario nao autenticado, refresh ignorado',
      );
      return;
    }

    final farmId = await _resolveCurrentFarmId(userId: userId);
    if (farmId != null) {
      await _refresh(
        description: 'potreiros',
        action: () => _getPotreirosUsecase(
          PotreirosFilterEntity(appUsersId: userId, appFazendasId: farmId),
        ),
      );
      await _refresh(
        description: 'lotes',
        action: () => _getAnimalLotsUsecase(
          AnimalLotsFilterEntity(appUsersId: userId, appFazendasId: farmId),
        ),
      );
      await _refresh(
        description: 'animais',
        action: () => _getAnimalsUsecase(
          AnimalsFilterEntity(appUsersId: userId, appFazendasId: farmId),
        ),
      );
    }
    await _refresh(
      description: 'movimentacoes',
      action: () =>
          _getComprasUsecase(MovimentacaoFilterEntity(appUsersId: userId)),
    );

    await _removeSuccessfulLocalCreates(successfulItems);
    await _reapplySuccessfulDeletes(successfulItems);
  }

  Future<UserSession?> _getSession() async {
    try {
      return SessionStorage.getUserSession();
    } catch (error) {
      AppLogger.warning('POST SYNC CACHE REFRESH: falha ao ler sessao: $error');
      return null;
    }
  }

  Future<void> _refresh({
    required String description,
    required Future<Object?> Function() action,
  }) async {
    try {
      await action();
      AppLogger.success(
        'POST SYNC CACHE REFRESH: cache de $description atualizado',
      );
    } catch (error) {
      AppLogger.warning(
        'POST SYNC CACHE REFRESH: falha ao atualizar $description: $error',
      );
    }
  }

  Future<void> _reapplySuccessfulDeletes(List<SyncItem> successfulItems) async {
    final deleteItems = successfulItems
        .where(
          (item) =>
              item.action == SyncOperation.delete &&
              item.module == 'movimentacoes',
        )
        .toList(growable: false);
    if (deleteItems.isEmpty) {
      return;
    }

    for (final item in deleteItems) {
      final mutation = MovimentacaoOfflineCacheMutation.forEndpoint(
        item.endpoint,
      );
      if (mutation == null) {
        continue;
      }

      final userId = int.tryParse(
        item.payload['app_users_id']?.toString() ?? '',
      );
      final itemId = item.payload[mutation.idField];
      final listPayload =
          mutation.listPayloadBuilder?.call(item.payload) ??
          mutation.listPayload;

      await _mutationCacheService.applyMutation(
        action: SyncOperation.delete,
        listEndpoint: mutation.listEndpoint,
        listPayload: listPayload,
        userId: userId,
        itemId: itemId,
        idField: mutation.idField,
        listField: mutation.listField,
        rowsField: mutation.rowsField,
        allowLatestCacheFallback: true,
      );
    }
  }

  Future<void> _removeSuccessfulLocalCreates(
    List<SyncItem> successfulItems,
  ) async {
    final createItems = successfulItems
        .where(
          (item) =>
              item.action == SyncOperation.create &&
              item.module == 'movimentacoes',
        )
        .toList(growable: false);
    if (createItems.isEmpty) {
      return;
    }

    for (final item in createItems) {
      final mutation = MovimentacaoOfflineCacheMutation.forEndpoint(
        item.endpoint,
      );
      if (mutation == null) {
        continue;
      }

      final userId = int.tryParse(
        item.payload['app_users_id']?.toString() ?? '',
      );
      final listPayload =
          mutation.listPayloadBuilder?.call(item.payload) ??
          mutation.listPayload;

      await _mutationCacheService.applyMutation(
        action: SyncOperation.delete,
        listEndpoint: mutation.listEndpoint,
        listPayload: listPayload,
        userId: userId,
        idLocal: item.idLocal,
        idField: mutation.idField,
        listField: mutation.listField,
        rowsField: mutation.rowsField,
        allowLatestCacheFallback: true,
      );
    }
  }
}
