import 'package:costeira/core/api/api_client.dart';
import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/api/api_response_utils.dart';
import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/features/movimentacoes/troca_categoria/domain/entities/delete_troca_categoria_entity.dart';
import 'package:costeira/features/movimentacoes/troca_categoria/domain/entities/troca_categoria_upsert_entity.dart';
import 'package:costeira/features/movimentacoes/troca_categoria/domain/repository/troca_categoria_datasource.dart';
import 'package:costeira/features/movimentacoes/troca_categoria/infra/models/delete_troca_categoria_request_model.dart';
import 'package:costeira/features/movimentacoes/troca_categoria/infra/models/troca_categoria_upsert_request_model.dart';

class TrocaCategoriaDatasourceImpl implements TrocaCategoriaDatasource {
  const TrocaCategoriaDatasourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<ApiMessage> createTrocaCategoria(
    TrocaCategoriaUpsertEntity troca,
  ) async {
    if (troca.appUsersId == null) {
      throw ApiException('Usuario nao autenticado para cadastrar troca.');
    }

    final payload = TrocaCategoriaUpsertRequestModel.create(troca).data;
    AppLogger.info('TROCA CATEGORIA DATASOURCE: CREATE PAYLOAD=$payload');

    final response = await _apiClient.post(
      WSConstantes.movimentacoesAdicionarTrocaCategoria,
      data: payload,
    );

    return _parseMutationResponse(
      response,
      operationName: 'CREATE TROCA CATEGORIA',
      expectedSuccessMessage: 'Troca de categoria cadastrada com sucesso',
    );
  }

  @override
  Future<ApiMessage> updateTrocaCategoria(
    TrocaCategoriaUpsertEntity troca,
  ) async {
    if (troca.id == null) {
      throw ApiException('Informe o id da troca para atualizar.');
    }
    if (troca.appUsersId == null) {
      throw ApiException('Usuario nao autenticado para atualizar troca.');
    }

    final payload = TrocaCategoriaUpsertRequestModel.update(troca).data;
    AppLogger.info('TROCA CATEGORIA DATASOURCE: UPDATE PAYLOAD=$payload');

    final response = await _apiClient.post(
      WSConstantes.movimentacoesAdicionarTrocaCategoria,
      data: payload,
    );

    return _parseMutationResponse(
      response,
      operationName: 'UPDATE TROCA CATEGORIA',
      expectedSuccessMessage: 'Troca de categoria atualizada com sucesso',
    );
  }

  @override
  Future<ApiMessage> deleteTrocaCategoria(
    DeleteTrocaCategoriaEntity troca,
  ) async {
    final payload = DeleteTrocaCategoriaRequestModel.fromEntity(troca).data;
    AppLogger.info('TROCA CATEGORIA DATASOURCE: DELETE PAYLOAD=$payload');

    final response = await _apiClient.post(
      WSConstantes.movimentacoesExcluirTrocaCategoria,
      data: payload,
    );

    return _parseMutationResponse(
      response,
      operationName: 'DELETE TROCA CATEGORIA',
      expectedSuccessMessage: 'Troca de categoria excluida com sucesso',
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
