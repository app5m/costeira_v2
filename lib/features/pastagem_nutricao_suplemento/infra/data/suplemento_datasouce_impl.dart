import 'package:costeira/core/api/api_client.dart';
import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/api/api_response_utils.dart';
import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/core/offline/offline_api_service.dart';
import 'package:costeira/core/offline/sync/sync_operation.dart';
import 'package:costeira/core/offline/sync/sync_priority.dart';
import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/entities/suplemento.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/entities/suplemento_filter.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/entities/suplementos_list.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/repository/suplemento_datasource.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/infra/models/delete_suplemento_registro_request_model.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/infra/models/delete_suplemento_request_model.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/infra/models/suplemento_charts_filter_request_model.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/infra/models/suplemento_charts_response_model.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/infra/models/suplemento_filter_request_model.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/infra/models/suplemento_registro_upsert_request_model.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/infra/models/suplemento_upsert_request_model.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/infra/models/suplementos_list_response_model.dart';

class SuplementoDatasouceImpl implements SuplementoDatasource {
  const SuplementoDatasouceImpl(this._apiClient, this._offlineApiService);

  final ApiClient _apiClient;
  final OfflineApiService _offlineApiService;

  @override
  Future<SuplementosListEntity> getSuplementos(SuplementoFilterEntity filter) async {
    final payload = SuplementoFilterRequestModel.fromEntity(filter).data;
    AppLogger.info('SUPLEMENTACAO DATASOURCE: LIST PAYLOAD=$payload');

    return _offlineApiService.postCached<SuplementosListEntity>(
      endpoint: WSConstantes.suplementacaoListar,
      payload: payload,
      userId: filter.appUsersId,
      parser: (response) => SuplementosListResponseModel.fromJson(responseAsMap(response)),
      missingCacheMessage: 'Sem conexão e sem dados salvos para suplementacao.',
      rawResponseLog: 'SUPLEMENTACAO DATASOURCE: LIST RAW RESPONSE',
    );
  }

  @override
  Future<ApiMessage> createSuplemento(SuplementoUpsertEntity suplemento) async {
    if (suplemento.appUsersId == null) {
      throw ApiException('Usuario nao autenticado para cadastrar suplemento.');
    }

    final payload = SuplementoUpsertRequestModel.fromEntity(suplemento).data;
    AppLogger.info('SUPLEMENTACAO DATASOURCE: CREATE PAYLOAD=$payload');

    return _mutation(
      action: SyncOperation.create,
      endpoint: WSConstantes.suplementacaoAdicionar,
      payload: payload,
      pendingMessage: 'Suplementacao salva localmente para sincronizar.',
      rawResponseLog: 'SUPLEMENTACAO DATASOURCE: CREATE RESPONSE',
      operationName: 'CREATE SUPLEMENTACAO',
      expectedSuccessMessage: 'Suplementacao cadastrada com sucesso',
    );
  }

  @override
  Future<ApiMessage> updateSuplemento(SuplementoUpsertEntity suplemento) async {
    if (suplemento.id == null) {
      throw ApiException('Informe o id da suplementacao para atualizar.');
    }
    if (suplemento.appUsersId == null) {
      throw ApiException('Usuario nao autenticado para atualizar suplemento.');
    }

    final payload = SuplementoUpsertRequestModel.fromEntity(suplemento).data;
    AppLogger.info('SUPLEMENTACAO DATASOURCE: UPDATE PAYLOAD=$payload');

    return _mutation(
      action: SyncOperation.update,
      endpoint: WSConstantes.suplementacaoAdicionar,
      payload: payload,
      pendingMessage: 'Alteração da suplementacao salva para sincronizar.',
      rawResponseLog: 'SUPLEMENTACAO DATASOURCE: UPDATE RESPONSE',
      operationName: 'UPDATE SUPLEMENTACAO',
      expectedSuccessMessage: 'Suplementacao atualizada com sucesso',
    );
  }

  @override
  Future<ApiMessage> createRegistro(SuplementoRegistroUpsertEntity registro) async {
    if (registro.appUsersId == null) {
      throw ApiException('Usuario nao autenticado para cadastrar registro.');
    }

    final payload = SuplementoRegistroUpsertRequestModel.fromEntity(registro).data;
    AppLogger.info('SUPLEMENTACAO REGISTRO: CREATE PAYLOAD=$payload');

    return _mutation(
      action: SyncOperation.create,
      endpoint: WSConstantes.suplementacaoAdicionarRegistro,
      payload: payload,
      pendingMessage: 'Registro de suplementacao salvo localmente para sincronizar.',
      rawResponseLog: 'SUPLEMENTACAO REGISTRO: CREATE RESPONSE',
      operationName: 'CREATE REGISTRO SUPLEMENTACAO',
      expectedSuccessMessage: 'Registro cadastrado com sucesso',
    );
  }

