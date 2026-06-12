import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/api/api_response_utils.dart';
import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/core/offline/offline_api_service.dart';
import 'package:costeira/core/offline/sync/sync_operation.dart';
import 'package:costeira/core/offline/sync/sync_priority.dart';
import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/features/movimentacoes/mortes/domain/entities/delete_morte_entity.dart';
import 'package:costeira/features/movimentacoes/mortes/domain/entities/morte_upsert_entity.dart';
import 'package:costeira/features/movimentacoes/mortes/domain/repository/mortes_datasource.dart';
import 'package:costeira/features/movimentacoes/infra/data/movimentacao_offline_cache_mutation.dart';
import 'package:costeira/features/movimentacoes/mortes/infra/models/delete_morte_request_model.dart';
import 'package:costeira/features/movimentacoes/mortes/infra/models/morte_upsert_request_model.dart';

class MortesDatasourceImpl implements MortesDatasource {
  const MortesDatasourceImpl(this._offlineApiService);

  final OfflineApiService _offlineApiService;

  @override
  Future<ApiMessage> createMorte(MorteUpsertEntity morte) async {
    if (morte.appUsersId == null) {
      throw ApiException('Usuario nao autenticado para cadastrar morte.');
    }

    final payload = MorteUpsertRequestModel.create(morte).data;
    AppLogger.info('MORTES DATASOURCE: CREATE PAYLOAD=$payload');

    return _offlineApiService.postOrEnqueue(
      module: 'movimentacoes',
      action: SyncOperation.create,
      endpoint: WSConstantes.movimentacoesAdicionarMorte,
      payload: payload,
      priority: SyncPriority.movimentacoes,
      pendingMessage: 'Morte salva localmente para sincronizar.',
      rawResponseLog: 'MORTES DATASOURCE: CREATE RAW RESPONSE',
      offlineCacheMutation: MovimentacaoOfflineCacheMutation.forEndpoint(
        WSConstantes.movimentacoesAdicionarMorte,
      ),
      parseResponse: (response) => _parseMutationResponse(
        response,
        operationName: 'CREATE MORTE',
        expectedSuccessMessage: 'Morte cadastrada com sucesso',
      ),
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

    return _offlineApiService.postOrEnqueue(
      module: 'movimentacoes',
      action: SyncOperation.update,
      endpoint: WSConstantes.movimentacoesAdicionarMorte,
      payload: payload,
      priority: SyncPriority.movimentacoes,
      pendingMessage: 'Alteração da morte salva para sincronizar.',
      rawResponseLog: 'MORTES DATASOURCE: UPDATE RAW RESPONSE',
      offlineCacheMutation: MovimentacaoOfflineCacheMutation.forEndpoint(
        WSConstantes.movimentacoesAdicionarMorte,
      ),
      parseResponse: (response) => _parseMutationResponse(
        response,
        operationName: 'UPDATE MORTE',
        expectedSuccessMessage: 'Morte atualizada com sucesso',
      ),
    );
  }

  @override
  Future<ApiMessage> deleteMorte(DeleteMorteEntity morte) async {
    final payload = DeleteMorteRequestModel.fromEntity(morte).data;
    AppLogger.info('MORTES DATASOURCE: DELETE PAYLOAD=$payload');

    return _offlineApiService.postOrEnqueue(
      module: 'movimentacoes',
      action: SyncOperation.delete,
      endpoint: WSConstantes.movimentacoesExcluirMorte,
      payload: payload,
      priority: SyncPriority.movimentacoes,
      pendingMessage: 'Exclusao da morte salva para sincronizar.',
      rawResponseLog: 'MORTES DATASOURCE: DELETE RAW RESPONSE',
      offlineCacheMutation: MovimentacaoOfflineCacheMutation.forEndpoint(
        WSConstantes.movimentacoesExcluirMorte,
      ),
      parseResponse: (response) => _parseMutationResponse(
        response,
        operationName: 'DELETE MORTE',
        expectedSuccessMessage: 'Morte excluida com sucesso',
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
