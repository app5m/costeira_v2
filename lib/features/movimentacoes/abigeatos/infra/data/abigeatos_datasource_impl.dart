import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/api/api_response_utils.dart';
import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/core/offline/offline_api_service.dart';
import 'package:costeira/core/offline/sync/sync_operation.dart';
import 'package:costeira/core/offline/sync/sync_priority.dart';
import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/features/movimentacoes/abigeatos/domain/entities/abigeato_upsert_entity.dart';
import 'package:costeira/features/movimentacoes/abigeatos/domain/entities/delete_abigeato_entity.dart';
import 'package:costeira/features/movimentacoes/abigeatos/domain/repository/abigeatos_datasource.dart';
import 'package:costeira/features/movimentacoes/abigeatos/infra/models/abigeato_upsert_request_model.dart';
import 'package:costeira/features/movimentacoes/abigeatos/infra/models/delete_abigeato_request_model.dart';
import 'package:costeira/features/movimentacoes/infra/data/movimentacao_offline_cache_mutation.dart';

class AbigeatosDatasourceImpl implements AbigeatosDatasource {
  const AbigeatosDatasourceImpl(this._offlineApiService);

  final OfflineApiService _offlineApiService;

  @override
  Future<ApiMessage> createAbigeato(AbigeatoUpsertEntity abigeato) async {
    if (abigeato.appUsersId == null) {
      throw ApiException('Usuario nao autenticado para cadastrar abigeato.');
    }

    final payload = AbigeatoUpsertRequestModel.create(abigeato).data;
    AppLogger.info('ABIGEATOS DATASOURCE: CREATE PAYLOAD=$payload');

    return _offlineApiService.postOrEnqueue(
      module: 'movimentacoes',
      action: SyncOperation.create,
      endpoint: WSConstantes.movimentacoesAdicionarAbigeato,
      payload: payload,
      priority: SyncPriority.movimentacoes,
      pendingMessage: 'Abigeato salvo localmente para sincronizar.',
      rawResponseLog: 'ABIGEATOS DATASOURCE: CREATE RAW RESPONSE',
      offlineCacheMutation: MovimentacaoOfflineCacheMutation.forEndpoint(
        WSConstantes.movimentacoesAdicionarAbigeato,
      ),
      parseResponse: (response) => _parseMutationResponse(
        response,
        operationName: 'CREATE ABIGEATO',
        expectedSuccessMessage: 'Abigeato cadastrado com sucesso',
      ),
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

    return _offlineApiService.postOrEnqueue(
      module: 'movimentacoes',
      action: SyncOperation.update,
      endpoint: WSConstantes.movimentacoesAdicionarAbigeato,
      payload: payload,
      priority: SyncPriority.movimentacoes,
      pendingMessage: 'Alteração do abigeato salva para sincronizar.',
      rawResponseLog: 'ABIGEATOS DATASOURCE: UPDATE RAW RESPONSE',
      offlineCacheMutation: MovimentacaoOfflineCacheMutation.forEndpoint(
        WSConstantes.movimentacoesAdicionarAbigeato,
      ),
      parseResponse: (response) => _parseMutationResponse(
        response,
        operationName: 'UPDATE ABIGEATO',
        expectedSuccessMessage: 'Abigeato atualizado com sucesso',
      ),
    );
  }

  @override
  Future<ApiMessage> deleteAbigeato(DeleteAbigeatoEntity abigeato) async {
    final payload = DeleteAbigeatoRequestModel.fromEntity(abigeato).data;
    AppLogger.info('ABIGEATOS DATASOURCE: DELETE PAYLOAD=$payload');

    return _offlineApiService.postOrEnqueue(
      module: 'movimentacoes',
      action: SyncOperation.delete,
      endpoint: WSConstantes.movimentacoesExcluirAbigeato,
      payload: payload,
      priority: SyncPriority.movimentacoes,
      pendingMessage: 'Exclusao do abigeato salva para sincronizar.',
      rawResponseLog: 'ABIGEATOS DATASOURCE: DELETE RAW RESPONSE',
      offlineCacheMutation: MovimentacaoOfflineCacheMutation.forEndpoint(
        WSConstantes.movimentacoesExcluirAbigeato,
      ),
      parseResponse: (response) => _parseMutationResponse(
        response,
        operationName: 'DELETE ABIGEATO',
        expectedSuccessMessage: 'Abigeato excluido com sucesso',
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
