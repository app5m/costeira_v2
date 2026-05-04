import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/features/tasks/domain/entities/delete_task_entity.dart';
import 'package:costeira/features/tasks/domain/entities/task_entity.dart';
import 'package:costeira/features/tasks/domain/entities/task_filter_entity.dart';
import 'package:costeira/features/tasks/domain/entities/task_status_entity.dart';
import 'package:costeira/features/tasks/domain/usecases/delete_task_usecase.dart';
import 'package:costeira/features/tasks/domain/usecases/get_tasks_usecase.dart';
import 'package:costeira/features/tasks/domain/usecases/set_task_done_usecase.dart';
import 'package:flutter/foundation.dart';

class ListTasksController extends ChangeNotifier {
  ListTasksController(
    this._getTasksUsecase,
    this._deleteTaskUsecase,
    this._setTaskDoneUsecase,
  );

  final GetTasksUsecase _getTasksUsecase;
  final DeleteTaskUsecase _deleteTaskUsecase;
  final SetTaskDoneUsecase _setTaskDoneUsecase;

  bool _isLoading = false;
  String? _errorMessage;
  List<TaskEntity> _tasks = const [];
  int _rows = 0;
  TaskFilterEntity _filter = TaskFilterEntity(month: DateTime.now());
  int _reloadVersion = 0;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<TaskEntity> get tasks => _tasks;
  int get rows => _rows;
  TaskFilterEntity get filter => _filter;

  Future<void> load({TaskFilterEntity? filter}) async {
    final requestVersion = ++_reloadVersion;
    final nextFilter = filter ?? _filter;

    _setLoading(true);
    _errorMessage = null;

    try {
      final userId = await _getUserId('carregar tarefas');
      final requestFilter = nextFilter.copyWith(appUsersId: userId);

      final result = await _getTasksUsecase(requestFilter);
      AppLogger.info(
        'TASKS LIST CONTROLLER: API MONTH=${_formatMonthForLog(requestFilter.month)} '
        'ROWS=${result.rows} TASKS=${result.data.length}',
      );

      if (requestVersion != _reloadVersion) {
        AppLogger.info(
          'TASKS LIST CONTROLLER: IGNORANDO RESPOSTA ANTIGA '
          'MONTH=${_formatMonthForLog(requestFilter.month)}',
        );
        return;
      }

      _filter = nextFilter;
      _rows = result.rows;
      _tasks = result.data;
      AppLogger.info(
        'TASKS LIST CONTROLLER: APLICADO MONTH=${_formatMonthForLog(_filter.month)} '
        'TASKS=${_tasks.length}',
      );
    } on ApiException catch (error) {
      _errorMessage = error.message;
      rethrow;
    } finally {
      if (requestVersion == _reloadVersion) {
        _setLoading(false);
      }
    }
  }

  Future<void> reload() async {
    await load(filter: _filter);
  }

  Future<ApiMessage> deleteTask(TaskEntity task) async {
    final userId = await _getUserId('excluir tarefa');
    final message = await _deleteTaskUsecase(
      DeleteTaskEntity(appUsersId: userId, id: task.id),
    );
    _tasks = _tasks.where((item) => item.id != task.id).toList(growable: false);
    _rows = _tasks.length;
    notifyListeners();
    return message;
  }

  Future<ApiMessage> setDone(TaskEntity task) async {
    final userId = await _getUserId('concluir tarefa');
    final message = await _setTaskDoneUsecase(
      TaskStatusEntity(appUsersId: userId, id: task.id),
    );
    await reload();
    return message;
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

  String _formatMonthForLog(DateTime? month) {
    if (month == null) {
      return '-';
    }
    return '${month.month.toString().padLeft(2, '0')}/${month.year}';
  }
}
