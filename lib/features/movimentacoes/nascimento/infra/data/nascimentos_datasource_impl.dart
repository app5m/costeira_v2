import 'package:costeira/core/api/api_client.dart';
import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/api/api_response_utils.dart';
import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/features/movimentacoes/nascimento/domain/entities/delete_nascimento_entity.dart';
import 'package:costeira/features/movimentacoes/nascimento/domain/entities/nascimento_upsert_entity.dart';
import 'package:costeira/features/movimentacoes/nascimento/domain/repository/nascimentos_datasource.dart';
import 'package:costeira/features/movimentacoes/nascimento/infra/models/delete_nascimento_request_model.dart';
import 'package:costeira/features/movimentacoes/nascimento/infra/models/nascimento_upsert_request_model.dart';

class NascimentosDatasourceImpl implements NascimentosDatasource {
  const NascimentosDatasourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<ApiMessage> createNascimento(NascimentoUpsertEntity nascimento) async {
    if (nascimento.appUsersId == null) {
      throw ApiException('Usuario nao autenticado para cadastrar nascimento.');
    }
    if (nascimento.animais.length != 2) {
      throw ApiException('O nascimento deve conter uma matriz e um terneiro.');
    }

    final payload = NascimentoUpsertRequestModel.create(nascimento).data;
    AppLogger.info('NASCIMENTOS DATASOURCE: CREATE PAYLOAD=$payload');

    final response = await _apiClient.post(
      WSConstantes.movimentacoesAdicionarNascimento,
      data: payload,
    );

    AppLogger.success('NASCIMENTOS DATASOURCE: CREATE RAW RESPONSE=$response');
    return _parseMutationResponse(
      response,
      operationName: 'CREATE NASCIMENTO',
      expectedSuccessMessage: 'Nascimento cadastrado com sucesso',
    );
  }

  @override
  Future<ApiMessage> updateNascimento(NascimentoUpsertEntity nascimento) async {
    if (nascimento.id == null) {
      throw ApiException('Informe o id do nascimento para atualizar.');
    }
    if (nascimento.appUsersId == null) {
      throw ApiException('Usuario nao autenticado para atualizar nascimento.');
    }

    final payload = NascimentoUpsertRequestModel.update(nascimento).data;
    AppLogger.info('NASCIMENTOS DATASOURCE: UPDATE PAYLOAD=$payload');

    final response = await _apiClient.post(
      WSConstantes.movimentacoesAdicionarNascimento,
      data: payload,
    );

    AppLogger.success('NASCIMENTOS DATASOURCE: UPDATE RAW RESPONSE=$response');
    return _parseMutationResponse(
      response,
      operationName: 'UPDATE NASCIMENTO',
      expectedSuccessMessage: 'Nascimento atualizado com sucesso',
    );
  }

  @override
  Future<ApiMessage> deleteNascimento(DeleteNascimentoEntity nascimento) async {
    final payload = DeleteNascimentoRequestModel.fromEntity(nascimento).data;
    AppLogger.info('NASCIMENTOS DATASOURCE: DELETE PAYLOAD=$payload');

    final response = await _apiClient.post(
      WSConstantes.movimentacoesExcluirNascimento,
      data: payload,
    );

    AppLogger.success('NASCIMENTOS DATASOURCE: DELETE RAW RESPONSE=$response');
    return _parseMutationResponse(
      response,
      operationName: 'DELETE NASCIMENTO',
      expectedSuccessMessage: 'Nascimento excluido com sucesso',
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
        'NASCIMENTOS DATASOURCE: $operationName RETORNOU CONTRATO INVALIDO RAW=$response',
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
