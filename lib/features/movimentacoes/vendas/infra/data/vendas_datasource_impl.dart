import 'package:costeira/core/api/api_client.dart';
import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/api/api_response_utils.dart';
import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/features/movimentacoes/vendas/domain/entities/delete_venda_entity.dart';
import 'package:costeira/features/movimentacoes/vendas/domain/entities/venda_upsert_entity.dart';
import 'package:costeira/features/movimentacoes/vendas/domain/repository/vendas_datasource.dart';
import 'package:costeira/features/movimentacoes/vendas/infra/models/delete_venda_request_model.dart';
import 'package:costeira/features/movimentacoes/vendas/infra/models/venda_upsert_request_model.dart';

class VendasDatasourceImpl implements VendasDatasource {
  const VendasDatasourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<ApiMessage> createVenda(VendaUpsertEntity venda) async {
    if (venda.appUsersId == null) {
      throw ApiException('Usuario nao autenticado para cadastrar venda.');
    }

    final payload = VendaUpsertRequestModel.create(venda).data;
    AppLogger.info('VENDAS DATASOURCE: CREATE PAYLOAD=$payload');

    final response = await _apiClient.post(
      WSConstantes.movimentacoesAdicionarVenda,
      data: payload,
    );

    AppLogger.success('VENDAS DATASOURCE: CREATE RAW RESPONSE=$response');
    return _parseMutationResponse(
      response,
      operationName: 'CREATE VENDA',
      expectedSuccessMessage: 'Venda executada com sucesso',
    );
  }

  @override
  Future<ApiMessage> updateVenda(VendaUpsertEntity venda) async {
    if (venda.id == null) {
      throw ApiException('Informe o id da venda para atualizar.');
    }
    if (venda.appUsersId == null) {
      throw ApiException('Usuario nao autenticado para atualizar venda.');
    }

    final payload = VendaUpsertRequestModel.update(venda).data;
    AppLogger.info('VENDAS DATASOURCE: UPDATE PAYLOAD=$payload');

    final response = await _apiClient.post(
      WSConstantes.movimentacoesAdicionarVenda,
      data: payload,
    );

    AppLogger.success('VENDAS DATASOURCE: UPDATE RAW RESPONSE=$response');
    return _parseMutationResponse(
      response,
      operationName: 'UPDATE VENDA',
      expectedSuccessMessage: 'Venda atualizada com sucesso',
    );
  }

  @override
  Future<ApiMessage> deleteVenda(DeleteVendaEntity venda) async {
    final payload = DeleteVendaRequestModel.fromEntity(venda).data;
    AppLogger.info('VENDAS DATASOURCE: DELETE PAYLOAD=$payload');

    final response = await _apiClient.post(
      WSConstantes.movimentacoesExcluirVenda,
      data: payload,
    );

    AppLogger.success('VENDAS DATASOURCE: DELETE RAW RESPONSE=$response');
    return _parseMutationResponse(
      response,
      operationName: 'DELETE VENDA',
      expectedSuccessMessage: 'Venda excluida com sucesso',
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
        'VENDAS DATASOURCE: $operationName RETORNOU CONTRATO INVALIDO RAW=$response',
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
