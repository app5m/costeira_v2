import 'package:costeira/core/api/api_client.dart';
import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/api/api_response_utils.dart';
import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/features/movimentacoes/abigeatos/domain/entities/abigeato_upsert_entity.dart';
import 'package:costeira/features/movimentacoes/abigeatos/domain/entities/delete_abigeato_entity.dart';
import 'package:costeira/features/movimentacoes/abigeatos/domain/repository/abigeatos_datasource.dart';
import 'package:costeira/features/movimentacoes/abigeatos/infra/models/abigeato_upsert_request_model.dart';
import 'package:costeira/features/movimentacoes/abigeatos/infra/models/delete_abigeato_request_model.dart';

class AbigeatosDatasourceImpl implements AbigeatosDatasource {
  const AbigeatosDatasourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<ApiMessage> createAbigeato(AbigeatoUpsertEntity abigeato) async {
    if (abigeato.appUsersId == null) {
      throw ApiException('Usuario nao autenticado para cadastrar abigeato.');
    }

    final payload = AbigeatoUpsertRequestModel.create(abigeato).data;
    AppLogger.info('ABIGEATOS DATASOURCE: CREATE PAYLOAD=$payload');

    final response = await _apiClient.post(
      WSConstantes.movimentacoesAdicionarAbigeato,
      data: payload,
    );

    AppLogger.success('ABIGEATOS DATASOURCE: CREATE RAW RESPONSE=$response');
    return _parseMutationResponse(
      response,
      operationName: 'CREATE ABIGEATO',
      expectedSuccessMessage: 'Abigeato cadastrado com sucesso',
    );
  }

  @override
  Future<ApiMessage> updateAbigeato(AbigeatoUpsertEntity abigeato) async {
    if (abigeato.id == null) {
      throw ApiException('Informe o id do abigeato para atualizar.');
    }
    if (abigeato.appUsersId == null) {
      throw ApiException('Usuario nao autenticado para atualizar abigeato.');
    }

    final payload = AbigeatoUpsertRequestModel.update(abigeato).data;
    AppLogger.info('ABIGEATOS DATASOURCE: UPDATE PAYLOAD=$payload');

    final response = await _apiClient.post(
      WSConstantes.movimentacoesAdicionarAbigeato,
      data: payload,
    );

    AppLogger.success('ABIGEATOS DATASOURCE: UPDATE RAW RESPONSE=$response');
    return _parseMutationResponse(
      response,
      operationName: 'UPDATE ABIGEATO',
      expectedSuccessMessage: 'Abigeato atualizado com sucesso',
    );
  }

  @override
  Future<ApiMessage> deleteAbigeato(DeleteAbigeatoEntity abigeato) async {
    final payload = DeleteAbigeatoRequestModel.fromEntity(abigeato).data;
    AppLogger.info('ABIGEATOS DATASOURCE: DELETE PAYLOAD=$payload');

    final response = await _apiClient.post(
      WSConstantes.movimentacoesExcluirAbigeato,
      data: payload,
    );

    AppLogger.success('ABIGEATOS DATASOURCE: DELETE RAW RESPONSE=$response');
    return _parseMutationResponse(
      response,
      operationName: 'DELETE ABIGEATO',
      expectedSuccessMessage: 'Abigeato excluido com sucesso',
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
      AppLogger.error(
        'ABIGEATOS DATASOURCE: $operationName RETORNOU CONTRATO INVALIDO RAW=$response',
      );
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
