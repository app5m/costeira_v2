import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/features/auth/models/user_session.dart';
import 'package:costeira/features/animals/domain/entities/animal_lots_filter_entity.dart';
import 'package:costeira/features/animals/domain/entities/animals_filter_entity.dart';
import 'package:costeira/features/animals/domain/usecases/get_animal_lots_usecase.dart';
import 'package:costeira/features/animals/domain/usecases/get_animals_usecase.dart';
import 'package:costeira/features/movimentacoes/domain/entities/movimentacao_filter_entity.dart';
import 'package:costeira/features/movimentacoes/domain/usecases/get_compras_usecase.dart';
import 'package:costeira/features/potreiros/domain/entities/potreiros_filter_entity.dart';
import 'package:costeira/features/potreiros/domain/usecases/get_potreiros_usecase.dart';

class PostSyncCacheRefreshService {
  const PostSyncCacheRefreshService(
    this._getPotreirosUsecase,
    this._getAnimalLotsUsecase,
    this._getAnimalsUsecase,
    this._getComprasUsecase,
  );

  final GetPotreirosUsecase _getPotreirosUsecase;
  final GetAnimalLotsUsecase _getAnimalLotsUsecase;
  final GetAnimalsUsecase _getAnimalsUsecase;
  final GetComprasUsecase _getComprasUsecase;

  Future<void> refreshMainCaches() async {
    final session = await _getSession();
    final userId = session?.id ?? 0;
    if (userId <= 0) {
      AppLogger.warning(
        'POST SYNC CACHE REFRESH: usuario nao autenticado, refresh ignorado',
      );
      return;
    }

    await _refresh(
      description: 'potreiros',
      action: () =>
          _getPotreirosUsecase(PotreirosFilterEntity(appUsersId: userId)),
    );
    await _refresh(
      description: 'lotes',
      action: () =>
          _getAnimalLotsUsecase(AnimalLotsFilterEntity(appUsersId: userId)),
    );
    await _refresh(
      description: 'animais',
      action: () => _getAnimalsUsecase(AnimalsFilterEntity(appUsersId: userId)),
    );
    await _refresh(
      description: 'movimentacoes',
      action: () =>
          _getComprasUsecase(MovimentacaoFilterEntity(appUsersId: userId)),
    );
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
}
