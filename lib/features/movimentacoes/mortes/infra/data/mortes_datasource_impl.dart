import 'package:costeira/core/api/api_client.dart';
import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/api/api_response_utils.dart';
import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/features/movimentacoes/mortes/domain/entities/delete_morte_entity.dart';
import 'package:costeira/features/movimentacoes/mortes/domain/entities/morte_upsert_entity.dart';
import 'package:costeira/features/movimentacoes/mortes/domain/repository/mortes_datasource.dart';
import 'package:costeira/features/movimentacoes/mortes/infra/models/delete_morte_request_model.dart';
import 'package:costeira/features/movimentacoes/mortes/infra/models/morte_upsert_request_model.dart';

class MortesDatasourceImpl implements MortesDatasource {
  const MortesDatasourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<ApiMessage> createMorte(MorteUpsertEntity morte) async {
    if (morte.appUsersId == null) {
      throw ApiException('Usuario nao autenticado para cadastrar morte.');
    }

    final payload = MorteUpsertRequestModel.create(morte).data;
    AppLogger.info('MORTES DATASOURCE: CREATE PAYLOAD=$payload');

    final response = await _apiClient.post(
      WSConstantes.movimentacoesAdicionarMorte,
      data: payload,
    );

    AppLogger.success('MORTES DATASOURCE: CREATE RAW RESPONSE=$response');
    return _parseMutationResponse(
      response,
      operationName: 'CREATE MORTE',
      expectedSuccessMessage: 'Morte cadastrada com sucesso',
    );
  }

  @override
  Future<ApiMessage> updateMorte(MorteUpsertEntity morte) async {
    if (morte.id == null) {
      throw ApiException('Informe o id da morte para atualizar.');
    }
    if (morte.appUsersId == null) {
      throw ApiException('Usuario nao autenticado para atualizar morte.');
    }

    final payload = MorteUpsertRequestModel.update(morte).data;
    AppLogger.info('MORTES DATASOURCE: UPDATE PAYLOAD=$payload');

    final response = await _apiClient.post(
      WSConstantes.movimentacoesAdicionarMorte,
      data: payload,
    );

    AppLogger.success('MORTES DATASOURCE: UPDATE RAW RESPONSE=$response');
    return _parseMutationResponse(
      response,
      operationName: 'UPDATE MORTE',
      expectedSuccessMessage: 'Morte atualizada com sucesso',
    );
  }

  @override
  Future<ApiMessage> deleteMorte(DeleteMorteEntity morte) async {
    final payload = DeleteMorteRequestModel.fromEntity(morte).data;
    AppLogger.info('MORTES DATASOURCE: DELETE PAYLOAD=$payload');

    final response = await _apiClient.post(
      WSConstantes.movimentacoesExcluirMorte,
      data: payload,
    );

    AppLogger.success('MORTES DATASOURCE: DELETE RAW RESPONSE=$response');
    return _parseMutationResponse(
      response,
      operationName: 'DELETE MORTE',
      expectedSuccessMessage: 'Morte excluida com sucesso',
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
