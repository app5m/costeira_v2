import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/features/fazendas/domain/entities/fazenda_filter_entity.dart';
import 'package:costeira/features/fazendas/domain/usecases/get_fazendas_usecase.dart';

class ResolveCurrentFarmId {
  const ResolveCurrentFarmId(this._getFazendasUsecase);

  final GetFazendasUsecase _getFazendasUsecase;

  Future<int?> call({int? preferred, int? userId}) async {
    if (preferred != null && preferred > 0) {
      return preferred;
    }

    final resolvedUserId =
        userId ?? (await SessionStorage.getUserSession())?.id;
    if (resolvedUserId == null || resolvedUserId <= 0) {
      return null;
    }

    final result = await _getFazendasUsecase(
      FazendaFilterEntity(appUsersId: resolvedUserId),
    );
    if (result.data.isEmpty) {
      return null;
    }
    final saved = await SessionStorage.getSelectedFarmId();
    if (saved != null && result.data.any((farm) => farm.id == saved)) {
      return saved;
    }
    return result.data.first.id;
  }
}
