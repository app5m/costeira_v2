import 'package:costeira/core/api/api_client.dart';
import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/api/api_response_utils.dart';
import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/features/movimentacoes/compras/domain/entities/compra_upsert_entity.dart';
import 'package:costeira/features/movimentacoes/compras/domain/entities/delete_compra_entity.dart';
import 'package:costeira/features/movimentacoes/compras/domain/repository/compras_datasource.dart';
import 'package:costeira/features/movimentacoes/compras/infra/models/compra_upsert_request_model.dart';
import 'package:costeira/features/movimentacoes/compras/infra/models/delete_compra_request_model.dart';

class ComprasDatasourceImpl implements ComprasDatasource {
  const ComprasDatasourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<ApiMessage> createCompra(CompraUpsertEntity compra) async {
    if (compra.appUsersId == null) {
      throw ApiException('Usuario nao autenticado para cadastrar compra.');
    }

    final payload = CompraUpsertRequestModel.create(compra).data;
    AppLogger.info('COMPRAS DATASOURCE: CREATE PAYLOAD=$payload');

    final response = await _apiClient.post(
      WSConstantes.movimentacoesAdicionarCompra,
      data: payload,
    );

    AppLogger.success('COMPRAS DATASOURCE: CREATE RAW RESPONSE=$response');
    return _parseMutationResponse(
      response,
      operationName: 'CREATE COMPRA',
      expectedSuccessMessage: 'Compra cadastrada com sucesso',
    );
  }

  @override
  Future<ApiMessage> updateCompra(CompraUpsertEntity compra) async {
    if (compra.id == null) {
      throw ApiException('Informe o id da compra para atualizar.');
    }
    if (compra.appUsersId == null) {
      throw ApiException('Usuario nao autenticado para atualizar compra.');
    }

    final payload = CompraUpsertRequestModel.update(compra).data;
    AppLogger.info('COMPRAS DATASOURCE: UPDATE PAYLOAD=$payload');

    final response = await _apiClient.post(
      WSConstantes.movimentacoesAdicionarCompra,
      data: payload,
    );

    AppLogger.success('COMPRAS DATASOURCE: UPDATE RAW RESPONSE=$response');
    return _parseMutationResponse(
      response,
      operationName: 'UPDATE COMPRA',
      expectedSuccessMessage: 'Compra atualizada com sucesso',
    );
  }

  @override
  Future<ApiMessage> deleteCompra(DeleteCompraEntity compra) async {
    final payload = DeleteCompraRequestModel.fromEntity(compra).data;
    AppLogger.info('COMPRAS DATASOURCE: DELETE PAYLOAD=$payload');

    final response = await _apiClient.post(
      WSConstantes.movimentacoesExcluirCompra,
      data: payload,
    );

    AppLogger.success('COMPRAS DATASOURCE: DELETE RAW RESPONSE=$response');
    return _parseMutationResponse(
      response,
      operationName: 'DELETE COMPRA',
      expectedSuccessMessage: 'Compra excluida com sucesso',
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
        'COMPRAS DATASOURCE: $operationName RETORNOU CONTRATO INVALIDO RAW=$response',
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