  @override
  Future<ApiMessage> updateRegistro(SuplementoRegistroUpsertEntity registro) async {
    if (registro.id == null) {
      throw ApiException('Informe o id do registro para atualizar.');
    }
    if (registro.appUsersId == null) {
      throw ApiException('Usuario nao autenticado para atualizar registro.');
    }

    final payload = SuplementoRegistroUpsertRequestModel.fromEntity(registro).data;
    AppLogger.info('SUPLEMENTACAO REGISTRO: UPDATE PAYLOAD=$payload');

    return _mutation(
      action: SyncOperation.update,
      endpoint: WSConstantes.suplementacaoAdicionarRegistro,
      payload: payload,
      pendingMessage: 'Alteração do registro de suplementacao salva para sincronizar.',
      rawResponseLog: 'SUPLEMENTACAO REGISTRO: UPDATE RESPONSE',
      operationName: 'UPDATE REGISTRO SUPLEMENTACAO',
      expectedSuccessMessage: 'Registro atualizado com sucesso',
    );
  }

  @override
  Future<ApiMessage> deleteSuplemento(DeleteSuplementoEntity suplemento) async {
    final payload = DeleteSuplementoRequestModel.fromEntity(suplemento).data;
    AppLogger.info('SUPLEMENTACAO DATASOURCE: DELETE PAYLOAD=$payload');

    return _mutation(
      action: SyncOperation.delete,
      endpoint: WSConstantes.suplementacaoExcluir,
      payload: payload,
      pendingMessage: 'Exclusao da suplementacao salva para sincronizar.',
      rawResponseLog: 'SUPLEMENTACAO DATASOURCE: DELETE RESPONSE',
      operationName: 'DELETE SUPLEMENTACAO',
      expectedSuccessMessage: 'Suplementacao excluida com sucesso',
    );
  }

  @override
  Future<ApiMessage> deleteRegistro(DeleteSuplementoRegistroEntity registro) async {
    final payload = DeleteSuplementoRegistroRequestModel.fromEntity(registro).data;
    AppLogger.info('SUPLEMENTACAO REGISTRO: DELETE PAYLOAD=$payload');

    return _mutation(
      action: SyncOperation.delete,
      endpoint: WSConstantes.suplementacaoExcluirRegistro,
      payload: payload,
      pendingMessage: 'Exclusao do registro de suplementacao salva para sincronizar.',
      rawResponseLog: 'SUPLEMENTACAO REGISTRO: DELETE RESPONSE',
      operationName: 'DELETE REGISTRO SUPLEMENTACAO',
      expectedSuccessMessage: 'Registro excluido com sucesso',
    );
  }

  @override
  Future<SuplementoChartsEntity> getCharts(SuplementoChartsFilterEntity filter) async {
    final payload = SuplementoChartsFilterRequestModel.fromEntity(filter).data;
    AppLogger.info('SUPLEMENTACAO CHARTS: PAYLOAD=$payload');

    final response = await _apiClient.post(WSConstantes.suplementacaoGraficos, data: payload);
    AppLogger.success('SUPLEMENTACAO CHARTS: RESPONSE=$response');

    final wrapper = responseAsMap(response);
    final dataList = wrapper['data'] as List<dynamic>? ?? const [];
    final first = dataList.whereType<Map>().cast<Map>().firstOrNull;

    if (first == null) {
      return SuplementoChartsEntity.empty;
    }

    return SuplementoChartsResponseModel.fromJson(Map<String, dynamic>.from(first));
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
      module: 'pastagem_nutricao_suplemento',
      action: action,
      endpoint: endpoint,
      payload: payload,
      priority: SyncPriority.pastagemNutricaoSuplemento,
      pendingMessage: pendingMessage,
      rawResponseLog: rawResponseLog,
      parseResponse: (response) => _parseMutationResponse(
        response,
        operationName: operationName,
        expectedSuccessMessage: expectedSuccessMessage,
      ),
    );
  }

  ApiMessage _parseMutationResponse(
    dynamic response, {
    required String operationName,
    required String expectedSuccessMessage,
  }) {
    final map = responseAsMap(response);
    final hasMutationContract = map.containsKey('status') || map.containsKey('msg');

    if (!hasMutationContract) {
      throw ApiException(
        'Resposta inesperada da API ao executar $operationName. '
        'Esperado status/msg, recebido: $response',
      );
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
