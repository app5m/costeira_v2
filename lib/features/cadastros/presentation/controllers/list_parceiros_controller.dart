import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/features/cadastros/domain/entities/parceiro_entity.dart';
import 'package:costeira/features/cadastros/domain/entities/parceiro_filter_entity.dart';
import 'package:costeira/features/cadastros/domain/entities/parceiro_kind.dart';
import 'package:costeira/features/cadastros/domain/usecases/get_parceiros_usecase.dart';
import 'package:flutter/foundation.dart';

class ListParceirosController extends ChangeNotifier {
  ListParceirosController(this._getParceirosUsecase);

  final GetParceirosUsecase _getParceirosUsecase;

  bool _isLoading = false;
  String? _errorMessage;
  List<ParceiroEntity> _parceiros = const [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<ParceiroEntity> get parceiros => _parceiros;

  Future<void> load({
    required ParceiroKind kind,
    required int appFazendasId,
    String? nome,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final user = await SessionStorage.getUserSession();
      if (user == null) {
        throw ApiException('Usuario nao autenticado.');
      }

      final result = await _getParceirosUsecase(
        ParceiroFilterEntity(
          kind: kind,
          appUsersId: user.id,
          appFazendasId: appFazendasId,
          nome: nome,
        ),
      );
      _parceiros = result.data;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void removeById(int id) {
    _parceiros = _parceiros.where((item) => item.id != id).toList();
    notifyListeners();
  }

  void clear() {
    _parceiros = const [];
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
