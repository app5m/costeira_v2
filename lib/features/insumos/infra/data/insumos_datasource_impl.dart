import 'package:costeira/core/api/api_client.dart';
import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/api/api_response_utils.dart';
import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/core/offline/offline_api_service.dart';
import 'package:costeira/core/offline/sync/sync_operation.dart';
import 'package:costeira/core/offline/sync/sync_priority.dart';
import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/features/insumos/domain/entities/insumos.dart';
import 'package:costeira/features/insumos/domain/repository/insumos_datasource.dart';
import 'package:costeira/features/insumos/infra/models/delete_insumo_request_model.dart';
import 'package:costeira/features/insumos/infra/models/insumo_charts_filter_request_model.dart';
import 'package:costeira/features/insumos/infra/models/insumo_charts_response_model.dart';
import 'package:costeira/features/insumos/infra/models/insumo_registro_upsert_request_model.dart';
import 'package:costeira/features/insumos/infra/models/insumo_upsert_request_model.dart';
import 'package:costeira/features/insumos/infra/models/insumos_filter_request_model.dart';
import 'package:costeira/features/insumos/infra/models/insumos_list_response_model.dart';
import 'package:costeira/features/insumos/infra/models/insumos_tipo_filter_request_model.dart';
import 'package:costeira/features/insumos/infra/models/insumos_tipo_list_response_model.dart';

class InsumosDatasourceImpl implements InsumosDatasource {
  const InsumosDatasourceImpl(this._apiClient, this._offlineApiService);

  final ApiClient _apiClient;
  final OfflineApiService _offlineApiService;

  @override
  Future<InsumosListEntity> getInsumos(InsumosFilterEntity filter) async {
    final payload = InsumosFilterRequestModel.fromEntity(filter).data;
    AppLogger.info('INSUMOS DATASOURCE: LIST PAYLOAD=$payload');

    return _offlineApiService.postCached<InsumosListEntity>(
      endpoint: WSConstantes.insumosListar,
      payload: payload,
      userId: filter.appUsersId,
      parser: (response) =>
          InsumosListResponseModel.fromJson(responseAsMap(response)),
      missingCacheMessage: 'Sem conexao e sem dados salvos para insumos.',
      rawResponseLog: 'INSUMOS DATASOURCE: LIST RAW RESPONSE',
    );
  }

  @override
  Future<InsumoChartsEntity> getInsumoCharts(
    InsumoChartsFilterEntity filter,
  ) async {
    final payload = InsumoChartsFilterRequestModel.fromEntity(filter).data;
    AppLogger.info('INSUMOS DATASOURCE: CHARTS PAYLOAD=$payload');

    final response = await _apiClient.post(
      WSConstantes.insumosGraficos,
      data: payload,
    );

    AppLogger.success('INSUMOS DATASOURCE: CHARTS RAW RESPONSE=$response');
    return InsumoChartsResponseModel.fromJson(responseAsMap(response));
  }

  @override
  Future<InsumosTipoListEntity> getInsumosTipo(
    InsumosTipoFilterEntity filter,
  ) async {
    final payload = InsumosTipoFilterRequestModel.fromEntity(filter).data;
    AppLogger.info('INSUMOS DATASOURCE: LIST TIPO PAYLOAD=$payload');

    return _offlineApiService.postCached<InsumosTipoListEntity>(
      endpoint: WSConstantes.insumosListarTipo,
      payload: payload,
      userId: filter.appUsersId,
      parser: (response) =>
          InsumosTipoListResponseModel.fromJson(responseAsMap(response)),
      missingCacheMessage:
          'Sem conexao e sem dados salvos para tipos de insumos.',
      rawResponseLog: 'INSUMOS DATASOURCE: LIST TIPO RAW RESPONSE',
    );
  }

  @override
  Future<ApiMessage> createInsumo(InsumoUpsertEntity insumo) async {
    final payload = InsumoUpsertRequestModel.fromEntity(insumo).data;
    AppLogger.info('INSUMOS DATASOURCE: CREATE PAYLOAD=$payload');

    return _offlineApiService.postOrEnqueue(
      module: 'insumos',
      action: SyncOperation.create,
      endpoint: WSConstantes.insumosAdicionar,
      payload: payload,
      priority: SyncPriority.insumos,
      pendingMessage: 'Insumo salvo localmente para sincronizar.',
      rawResponseLog: 'INSUMOS DATASOURCE: CREATE RAW RESPONSE',
      parseResponse: (response) => _parseMutationResponse(
        response,
        operationName: 'CREATE INSUMO',
        expectedSuccessMessage: 'Insumo cadastrado com sucesso',
      ),
    );
  }

