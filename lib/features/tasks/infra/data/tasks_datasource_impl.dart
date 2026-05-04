import 'package:costeira/core/api/api_client.dart';
import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/api/api_response_utils.dart';
import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/core/models/api_message.dart';
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
  const TasksDatasourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<TasksListEntity> getTasks(TaskFilterEntity filter) async {
    final payload = TaskFilterRequestDto.fromEntity(filter).data;
    AppLogger.info('TASKS DATASOURCE: LIST PAYLOAD=$payload');

    final response = await _apiClient.post(WSConstantes.tarefasListar, data: payload);

    AppLogger.success('TASKS DATASOURCE: LIST RAW RESPONSE=$response');
    return TasksListResponseModel.fromJson(responseAsMap(response));
  }

  @override
  Future<ApiMessage> saveTask(TaskUpsertEntity task) async {
    final payload = TaskUpsertRequestDto.fromEntity(task).data;
    AppLogger.info('TASKS DATASOURCE: SAVE PAYLOAD=$payload');

    final response = await _apiClient.post(WSConstantes.tarefasAdicionar, data: payload);

    AppLogger.success('TASKS DATASOURCE: SAVE RAW RESPONSE=$response');
    return _parseMutationResponse(
      response,
      operationName: 'SAVE TASK',
      expectedSuccessMessage: 'Tarefa salva com sucesso.',
    );
  }

  @override
  Future<ApiMessage> deleteTask(DeleteTaskEntity task) async {
    final payload = DeleteTaskRequestDto.fromEntity(task).data;
    AppLogger.info('TASKS DATASOURCE: DELETE PAYLOAD=$payload');

    final response = await _apiClient.post(WSConstantes.tarefasExcluir, data: payload);

    AppLogger.success('TASKS DATASOURCE: DELETE RAW RESPONSE=$response');
    return _parseMutationResponse(
      response,
      operationName: 'DELETE TASK',
      expectedSuccessMessage: 'Tarefa excluida com sucesso.',
    );
  }

  @override
  Future<ApiMessage> setTaskDone(TaskStatusEntity task) async {
    final payload = TaskStatusRequestDto.fromEntity(task).data;
    AppLogger.info('TASKS DATASOURCE: SET DONE PAYLOAD=$payload');

    final response = await _apiClient.post(WSConstantes.tarefasSetStatus, data: payload);

    AppLogger.success('TASKS DATASOURCE: SET DONE RAW RESPONSE=$response');
    return _parseMutationResponse(
      response,
      operationName: 'SET TASK DONE',
      expectedSuccessMessage: 'Tarefa concluida com sucesso.',
    );
  }

  @override
  Future<ApiMessage> saveResponsavel(TaskResponsavelUpsertEntity responsavel) async {
    final payload = TaskResponsavelUpsertRequestDto.fromEntity(responsavel).data;
    AppLogger.info('TASKS DATASOURCE: SAVE RESPONSAVEL PAYLOAD=$payload');

    final response = await _apiClient.post(WSConstantes.tarefasAdicionarResponsavel, data: payload);

    AppLogger.success('TASKS DATASOURCE: SAVE RESPONSAVEL RAW RESPONSE=$response');
    return _parseMutationResponse(
      response,
      operationName: 'SAVE RESPONSAVEL',
      expectedSuccessMessage: 'Responsavel salvo com sucesso.',
    );
  }

  @override
  Future<ApiMessage> deleteResponsavel(DeleteTaskResponsavelEntity responsavel) async {
    final payload = DeleteTaskResponsavelRequestDto.fromEntity(responsavel).data;
    AppLogger.info('TASKS DATASOURCE: DELETE RESPONSAVEL PAYLOAD=$payload');

    final response = await _apiClient.post(WSConstantes.tarefasExcluirResponsavel, data: payload);

    AppLogger.success('TASKS DATASOURCE: DELETE RESPONSAVEL RAW RESPONSE=$response');
    return _parseMutationResponse(
      response,
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
