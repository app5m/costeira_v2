import 'package:costeira/core/api/api_client.dart';
import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/api/api_response_utils.dart';
import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/core/offline/offline_api_service.dart';
import 'package:costeira/core/offline/sync/sync_operation.dart';
import 'package:costeira/core/offline/sync/sync_priority.dart';
import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/features/tasks/domain/entities/delete_task_entity.dart';
import 'package:costeira/features/tasks/domain/entities/delete_task_responsavel_entity.dart';
import 'package:costeira/features/tasks/domain/entities/task_charts_entity.dart';
import 'package:costeira/features/tasks/domain/entities/task_charts_filter_entity.dart';
import 'package:costeira/features/tasks/domain/entities/task_filter_entity.dart';
import 'package:costeira/features/tasks/domain/entities/task_responsavel_upsert_entity.dart';
import 'package:costeira/features/tasks/domain/entities/task_status_entity.dart';
import 'package:costeira/features/tasks/domain/entities/task_upsert_entity.dart';
import 'package:costeira/features/tasks/domain/entities/tasks_list_entity.dart';
import 'package:costeira/features/tasks/domain/repository/tasks_datasource.dart';
import 'package:costeira/features/tasks/infra/dtos/delete_task_request_dto.dart';
import 'package:costeira/features/tasks/infra/dtos/delete_task_responsavel_request_dto.dart';
import 'package:costeira/features/tasks/infra/dtos/task_charts_filter_request_dto.dart';
import 'package:costeira/features/tasks/infra/dtos/task_filter_request_dto.dart';
import 'package:costeira/features/tasks/infra/dtos/task_responsavel_upsert_request_dto.dart';
import 'package:costeira/features/tasks/infra/dtos/task_status_request_dto.dart';
import 'package:costeira/features/tasks/infra/dtos/task_upsert_request_dto.dart';
import 'package:costeira/features/tasks/infra/models/task_charts_response_model.dart';
import 'package:costeira/features/tasks/infra/models/tasks_list_response_model.dart';

class TasksDatasourceImpl implements TasksDatasource {
  const TasksDatasourceImpl(this._apiClient, this._offlineApiService);

  final ApiClient _apiClient;
  final OfflineApiService _offlineApiService;

  @override
  Future<TasksListEntity> getTasks(TaskFilterEntity filter) async {
    final payload = TaskFilterRequestDto.fromEntity(filter).data;
    AppLogger.info('TASKS DATASOURCE: LIST PAYLOAD=$payload');

    return _offlineApiService.postCached<TasksListEntity>(
      endpoint: WSConstantes.tarefasListar,
      payload: payload,
      userId: filter.appUsersId,
      parser: (response) => TasksListResponseModel.fromJson(responseAsMap(response)),
      missingCacheMessage: 'Sem conexão e sem dados salvos para tarefas.',
      rawResponseLog: 'TASKS DATASOURCE: LIST RAW RESPONSE',
    );
  }

  @override
  Future<ApiMessage> saveTask(TaskUpsertEntity task) async {
    final payload = TaskUpsertRequestDto.fromEntity(task).data;
    AppLogger.info('TASKS DATASOURCE: SAVE PAYLOAD=$payload');

    return _mutation(
      action: payload['id'] == null ? SyncOperation.create : SyncOperation.update,
      endpoint: WSConstantes.tarefasAdicionar,
      payload: payload,
      pendingMessage: 'Tarefa salva localmente para sincronizar.',
      rawResponseLog: 'TASKS DATASOURCE: SAVE RAW RESPONSE',
      operationName: 'SAVE TASK',
      expectedSuccessMessage: 'Tarefa salva com sucesso.',
    );
  }

  @override
  Future<ApiMessage> deleteTask(DeleteTaskEntity task) async {
    final payload = DeleteTaskRequestDto.fromEntity(task).data;
    AppLogger.info('TASKS DATASOURCE: DELETE PAYLOAD=$payload');

    return _mutation(
      action: SyncOperation.delete,
      endpoint: WSConstantes.tarefasExcluir,
      payload: payload,
      pendingMessage: 'Exclusão da tarefa salva para sincronizar.',
      rawResponseLog: 'TASKS DATASOURCE: DELETE RAW RESPONSE',
      operationName: 'DELETE TASK',
      expectedSuccessMessage: 'Tarefa excluida com sucesso.',
    );
  }

  @override
  Future<ApiMessage> setTaskDone(TaskStatusEntity task) async {
    final payload = TaskStatusRequestDto.fromEntity(task).data;
    AppLogger.info('TASKS DATASOURCE: SET DONE PAYLOAD=$payload');

    return _mutation(
      action: SyncOperation.update,
      endpoint: WSConstantes.tarefasSetStatus,
      payload: payload,
      pendingMessage: 'Status da tarefa salvo para sincronizar.',
      rawResponseLog: 'TASKS DATASOURCE: SET DONE RAW RESPONSE',
      operationName: 'SET TASK DONE',
      expectedSuccessMessage: 'Tarefa concluida com sucesso.',
    );
  }

  @override
  Future<ApiMessage> saveResponsavel(TaskResponsavelUpsertEntity responsavel) async {
    final payload = TaskResponsavelUpsertRequestDto.fromEntity(responsavel).data;
    AppLogger.info('TASKS DATASOURCE: SAVE RESPONSAVEL PAYLOAD=$payload');

    return _mutation(
      action: payload['id'] == null ? SyncOperation.create : SyncOperation.update,
      endpoint: WSConstantes.tarefasAdicionarResponsavel,
      payload: payload,
      pendingMessage: 'Responsavel da tarefa salvo para sincronizar.',
      rawResponseLog: 'TASKS DATASOURCE: SAVE RESPONSAVEL RAW RESPONSE',
      operationName: 'SAVE RESPONSAVEL',
      expectedSuccessMessage: 'Responsavel salvo com sucesso.',
    );
  }