  @override
  Future<ApiMessage> updateInsumo(InsumoUpsertEntity insumo) async {
    if (insumo.id == null) {
      throw ApiException('Informe o id do insumo para atualizar.');
    }

    final payload = InsumoUpsertRequestModel.fromEntity(insumo).data;
    AppLogger.info('INSUMOS DATASOURCE: UPDATE PAYLOAD=$payload');

    return _offlineApiService.postOrEnqueue(
      module: 'insumos',
      action: SyncOperation.update,
      endpoint: WSConstantes.insumosAdicionar,
      payload: payload,
      priority: SyncPriority.insumos,
      pendingMessage: 'Alteracao do insumo salva para sincronizar.',
      rawResponseLog: 'INSUMOS DATASOURCE: UPDATE RAW RESPONSE',
      parseResponse: (response) => _parseMutationResponse(
        response,
        operationName: 'UPDATE INSUMO',
        expectedSuccessMessage: 'Insumo atualizado com sucesso',
      ),
    );
  }

  @override
  Future<ApiMessage> createInsumoRegistro(
    InsumoRegistroUpsertEntity registro,
  ) async {
    final payload = InsumoRegistroUpsertRequestModel.fromEntity(registro).data;
    AppLogger.info('INSUMOS DATASOURCE: CREATE REGISTRO PAYLOAD=$payload');

    return _offlineApiService.postOrEnqueue(
      module: 'insumos',
      action: SyncOperation.create,
      endpoint: WSConstantes.insumosAdicionarRegistro,
      payload: payload,
      priority: SyncPriority.insumos,
      pendingMessage: 'Registro de insumo salvo localmente para sincronizar.',
      rawResponseLog: 'INSUMOS DATASOURCE: CREATE REGISTRO RAW RESPONSE',
      parseResponse: (response) => _parseMutationResponse(
        response,
        operationName: 'CREATE INSUMO REGISTRO',
        expectedSuccessMessage: 'Registro cadastrado com sucesso',
      ),
    );
  }

  @override
  Future<ApiMessage> updateInsumoRegistro(
    InsumoRegistroUpsertEntity registro,
  ) async {
    if (registro.id == null) {
      throw ApiException('Informe o id do registro para atualizar.');
    }

    final payload = InsumoRegistroUpsertRequestModel.fromEntity(registro).data;
    AppLogger.info('INSUMOS DATASOURCE: UPDATE REGISTRO PAYLOAD=$payload');

    return _offlineApiService.postOrEnqueue(
      module: 'insumos',
      action: SyncOperation.update,
      endpoint: WSConstantes.insumosAdicionarRegistro,
      payload: payload,
      priority: SyncPriority.insumos,
      pendingMessage: 'Alteracao do registro de insumo salva para sincronizar.',
      rawResponseLog: 'INSUMOS DATASOURCE: UPDATE REGISTRO RAW RESPONSE',
      parseResponse: (response) => _parseMutationResponse(
        response,
        operationName: 'UPDATE INSUMO REGISTRO',
        expectedSuccessMessage: 'Registro atualizado com sucesso',
      ),
    );
  }

  @override
  Future<ApiMessage> deleteInsumo(DeleteInsumoEntity insumo) async {
    final payload = DeleteInsumoRequestModel.fromEntity(insumo).data;
    AppLogger.info('INSUMOS DATASOURCE: DELETE PAYLOAD=$payload');

    return _offlineApiService.postOrEnqueue(
      module: 'insumos',
      action: SyncOperation.delete,
      endpoint: WSConstantes.insumosExcluir,
      payload: payload,
      priority: SyncPriority.insumos,
      pendingMessage: 'Exclusao do insumo salva para sincronizar.',
      rawResponseLog: 'INSUMOS DATASOURCE: DELETE RAW RESPONSE',
      parseResponse: (response) => _parseMutationResponse(
        response,
        operationName: 'DELETE INSUMO',
        expectedSuccessMessage: 'Insumo excluido com sucesso',
      ),
    );
  }

  @override
  Future<ApiMessage> deleteInsumoRegistro(DeleteInsumoEntity registro) async {
    final payload = DeleteInsumoRequestModel.fromEntity(registro).data;
    AppLogger.info('INSUMOS DATASOURCE: DELETE REGISTRO PAYLOAD=$payload');

    return _offlineApiService.postOrEnqueue(
      module: 'insumos',
      action: SyncOperation.delete,
      endpoint: WSConstantes.insumosExcluirRegistro,
      payload: payload,
      priority: SyncPriority.insumos,
      pendingMessage: 'Exclusao do registro de insumo salva para sincronizar.',
      rawResponseLog: 'INSUMOS DATASOURCE: DELETE REGISTRO RAW RESPONSE',
      parseResponse: (response) => _parseMutationResponse(
        response,
        operationName: 'DELETE INSUMO REGISTRO',
        expectedSuccessMessage: 'Registro excluido com sucesso',
      ),
    );
  }

  ApiMessage _parseMutationResponse(
    dynamic response, {
    required String operationName,
    required String expectedSuccessMessage,
  }) {
    final message = ApiMessage.fromResponse(response);
    AppLogger.success(
      'INSUMOS DATASOURCE: $operationName PARSED STATUS=${message.status} MSG=${message.message}',
    );

    if (!message.isSuccess) {
      throw ApiException(message.message);
    }

    if (message.message.trim().isEmpty) {
      return ApiMessage(
        status: message.status,
        message: expectedSuccessMessage,
      );
    }

    return message;
  }
}
