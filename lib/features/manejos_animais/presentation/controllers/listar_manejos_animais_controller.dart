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

  int? categoriaId;
  List<ManejoAnimalListaItem> itens = const [];
  bool loading = false;
  bool excluindo = false;
  String? error;

  Future<void> init() async {}

  void limpar() {
    categoriaId = null;
    itens = const [];
    error = null;
    loading = false;
    notifyListeners();
  }

  Future<void> setCategoria(int id) async {
    if (categoriaId == id && !loading) {
      return;
    }
    categoriaId = id;
    await load();
  }

  Future<String?> excluir(int id) async {
    final categoria = categoriaId;
    if (categoria == null || excluindo) {
      return 'Escolha uma categoria.';
    }
    excluindo = true;
    notifyListeners();
    try {
      final user = await SessionStorage.getUserSession();
      if (user == null) {
        throw ApiException('Usuario nao autenticado.');
      }
      final farmId = await _resolveFarm(userId: user.id);
      if (farmId == null) {
        throw ApiException('Cadastre uma fazenda antes de excluir o manejo.');
      }
      final result = await _usecase.excluir(
        appUsersId: user.id,
        appFazendasId: farmId,
        id: id,
      );
      if (!result.isSuccess) {
        return result.message;
      }
      await load();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'Nao foi possivel excluir o manejo.';
    } finally {
      excluindo = false;
      notifyListeners();
    }
  }

  Future<void> load() async {
    final categoria = categoriaId;
    if (categoria == null) {
      return;
    }
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
        idCategoria: categoria,
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
