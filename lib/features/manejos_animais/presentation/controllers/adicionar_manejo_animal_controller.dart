import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/features/fazendas/domain/usecases/resolve_current_farm_id.dart';
import 'package:costeira/features/manejos_animais/domain/usecases/adicionar_manejo_animal_usecase.dart';
import 'package:flutter/foundation.dart';

class AdicionarManejoAnimalController extends ChangeNotifier {
  AdicionarManejoAnimalController(
    this._usecase,
    this._resolveCurrentFarmId,
  );

  final AdicionarManejoAnimalUsecase _usecase;
  final ResolveCurrentFarmId _resolveCurrentFarmId;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<ApiMessage?> submit(Map<String, dynamic> fields) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final user = await SessionStorage.getUserSession();
      if (user == null) {
        throw ApiException('Usuario nao autenticado.');
      }
      final farmId = await _resolveCurrentFarmId(userId: user.id);
      if (farmId == null) {
        throw ApiException('Cadastre uma fazenda antes de registrar o manejo.');
      }
      return await _usecase(
        appUsersId: user.id,
        appFazendasId: farmId,
        fields: fields,
      );
    } on ApiException catch (error) {
      _errorMessage = error.message;
      return null;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
