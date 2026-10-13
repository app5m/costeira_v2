import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/features/fazendas/domain/usecases/resolve_current_farm_id.dart';
import 'package:costeira/features/manejos_animais/domain/entities/manejo_animal_lista.dart';
import 'package:costeira/features/manejos_animais/domain/usecases/listar_manejos_animais_usecase.dart';
import 'package:flutter/foundation.dart';

class ListarManejosAnimaisController extends ChangeNotifier {
  ListarManejosAnimaisController(this._usecase, this._resolveFarm);

  final ListarManejosAnimaisUsecase _usecase;
  final ResolveCurrentFarmId _resolveFarm;

  int categoriaId = ManejoAnimalCategoria.lista.first.id;
  List<ManejoAnimalListaItem> itens = const [];
  bool loading = true;
  String? error;

  Future<void> init() => load();

  Future<void> setCategoria(int id) async {
    if (categoriaId == id) {
      return;
    }
    categoriaId = id;
    await load();
  }

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final user = await SessionStorage.getUserSession();
      if (user == null) {
        throw ApiException('Usuario nao autenticado.');
      }
      final farmId = await _resolveFarm(userId: user.id);
      if (farmId == null) {
        throw ApiException('Cadastre uma fazenda antes de listar os manejos.');
      }
      final result = await _usecase(
        appUsersId: user.id,
        appFazendasId: farmId,
        idCategoria: categoriaId,
      );
      itens = result.itens;
    } on ApiException catch (e) {
      itens = const [];
      error = e.message;
    } catch (_) {
      itens = const [];
      error = 'Nao foi possivel listar os manejos.';
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
