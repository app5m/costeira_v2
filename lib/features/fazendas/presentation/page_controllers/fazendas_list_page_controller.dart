import 'package:costeira/features/fazendas/domain/entities/fazenda_entity.dart';
import 'package:costeira/features/fazendas/presentation/controllers/list_fazendas_controller.dart';
import 'package:costeira/features/fazendas/presentation/page_controllers/page_action_result.dart';
import 'package:flutter/foundation.dart';

class FazendasListPageController extends ChangeNotifier {
  FazendasListPageController(this._listController) {
    _listController.addListener(notifyListeners);
  }

  final ListFazendasController _listController;

  List<FazendaEntity> get fazendas => _listController.fazendas;
  bool get isLoading => _listController.isLoading;
  String? get errorMessage => _listController.errorMessage;

  Future<PageActionResult?> loadInitialData() async {
    try {
      await _listController.load();
      return null;
    } catch (_) {
      return PageActionResult(
        isSuccess: false,
        message:
            _listController.errorMessage ??
            'Nao foi possivel carregar as fazendas.',
      );
    }
  }

  Future<PageActionResult?> reload() async {
    try {
      await _listController.reload();
      return null;
    } catch (_) {
      return PageActionResult(
        isSuccess: false,
        message:
            _listController.errorMessage ??
            'Nao foi possivel atualizar as fazendas.',
      );
    }
  }

  @override
  void dispose() {
    _listController.removeListener(notifyListeners);
    super.dispose();
  }
}