  @override
  Future<ApiMessage> deleteResponsavel(DeleteTaskResponsavelEntity responsavel) async {
    final payload = DeleteTaskResponsavelRequestDto.fromEntity(responsavel).data;
    AppLogger.info('TASKS DATASOURCE: DELETE RESPONSAVEL PAYLOAD=$payload');

    return _mutation(
      action: SyncOperation.delete,
      endpoint: WSConstantes.tarefasExcluirResponsavel,
      payload: payload,
      pendingMessage: 'Exclusão do responsavel salva para sincronizar.',
      rawResponseLog: 'TASKS DATASOURCE: DELETE RESPONSAVEL RAW RESPONSE',
      operationName: 'DELETE RESPONSAVEL',
      expectedSuccessMessage: 'Responsavel excluido com sucesso.',
    );
  }

  @override
  Future<TaskChartsEntity> getTaskCharts(TaskChartsFilterEntity filter) async {
    final payload = TaskChartsFilterRequestDto.fromEntity(filter).data;
    AppLogger.info('TASKS DATASOURCE: CHARTS PAYLOAD=$payload');

    final response = await _apiClient.post(WSConstantes.tarefasGraficos, data: payload);

    AppLogger.success('TASKS DATASOURCE: CHARTS RAW RESPONSE=$response');

    final wrapper = responseAsMap(response);
    final dataList = wrapper['data'] as List<dynamic>? ?? const [];
    final first = dataList.whereType<Map>().cast<Map>().firstOrNull;

    if (first == null) {
      return TaskChartsEntity.empty;
    }

    return TaskChartsResponseModel.fromJson(Map<String, dynamic>.from(first));
  }

  Future<ApiMessage> _mutation({
    required String action,
    required String endpoint,
    required Map<String, dynamic> payload,
    required String pendingMessage,
    required String rawResponseLog,
    required String operationName,
    required String expectedSuccessMessage,
  }) {
    return _offlineApiService.postOrEnqueue(
      module: 'tasks',
      action: action,
      endpoint: endpoint,
      payload: payload,
      priority: SyncPriority.tasks,
      pendingMessage: pendingMessage,
      rawResponseLog: rawResponseLog,
      offlineCacheMutation: _cacheMutationFor(endpoint),
      parseResponse: (response) => _parseMutationResponse(
        response,
        operationName: operationName,
        expectedSuccessMessage: expectedSuccessMessage,
      ),
    );
  }

  OfflineCacheMutation? _cacheMutationFor(String endpoint) {
    switch (endpoint) {
      case WSConstantes.tarefasAdicionar:
      case WSConstantes.tarefasExcluir:
      case WSConstantes.tarefasSetStatus:
        return OfflineCacheMutation(
          listEndpoint: WSConstantes.tarefasListar,
          listPayloadBuilder: _defaultTasksListPayload,
          listField: 'data.lista',
          createCacheWhenMissing: true,
          emptyResponse: _emptyTasksListResponse,
          allowLatestCacheFallback: false,
        );
      case WSConstantes.tarefasAdicionarResponsavel:
      case WSConstantes.tarefasExcluirResponsavel:
        return OfflineCacheMutation(
          listEndpoint: WSConstantes.tarefasListar,
          listPayloadBuilder: _defaultTaskResponsaveisListPayload,
          listField: 'data.responsaveis',
          createCacheWhenMissing: true,
          emptyResponse: _emptyTasksListResponse,
          allowLatestCacheFallback: false,
        );
      default:
        return null;
    }
  }

  ApiMessage _parseMutationResponse(
    dynamic response, {
    required String operationName,
    required String expectedSuccessMessage,
  }) {
    final map = responseAsMap(response);
    final hasMutationContract = map.containsKey('status') || map.containsKey('msg');

    if (!hasMutationContract) {
      AppLogger.error('TASKS DATASOURCE: $operationName RETORNOU CONTRATO INVALIDO RAW=$response');
      throw ApiException('Resposta inesperada da API ao executar $operationName.');
    }

    final message = ApiMessage.fromResponse(response);
    if (!message.isSuccess) {
      throw ApiException(message.message);
    }

    if (message.message.trim().isEmpty) {
      return ApiMessage(status: message.status, message: expectedSuccessMessage);
    }

    return message;
  }
}

Map<String, dynamic> _defaultTaskResponsaveisListPayload(Map<String, dynamic> payload) {
  final userId = int.tryParse(payload['app_users_id']?.toString() ?? '');
  if (userId == null) {
    return <String, dynamic>{};
  }

  return TaskFilterRequestDto.fromEntity(TaskFilterEntity(appUsersId: userId)).data;
}

Map<String, dynamic> _defaultTasksListPayload(Map<String, dynamic> payload) {
  final userId = int.tryParse(payload['app_users_id']?.toString() ?? '');
  if (userId == null) {
    return <String, dynamic>{};
  }

  return TaskFilterRequestDto.fromEntity(
    TaskFilterEntity(appUsersId: userId, month: DateTime.now()),
  ).data;
}

const Map<String, dynamic> _emptyTasksListResponse = {
  'rows': 0,
  'data': {'lista': <Map<String, dynamic>>[], 'responsaveis': <Map<String, dynamic>>[]},
};
