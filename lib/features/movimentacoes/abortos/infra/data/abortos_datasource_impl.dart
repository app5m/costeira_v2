import 'package:costeira/core/api/api_client.dart';
import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/api/api_response_utils.dart';
import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/features/movimentacoes/abortos/domain/entities/aborto_upsert_entity.dart';
import 'package:costeira/features/movimentacoes/abortos/domain/entities/delete_aborto_entity.dart';
import 'package:costeira/features/movimentacoes/abortos/domain/repository/abortos_datasource.dart';
import 'package:costeira/features/movimentacoes/abortos/infra/models/aborto_upsert_request_model.dart';
import 'package:costeira/features/movimentacoes/abortos/infra/models/delete_aborto_request_model.dart';

class AbortosDatasourceImpl implements AbortosDatasource {
  const AbortosDatasourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<ApiMessage> createAborto(AbortoUpsertEntity aborto) async {
    if (aborto.appUsersId == null) {
      throw ApiException('Usuario nao autenticado para cadastrar aborto.');
    }

    final payload = AbortoUpsertRequestModel.create(aborto).data;
    AppLogger.info('ABORTOS DATASOURCE: CREATE PAYLOAD=$payload');

    final response = await _apiClient.post(
      WSConstantes.movimentacoesAdicionarAborto,
      data: payload,
    );

    AppLogger.success('ABORTOS DATASOURCE: CREATE RAW RESPONSE=$response');
    return _parseMutationResponse(
      response,
      operationName: 'CREATE ABORTO',
      expectedSuccessMessage: 'Aborto cadastrado com sucesso',
    );
  }

  @override
  Future<ApiMessage> updateAborto(AbortoUpsertEntity aborto) async {
    if (aborto.id == null) {
      throw ApiException('Informe o id do aborto para atualizar.');
    }
    if (aborto.appUsersId == null) {
      throw ApiException('Usuario nao autenticado para atualizar aborto.');
    }

    final payload = AbortoUpsertRequestModel.update(aborto).data;
    AppLogger.info('ABORTOS DATASOURCE: UPDATE PAYLOAD=$payload');

    final response = await _apiClient.post(
      WSConstantes.movimentacoesAdicionarAborto,
      data: payload,
    );

    AppLogger.success('ABORTOS DATASOURCE: UPDATE RAW RESPONSE=$response');
    return _parseMutationResponse(
      response,
      operationName: 'UPDATE ABORTO',
      expectedSuccessMessage: 'Aborto atualizado com sucesso',
    );
  }

  @override
  Future<ApiMessage> deleteAborto(DeleteAbortoEntity aborto) async {
    final payload = DeleteAbortoRequestModel.fromEntity(aborto).data;
    AppLogger.info('ABORTOS DATASOURCE: DELETE PAYLOAD=$payload');

    final response = await _apiClient.post(
      WSConstantes.movimentacoesExcluirAborto,
      data: payload,
    );

    AppLogger.success('ABORTOS DATASOURCE: DELETE RAW RESPONSE=$response');
    return _parseMutationResponse(
      response,
      operationName: 'DELETE ABORTO',
      expectedSuccessMessage: 'Aborto excluido com sucesso',
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
