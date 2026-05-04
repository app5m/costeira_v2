import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/features/tasks/domain/entities/delete_task_responsavel_entity.dart';
import 'package:costeira/features/tasks/domain/entities/task_filter_entity.dart';
import 'package:costeira/features/tasks/domain/entities/task_responsavel_entity.dart';
import 'package:costeira/features/tasks/domain/usecases/delete_task_responsavel_usecase.dart';
import 'package:costeira/features/tasks/domain/usecases/get_task_responsaveis_usecase.dart';
import 'package:flutter/foundation.dart';

class ListTaskResponsaveisController extends ChangeNotifier {
  ListTaskResponsaveisController(
    this._getTaskResponsaveisUsecase,
    this._deleteTaskResponsavelUsecase,
  );

  final GetTaskResponsaveisUsecase _getTaskResponsaveisUsecase;
  final DeleteTaskResponsavelUsecase _deleteTaskResponsavelUsecase;

  bool _isLoading = false;
  String? _errorMessage;
  List<TaskResponsavelEntity> _responsaveis = const [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<TaskResponsavelEntity> get responsaveis => _responsaveis;

  Future<void> load() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final userId = await _getUserId('listar responsaveis');
      _responsaveis = await _getTaskResponsaveisUsecase(
        TaskFilterEntity(appUsersId: userId),
      );
    } on ApiException catch (error) {
      _errorMessage = error.message;
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<ApiMessage> deleteResponsavel(
    TaskResponsavelEntity responsavel,
  ) async {
    final id = responsavel.id;
    if (id == null) {
      remove(responsavel);
      return const ApiMessage(status: '01', message: 'Responsavel removido.');
    }

    final userId = await _getUserId('excluir responsavel');
    final message = await _deleteTaskResponsavelUsecase(
      DeleteTaskResponsavelEntity(appUsersId: userId, id: id),
    );
    remove(responsavel);
    return message;
  }

  void upsert(
    TaskResponsavelEntity responsavel,
    TaskResponsavelEntity? previous,
  ) {
    final current = List<TaskResponsavelEntity>.from(_responsaveis);
    final index = previous == null
        ? -1
        : current.indexWhere((item) => identical(item, previous));

    if (index >= 0) {
      current[index] = responsavel;
    } else {
      current.insert(0, responsavel);
    }

    _responsaveis = current;
    notifyListeners();
  }

  void remove(TaskResponsavelEntity responsavel) {
    _responsaveis = _responsaveis
        .where((item) => !identical(item, responsavel))
        .toList(growable: false);
    notifyListeners();
  }

  Future<int> _getUserId(String action) async {
    final user = await SessionStorage.getUserSession();
    final userId = user?.id ?? 0;
    if (userId <= 0) {
      throw ApiException('Usuario nao autenticado para $action.');
    }
    return userId;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
