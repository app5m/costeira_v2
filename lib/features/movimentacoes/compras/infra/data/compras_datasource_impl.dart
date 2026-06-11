import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/api/api_response_utils.dart';
import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/core/offline/offline_api_service.dart';
import 'package:costeira/core/offline/sync/sync_operation.dart';
import 'package:costeira/core/offline/sync/sync_priority.dart';
import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/features/movimentacoes/compras/domain/entities/compra_upsert_entity.dart';
import 'package:costeira/features/movimentacoes/compras/domain/entities/delete_compra_entity.dart';
import 'package:costeira/features/movimentacoes/compras/domain/repository/compras_datasource.dart';
import 'package:costeira/features/movimentacoes/compras/infra/models/compra_upsert_request_model.dart';
import 'package:costeira/features/movimentacoes/compras/infra/models/delete_compra_request_model.dart';

class ComprasDatasourceImpl implements ComprasDatasource {
  const ComprasDatasourceImpl(this._offlineApiService);

  final OfflineApiService _offlineApiService;

  @override
  Future<ApiMessage> createCompra(CompraUpsertEntity compra) async {
    if (compra.appUsersId == null) {
      throw ApiException('Usuario nao autenticado para cadastrar compra.');
    }

    final payload = CompraUpsertRequestModel.create(compra).data;
    AppLogger.info('COMPRAS DATASOURCE: CREATE PAYLOAD=$payload');

    return _offlineApiService.postOrEnqueue(
      module: 'movimentacoes',
      action: SyncOperation.create,
      endpoint: WSConstantes.movimentacoesAdicionarCompra,
      payload: payload,
      priority: SyncPriority.movimentacoes,
      pendingMessage: 'Compra salva localmente para sincronizar.',
      rawResponseLog: 'COMPRAS DATASOURCE: CREATE RAW RESPONSE',
      parseResponse: (response) => _parseMutationResponse(
        response,
        operationName: 'CREATE COMPRA',
        expectedSuccessMessage: 'Compra cadastrada com sucesso',
      ),
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

    return _offlineApiService.postOrEnqueue(
      module: 'movimentacoes',
      action: SyncOperation.update,
      endpoint: WSConstantes.movimentacoesAdicionarCompra,
      payload: payload,
      priority: SyncPriority.movimentacoes,
      pendingMessage: 'Alteração da compra salva para sincronizar.',
      rawResponseLog: 'COMPRAS DATASOURCE: UPDATE RAW RESPONSE',
      parseResponse: (response) => _parseMutationResponse(
        response,
        operationName: 'UPDATE COMPRA',
        expectedSuccessMessage: 'Compra atualizada com sucesso',
      ),
    );
  }

  @override
  Future<ApiMessage> deleteCompra(DeleteCompraEntity compra) async {
    final payload = DeleteCompraRequestModel.fromEntity(compra).data;
    AppLogger.info('COMPRAS DATASOURCE: DELETE PAYLOAD=$payload');

    return _offlineApiService.postOrEnqueue(
      module: 'movimentacoes',
      action: SyncOperation.delete,
      endpoint: WSConstantes.movimentacoesExcluirCompra,
      payload: payload,
      priority: SyncPriority.movimentacoes,
      pendingMessage: 'Exclusao da compra salva para sincronizar.',
      rawResponseLog: 'COMPRAS DATASOURCE: DELETE RAW RESPONSE',
      parseResponse: (response) => _parseMutationResponse(
        response,
        operationName: 'DELETE COMPRA',
        expectedSuccessMessage: 'Compra excluida com sucesso',
      ),
    );
  }

  ApiMessage _parseMutationResponse(
    dynamic response, {
    required String operationName,
    required String expectedSuccessMessage,
  }) {
    final map = responseAsMap(response);
    final hasMutationContract = map.containsKey('status') || map.containsKey('msg');

    if (!hasMutationContract) {
      AppLogger.error(
        'COMPRAS DATASOURCE: $operationName RETORNOU CONTRATO INVALIDO RAW=$response',
      );
      throw ApiException('Resposta inesperada da API ao executar $operationName.');
    }

    final message = ApiMessage.fromResponse(response);
    if (!message.isSuccess) {
      throw ApiException(message.message);
    }

    if (message.message.trim().isEmpty) {
      return ApiMessage(status: message.status, message: expectedSuccessMessage);
    }

    return message;
  }
}
