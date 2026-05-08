import 'package:costeira/core/api/api_client.dart';
import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/api/api_response_utils.dart';
import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/entities/manejo.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/entities/manejo_filter.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/entities/manejos_list.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/repository/manejo_datasource.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/infra/models/delete_manejo_request_model.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/infra/models/manejo_charts_filter_request_model.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/infra/models/manejo_charts_response_model.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/infra/models/manejo_filter_request_model.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/infra/models/manejo_upsert_request_model.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/infra/models/manejos_list_response_model.dart';

class ManejoDataSourceImpl implements ManejoDataSource {
  const ManejoDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<ManejosListEntity> getManejos(ManejoFilterEntity filter) async {
    final payload = ManejoFilterRequestModel.fromEntity(filter).data;
    AppLogger.info('MANEJO DATASOURCE: LIST PAYLOAD=$payload');

    final response = await _apiClient.post(
      WSConstantes.pastagensListar,
      data: payload,
    );
    AppLogger.success('MANEJO DATASOURCE: LIST RAW RESPONSE=$response');

    return ManejosListResponseModel.fromJson(responseAsMap(response));
  }

  @override
  Future<ApiMessage> createManejo(ManejoUpsertEntity manejo) async {
    if (manejo.appUsersId == null) {
      throw ApiException('Usuario nao autenticado para cadastrar manejo.');
    }

    final payload = ManejoUpsertRequestModel.fromEntity(manejo).data;
    AppLogger.info('MANEJO DATASOURCE: CREATE PAYLOAD=$payload');

    final response = await _apiClient.post(
      WSConstantes.pastagensAdicionar,
      data: payload,
    );
    AppLogger.success('MANEJO DATASOURCE: CREATE RESPONSE=$response');

    return _parseMutationResponse(
      response,
      operationName: 'CREATE MANEJO',
      expectedSuccessMessage: 'Pastagem cadastrada com sucesso',
    );
  }

  @override
  Future<ApiMessage> updateManejo(ManejoUpsertEntity manejo) async {
    if (manejo.id == null) {
      throw ApiException('Informe o id do manejo para atualizar.');
    }
    if (manejo.appUsersId == null) {
      throw ApiException('Usuario nao autenticado para atualizar manejo.');
    }

    final payload = ManejoUpsertRequestModel.fromEntity(manejo).data;
    AppLogger.info('MANEJO DATASOURCE: UPDATE PAYLOAD=$payload');

    final response = await _apiClient.post(
      WSConstantes.pastagensAdicionar,
      data: payload,
    );
    AppLogger.success('MANEJO DATASOURCE: UPDATE RESPONSE=$response');

    return _parseMutationResponse(
      response,
      operationName: 'UPDATE MANEJO',
      expectedSuccessMessage: 'Pastagem atualizada com sucesso',
    );
  }

  @override
  Future<ApiMessage> deleteManejo(DeleteManejoEntity manejo) async {
    final payload = DeleteManejoRequestModel.fromEntity(manejo).data;
    AppLogger.info('MANEJO DATASOURCE: DELETE PAYLOAD=$payload');

    final response = await _apiClient.post(
      WSConstantes.pastagensExcluir,
      data: payload,
    );
    AppLogger.success('MANEJO DATASOURCE: DELETE RESPONSE=$response');

    return _parseMutationResponse(
      response,
      operationName: 'DELETE MANEJO',
      expectedSuccessMessage: 'Pastagem excluida com sucesso',
    );
  }

  @override
  Future<ManejoChartsEntity> getCharts(ManejoChartsFilterEntity filter) async {
    final payload = ManejoChartsFilterRequestModel.fromEntity(filter).data;
    AppLogger.info('MANEJO CHARTS: PAYLOAD=$payload');

    final response = await _apiClient.post(
      WSConstantes.pastagensGraficos,
      data: payload,
    );
    AppLogger.success('MANEJO CHARTS: RESPONSE=$response');

    final wrapper = responseAsMap(response);
    final dataList = wrapper['data'] as List<dynamic>? ?? const [];
    final first = dataList.whereType<Map>().cast<Map>().firstOrNull;

    if (first == null) {
      return ManejoChartsEntity.empty;
    }

    return ManejoChartsResponseModel.fromJson(Map<String, dynamic>.from(first));
  }

  ApiMessage _parseMutationResponse(
    dynamic response, {
    required String operationName,
    required String expectedSuccessMessage,
  }) {
    final map = responseAsMap(response);
    final hasMutationContract =
        map.containsKey('status') || map.containsKey('msg');

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
      return ApiMessage(
        status: message.status,
        message: expectedSuccessMessage,
      );
    }

    return message;
  }
}
