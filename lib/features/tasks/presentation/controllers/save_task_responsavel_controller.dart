import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/features/fazendas/domain/usecases/resolve_current_farm_id.dart';
import 'package:costeira/features/tasks/domain/entities/task_responsavel_entity.dart';
import 'package:costeira/features/tasks/domain/entities/task_responsavel_upsert_entity.dart';
import 'package:costeira/features/tasks/domain/usecases/save_task_responsavel_usecase.dart';
import 'package:flutter/foundation.dart';

class SaveTaskResponsavelController extends ChangeNotifier {
  SaveTaskResponsavelController(
    this._saveTaskResponsavelUsecase,
    this._resolveCurrentFarmId,
  );

  final SaveTaskResponsavelUsecase _saveTaskResponsavelUsecase;
  final ResolveCurrentFarmId _resolveCurrentFarmId;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<ApiMessage> submit(TaskResponsavelEntity responsavel) async {
    _setLoading(true);
    try {
      final userId = await _getUserId();
      final farmId = await _resolveCurrentFarmId(userId: userId);
      if (farmId == null || farmId <= 0) {
        throw ApiException(
          'Selecione uma fazenda antes de salvar o responsavel.',
        );
      }
      return await _saveTaskResponsavelUsecase(
        TaskResponsavelUpsertEntity(
          id: responsavel.id,
          appUsersId: userId,
          appFazendasId: farmId,
          nome: responsavel.nome,
          email: responsavel.email,
          celular: responsavel.celular,
        ),
      );
    } finally {
      _setLoading(false);
    }
  }

  Future<int> _getUserId() async {
    final user = await SessionStorage.getUserSession();
    final userId = user?.id ?? 0;
    if (userId <= 0) {
      throw ApiException('Usuario nao autenticado para salvar responsavel.');
    }
    return userId;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
