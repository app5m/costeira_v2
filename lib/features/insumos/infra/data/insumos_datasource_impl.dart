import 'package:costeira/core/api/api_client.dart';
import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/api/api_response_utils.dart';
import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/core/models/api_message.dart';
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
  const InsumosDatasourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<InsumosListEntity> getInsumos(InsumosFilterEntity filter) async {
    final payload = InsumosFilterRequestModel.fromEntity(filter).data;
    AppLogger.info('INSUMOS DATASOURCE: LIST PAYLOAD=$payload');

    final response = await _apiClient.post(
      WSConstantes.insumosListar,
      data: payload,
    );

    AppLogger.success('INSUMOS DATASOURCE: LIST RAW RESPONSE=$response');
    return InsumosListResponseModel.fromJson(responseAsMap(response));
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

    final response = await _apiClient.post(
      WSConstantes.insumosListarTipo,
      data: payload,
    );

    AppLogger.success('INSUMOS DATASOURCE: LIST TIPO RAW RESPONSE=$response');
    return InsumosTipoListResponseModel.fromJson(responseAsMap(response));
  }

  @override
  Future<ApiMessage> createInsumo(InsumoUpsertEntity insumo) async {
    final payload = InsumoUpsertRequestModel.fromEntity(insumo).data;
    AppLogger.info('INSUMOS DATASOURCE: CREATE PAYLOAD=$payload');

    final response = await _apiClient.post(
      WSConstantes.insumosAdicionar,
      data: payload,
    );

    AppLogger.success('INSUMOS DATASOURCE: CREATE RAW RESPONSE=$response');
    return _parseMutationResponse(
      response,
      operationName: 'CREATE INSUMO',
      expectedSuccessMessage: 'Insumo cadastrado com sucesso',
    );
  }

  @override
  Future<ApiMessage> updateInsumo(InsumoUpsertEntity insumo) async {
    if (insumo.id == null) {
      throw ApiException('Informe o id do insumo para atualizar.');
    }

    final payload = InsumoUpsertRequestModel.fromEntity(insumo).data;
    AppLogger.info('INSUMOS DATASOURCE: UPDATE PAYLOAD=$payload');

    final response = await _apiClient.post(
      WSConstantes.insumosAdicionar,
      data: payload,
    );

    AppLogger.success('INSUMOS DATASOURCE: UPDATE RAW RESPONSE=$response');
    return _parseMutationResponse(
      response,
      operationName: 'UPDATE INSUMO',
      expectedSuccessMessage: 'Insumo atualizado com sucesso',
    );
  }

  @override
  Future<ApiMessage> createInsumoRegistro(
    InsumoRegistroUpsertEntity registro,
  ) async {
    final payload = InsumoRegistroUpsertRequestModel.fromEntity(registro).data;
    AppLogger.info('INSUMOS DATASOURCE: CREATE REGISTRO PAYLOAD=$payload');

    final response = await _apiClient.post(
      WSConstantes.insumosAdicionarRegistro,
      data: payload,
    );

    AppLogger.success(
      'INSUMOS DATASOURCE: CREATE REGISTRO RAW RESPONSE=$response',
    );
    return _parseMutationResponse(
      response,
      operationName: 'CREATE INSUMO REGISTRO',
      expectedSuccessMessage: 'Registro cadastrado com sucesso',
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

    final response = await _apiClient.post(
      WSConstantes.insumosAdicionarRegistro,
      data: payload,
    );

    AppLogger.success(
      'INSUMOS DATASOURCE: UPDATE REGISTRO RAW RESPONSE=$response',
    );
    return _parseMutationResponse(
      response,
      operationName: 'UPDATE INSUMO REGISTRO',
      expectedSuccessMessage: 'Registro atualizado com sucesso',
    );
  }

  @override
  Future<ApiMessage> deleteInsumo(DeleteInsumoEntity insumo) async {
    final payload = DeleteInsumoRequestModel.fromEntity(insumo).data;
    AppLogger.info('INSUMOS DATASOURCE: DELETE PAYLOAD=$payload');

    final response = await _apiClient.post(
      WSConstantes.insumosExcluir,
      data: payload,
    );

    AppLogger.success('INSUMOS DATASOURCE: DELETE RAW RESPONSE=$response');
    return _parseMutationResponse(
      response,
      operationName: 'DELETE INSUMO',
      expectedSuccessMessage: 'Insumo excluido com sucesso',
    );
  }

  @override
  Future<ApiMessage> deleteInsumoRegistro(DeleteInsumoEntity registro) async {
    final payload = DeleteInsumoRequestModel.fromEntity(registro).data;
    AppLogger.info('INSUMOS DATASOURCE: DELETE REGISTRO PAYLOAD=$payload');

    final response = await _apiClient.post(
      WSConstantes.insumosExcluirRegistro,
      data: payload,
    );

    AppLogger.success(
      'INSUMOS DATASOURCE: DELETE REGISTRO RAW RESPONSE=$response',
    );
    return _parseMutationResponse(
      response,
      operationName: 'DELETE INSUMO REGISTRO',
      expectedSuccessMessage: 'Registro excluido com sucesso',
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
