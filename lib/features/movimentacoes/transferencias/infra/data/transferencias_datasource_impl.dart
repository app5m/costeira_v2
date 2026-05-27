import 'package:costeira/core/api/api_client.dart';
import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/api/api_response_utils.dart';
import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/features/movimentacoes/transferencias/domain/entities/delete_transferencia_entity.dart';
import 'package:costeira/features/movimentacoes/transferencias/domain/entities/transferencia_upsert_entity.dart';
import 'package:costeira/features/movimentacoes/transferencias/domain/repository/transferencias_datasource.dart';
import 'package:costeira/features/movimentacoes/transferencias/infra/models/delete_transferencia_request_model.dart';
import 'package:costeira/features/movimentacoes/transferencias/infra/models/transferencia_upsert_request_model.dart';

class TransferenciasDatasourceImpl implements TransferenciasDatasource {
  const TransferenciasDatasourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<ApiMessage> createTransferencia(
    TransferenciaUpsertEntity transferencia,
  ) async {
    if (transferencia.appUsersId == null) {
      throw ApiException(
        'Usuario nao autenticado para cadastrar transferencia.',
      );
    }

    final payload = TransferenciaUpsertRequestModel.create(transferencia).data;
    AppLogger.info('TRANSFERENCIAS DATASOURCE: CREATE PAYLOAD=$payload');

    final response = await _apiClient.post(
      WSConstantes.movimentacoesAdicionarTransferencia,
      data: payload,
    );

    AppLogger.success(
      'TRANSFERENCIAS DATASOURCE: CREATE RAW RESPONSE=$response',
    );
    return _parseMutationResponse(
      response,
      operationName: 'CREATE TRANSFERENCIA',
      expectedSuccessMessage: 'Transferencia cadastrada com sucesso',
    );
  }

  @override
  Future<ApiMessage> updateTransferencia(
    TransferenciaUpsertEntity transferencia,
  ) async {
    if (transferencia.id == null) {
      throw ApiException('Informe o id da transferencia para atualizar.');
    }
    if (transferencia.appUsersId == null) {
      throw ApiException(
        'Usuario nao autenticado para atualizar transferencia.',
      );
    }

    final payload = TransferenciaUpsertRequestModel.update(transferencia).data;
    AppLogger.info('TRANSFERENCIAS DATASOURCE: UPDATE PAYLOAD=$payload');

    final response = await _apiClient.post(
      WSConstantes.movimentacoesAdicionarTransferencia,
      data: payload,
    );

    AppLogger.success(
      'TRANSFERENCIAS DATASOURCE: UPDATE RAW RESPONSE=$response',
    );
    return _parseMutationResponse(
      response,
      operationName: 'UPDATE TRANSFERENCIA',
      expectedSuccessMessage: 'Transferencia atualizada com sucesso',
    );
  }

  @override
  Future<ApiMessage> deleteTransferencia(
    DeleteTransferenciaEntity transferencia,
  ) async {
    final payload = DeleteTransferenciaRequestModel.fromEntity(
      transferencia,
    ).data;
    AppLogger.info('TRANSFERENCIAS DATASOURCE: DELETE PAYLOAD=$payload');

    final response = await _apiClient.post(
      WSConstantes.movimentacoesExcluirTransferencia,
      data: payload,
    );

    AppLogger.success(
      'TRANSFERENCIAS DATASOURCE: DELETE RAW RESPONSE=$response',
    );
    return _parseMutationResponse(
      response,
      operationName: 'DELETE TRANSFERENCIA',
      expectedSuccessMessage: 'Transferencia excluida com sucesso',
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
        'TRANSFERENCIAS DATASOURCE: $operationName RETORNOU CONTRATO INVALIDO RAW=$response',
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
