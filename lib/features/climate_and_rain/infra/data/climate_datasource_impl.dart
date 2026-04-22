import 'package:costeira/core/api/api_client.dart';
import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/api/api_response_utils.dart';
import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/features/climate_and_rain/domain/entities/climate_charts_entity.dart';
import 'package:costeira/features/climate_and_rain/domain/entities/climate_charts_filter_entity.dart';
import 'package:costeira/features/climate_and_rain/domain/entities/climate_filter_entity.dart';
import 'package:costeira/features/climate_and_rain/domain/entities/climate_list_entity.dart';
import 'package:costeira/features/climate_and_rain/domain/entities/climate_upsert_entity.dart';
import 'package:costeira/features/climate_and_rain/domain/entities/delete_climate_entity.dart';
import 'package:costeira/features/climate_and_rain/domain/repository/climate_datasource.dart';
import 'package:costeira/features/climate_and_rain/infra/models/climate_charts_filter_request_model.dart';
import 'package:costeira/features/climate_and_rain/infra/models/climate_charts_response_model.dart';
import 'package:costeira/features/climate_and_rain/infra/models/climate_filter_request_model.dart';
import 'package:costeira/features/climate_and_rain/infra/models/climate_list_response_model.dart';
import 'package:costeira/features/climate_and_rain/infra/models/climate_upsert_request_model.dart';
import 'package:costeira/features/climate_and_rain/infra/models/delete_climate_request_model.dart';

class ClimateDatasourceImpl implements ClimateDatasource {
  const ClimateDatasourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<ClimateListEntity> getClimates(ClimateFilterEntity filter) async {
    final payload = ClimateFilterRequestModel.fromEntity(filter).data;
    AppLogger.info('CLIMATE DATASOURCE: LIST PAYLOAD=$payload');

    final response = await _apiClient.post(
      WSConstantes.climasListar,
      data: payload,
    );
    AppLogger.success('CLIMATE DATASOURCE: LIST RAW RESPONSE=$response');

    return ClimateListResponseModel.fromJson(responseAsMap(response));
  }

  @override
  Future<ApiMessage> createClimate(ClimateUpsertEntity climate) async {
    if (climate.appUsersId == null) {
      throw ApiException('Usuario nao autenticado para cadastrar clima.');
    }

    final payload = ClimateUpsertRequestModel.create(climate).data;
    AppLogger.info('CLIMATE DATASOURCE: CREATE PAYLOAD=$payload');

    final response = await _apiClient.post(
      WSConstantes.climasAdd,
      data: payload,
    );
    AppLogger.success('CLIMATE DATASOURCE: CREATE RAW RESPONSE=$response');

    return _parseMutationResponse(
      response,
      operationName: 'CREATE CLIMATE',
      expectedSuccessMessage: 'Clima cadastrado com sucesso',
    );
  }

  @override
  Future<ApiMessage> updateClimate(ClimateUpsertEntity climate) async {
    if (climate.id == null) {
      throw ApiException('Informe o id do clima para atualizar.');
    }
    if (climate.appUsersId == null) {
      throw ApiException('Usuario nao autenticado para atualizar clima.');
    }

    final payload = ClimateUpsertRequestModel.update(climate).data;
    AppLogger.info('CLIMATE DATASOURCE: UPDATE PAYLOAD=$payload');

    final response = await _apiClient.post(
      WSConstantes.climasAdd,
      data: payload,
    );
    AppLogger.success('CLIMATE DATASOURCE: UPDATE RAW RESPONSE=$response');

    return _parseMutationResponse(
      response,
      operationName: 'UPDATE CLIMATE',
      expectedSuccessMessage: 'Clima atualizado com sucesso',
    );
  }

  @override
  Future<ApiMessage> deleteClimate(DeleteClimateEntity climate) async {
    final payload = DeleteClimateRequestModel.fromEntity(climate).data;
    AppLogger.info('CLIMATE DATASOURCE: DELETE PAYLOAD=$payload');

    final response = await _apiClient.post(
      WSConstantes.climasExcluir,
      data: payload,
    );
    AppLogger.success('CLIMATE DATASOURCE: DELETE RAW RESPONSE=$response');

    return _parseMutationResponse(
      response,
      operationName: 'DELETE CLIMATE',
      expectedSuccessMessage: 'Clima excluido com sucesso',
    );
  }

  @override
  Future<ClimateChartsEntity> getClimateCharts(
    ClimateChartsFilterEntity filter,
  ) async {
    final payload = ClimateChartsFilterRequestModel.fromEntity(filter).data;
    AppLogger.info('CLIMATE DATASOURCE: CHARTS PAYLOAD=$payload');

    final response = await _apiClient.post(
      WSConstantes.climasGraficos,
      data: payload,
    );
    AppLogger.success('CLIMATE DATASOURCE: CHARTS RAW RESPONSE=$response');

    final wrapper = responseAsMap(response);
    final dataList = wrapper['data'] as List<dynamic>? ?? const [];
    final first = dataList.whereType<Map>().cast<Map>().firstOrNull;

    if (first == null) {
      return const ClimateChartsEntity(
        totalChuvaAcumulada: 0,
        totalChuvaUltimoMes: 0,
        chuvaMesAMes: [],
        comparativoUltimos2Anos: [],
      );
    }

    return ClimateChartsResponseModel.fromJson(
      Map<String, dynamic>.from(first),
    );
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
    AppLogger.success(
      'CLIMATE DATASOURCE: $operationName PARSED STATUS=${message.status} MSG=${message.message}',
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
