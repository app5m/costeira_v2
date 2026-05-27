import 'package:costeira/core/api/api_client.dart';
import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/api/api_response_utils.dart';
import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/features/movimentacoes/consumo/domain/entities/consumo_upsert_entity.dart';
import 'package:costeira/features/movimentacoes/consumo/domain/entities/delete_consumo_entity.dart';
import 'package:costeira/features/movimentacoes/consumo/domain/repository/consumos_datasource.dart';
import 'package:costeira/features/movimentacoes/consumo/infra/models/consumo_upsert_request_model.dart';
import 'package:costeira/features/movimentacoes/consumo/infra/models/delete_consumo_request_model.dart';

class ConsumosDatasourceImpl implements ConsumosDatasource {
  const ConsumosDatasourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<ApiMessage> createConsumo(ConsumoUpsertEntity consumo) async {
    if (consumo.appUsersId == null) {
      throw ApiException('Usuario nao autenticado para cadastrar consumo.');
    }

    final payload = ConsumoUpsertRequestModel.create(consumo).data;
    AppLogger.info('CONSUMOS DATASOURCE: CREATE PAYLOAD=$payload');

    final response = await _apiClient.post(
      WSConstantes.movimentacoesAdicionarConsumo,
      data: payload,
    );

    AppLogger.success('CONSUMOS DATASOURCE: CREATE RAW RESPONSE=$response');
    return _parseMutationResponse(
      response,
      operationName: 'CREATE CONSUMO',
      expectedSuccessMessage: 'Consumo cadastrado com sucesso',
    );
  }

  @override
  Future<ApiMessage> updateConsumo(ConsumoUpsertEntity consumo) async {
    if (consumo.id == null) {
      throw ApiException('Informe o id do consumo para atualizar.');
    }
    if (consumo.appUsersId == null) {
      throw ApiException('Usuario nao autenticado para atualizar consumo.');
    }

    final payload = ConsumoUpsertRequestModel.update(consumo).data;
    AppLogger.info('CONSUMOS DATASOURCE: UPDATE PAYLOAD=$payload');

    final response = await _apiClient.post(
      WSConstantes.movimentacoesAdicionarConsumo,
      data: payload,
    );

    AppLogger.success('CONSUMOS DATASOURCE: UPDATE RAW RESPONSE=$response');
    return _parseMutationResponse(
      response,
      operationName: 'UPDATE CONSUMO',
      expectedSuccessMessage: 'Consumo atualizado com sucesso',
    );
  }

  @override
  Future<ApiMessage> deleteConsumo(DeleteConsumoEntity consumo) async {
    final payload = DeleteConsumoRequestModel.fromEntity(consumo).data;
    AppLogger.info('CONSUMOS DATASOURCE: DELETE PAYLOAD=$payload');

    final response = await _apiClient.post(
      WSConstantes.movimentacoesExcluirConsumo,
      data: payload,
    );

    AppLogger.success('CONSUMOS DATASOURCE: DELETE RAW RESPONSE=$response');
    return _parseMutationResponse(
      response,
      operationName: 'DELETE CONSUMO',
      expectedSuccessMessage: 'Consumo excluido com sucesso',
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
        'Resposta inesperada da API ao executar $operationName.',
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
