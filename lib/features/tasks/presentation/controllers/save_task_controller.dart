import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/features/tasks/domain/entities/task_entity.dart';
import 'package:costeira/features/tasks/domain/entities/task_upsert_entity.dart';
import 'package:costeira/features/tasks/domain/usecases/save_task_usecase.dart';
import 'package:flutter/foundation.dart';

class SaveTaskController extends ChangeNotifier {
  SaveTaskController(this._saveTaskUsecase);

  final SaveTaskUsecase _saveTaskUsecase;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<ApiMessage> submit({
    TaskEntity? task,
    int? responsavelId,
    required int tipo,
    required String descricao,
    required String obs,
    required int urgencia,
    required List<String> datas,
  }) async {
    _setLoading(true);
    try {
      final userId = await _getUserId();
      return _saveTaskUsecase(
        TaskUpsertEntity(
          id: task?.id,
          appUsersId: userId,
          responsavelId: responsavelId,
          tipo: tipo,
          descricao: descricao,
          obs: obs,
          urgencia: urgencia,
          datas: datas,
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
      throw ApiException('Usuario nao autenticado para salvar tarefa.');
    }
    return userId;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
