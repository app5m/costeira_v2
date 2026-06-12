import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/api/api_response_utils.dart';
import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/core/offline/offline_api_service.dart';
import 'package:costeira/core/offline/sync/sync_operation.dart';
import 'package:costeira/core/offline/sync/sync_priority.dart';
import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/features/movimentacoes/consumo/domain/entities/consumo_upsert_entity.dart';
import 'package:costeira/features/movimentacoes/consumo/domain/entities/delete_consumo_entity.dart';
import 'package:costeira/features/movimentacoes/consumo/domain/repository/consumos_datasource.dart';
import 'package:costeira/features/movimentacoes/consumo/infra/models/consumo_upsert_request_model.dart';
import 'package:costeira/features/movimentacoes/consumo/infra/models/delete_consumo_request_model.dart';
import 'package:costeira/features/movimentacoes/infra/data/movimentacao_offline_cache_mutation.dart';

class ConsumosDatasourceImpl implements ConsumosDatasource {
  const ConsumosDatasourceImpl(this._offlineApiService);

  final OfflineApiService _offlineApiService;

  @override
  Future<ApiMessage> createConsumo(ConsumoUpsertEntity consumo) async {
    if (consumo.appUsersId == null) {
      throw ApiException('Usuario nao autenticado para cadastrar consumo.');
    }

    final payload = ConsumoUpsertRequestModel.create(consumo).data;
    AppLogger.info('CONSUMOS DATASOURCE: CREATE PAYLOAD=$payload');

    return _offlineApiService.postOrEnqueue(
      module: 'movimentacoes',
      action: SyncOperation.create,
      endpoint: WSConstantes.movimentacoesAdicionarConsumo,
      payload: payload,
      priority: SyncPriority.movimentacoes,
      pendingMessage: 'Consumo salvo localmente para sincronizar.',
      rawResponseLog: 'CONSUMOS DATASOURCE: CREATE RAW RESPONSE',
      offlineCacheMutation: MovimentacaoOfflineCacheMutation.forEndpoint(
        WSConstantes.movimentacoesAdicionarConsumo,
      ),
      parseResponse: (response) => _parseMutationResponse(
        response,
        operationName: 'CREATE CONSUMO',
        expectedSuccessMessage: 'Consumo cadastrado com sucesso',
      ),
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

    return _offlineApiService.postOrEnqueue(
      module: 'movimentacoes',
      action: SyncOperation.update,
      endpoint: WSConstantes.movimentacoesAdicionarConsumo,
      payload: payload,
      priority: SyncPriority.movimentacoes,
      pendingMessage: 'Alteração do consumo salva para sincronizar.',
      rawResponseLog: 'CONSUMOS DATASOURCE: UPDATE RAW RESPONSE',
      offlineCacheMutation: MovimentacaoOfflineCacheMutation.forEndpoint(
        WSConstantes.movimentacoesAdicionarConsumo,
      ),
      parseResponse: (response) => _parseMutationResponse(
        response,
        operationName: 'UPDATE CONSUMO',
        expectedSuccessMessage: 'Consumo atualizado com sucesso',
      ),
    );
  }

  @override
  Future<ApiMessage> deleteConsumo(DeleteConsumoEntity consumo) async {
    final payload = DeleteConsumoRequestModel.fromEntity(consumo).data;
    AppLogger.info('CONSUMOS DATASOURCE: DELETE PAYLOAD=$payload');

    return _offlineApiService.postOrEnqueue(
      module: 'movimentacoes',
      action: SyncOperation.delete,
      endpoint: WSConstantes.movimentacoesExcluirConsumo,
      payload: payload,
      priority: SyncPriority.movimentacoes,
      pendingMessage: 'Exclusao do consumo salva para sincronizar.',
      rawResponseLog: 'CONSUMOS DATASOURCE: DELETE RAW RESPONSE',
      offlineCacheMutation: MovimentacaoOfflineCacheMutation.forEndpoint(
        WSConstantes.movimentacoesExcluirConsumo,
      ),
      parseResponse: (response) => _parseMutationResponse(
        response,
        operationName: 'DELETE CONSUMO',
        expectedSuccessMessage: 'Consumo excluido com sucesso',
      ),
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
