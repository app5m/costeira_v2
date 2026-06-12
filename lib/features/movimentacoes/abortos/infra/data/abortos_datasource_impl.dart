import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/api/api_response_utils.dart';
import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/core/offline/offline_api_service.dart';
import 'package:costeira/core/offline/sync/sync_operation.dart';
import 'package:costeira/core/offline/sync/sync_priority.dart';
import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/features/movimentacoes/abortos/domain/entities/aborto_upsert_entity.dart';
import 'package:costeira/features/movimentacoes/abortos/domain/entities/delete_aborto_entity.dart';
import 'package:costeira/features/movimentacoes/abortos/domain/repository/abortos_datasource.dart';
import 'package:costeira/features/movimentacoes/abortos/infra/models/aborto_upsert_request_model.dart';
import 'package:costeira/features/movimentacoes/abortos/infra/models/delete_aborto_request_model.dart';
import 'package:costeira/features/movimentacoes/infra/data/movimentacao_offline_cache_mutation.dart';

class AbortosDatasourceImpl implements AbortosDatasource {
  const AbortosDatasourceImpl(this._offlineApiService);

  final OfflineApiService _offlineApiService;

  @override
  Future<ApiMessage> createAborto(AbortoUpsertEntity aborto) async {
    if (aborto.appUsersId == null) {
      throw ApiException('Usuario nao autenticado para cadastrar aborto.');
    }

    final payload = AbortoUpsertRequestModel.create(aborto).data;
    AppLogger.info('ABORTOS DATASOURCE: CREATE PAYLOAD=$payload');

    return _offlineApiService.postOrEnqueue(
      module: 'movimentacoes',
      action: SyncOperation.create,
      endpoint: WSConstantes.movimentacoesAdicionarAborto,
      payload: payload,
      priority: SyncPriority.movimentacoes,
      pendingMessage: 'Aborto salvo localmente para sincronizar.',
      rawResponseLog: 'ABORTOS DATASOURCE: CREATE RAW RESPONSE',
      offlineCacheMutation: MovimentacaoOfflineCacheMutation.forEndpoint(
        WSConstantes.movimentacoesAdicionarAborto,
      ),
      parseResponse: (response) => _parseMutationResponse(
        response,
        operationName: 'CREATE ABORTO',
        expectedSuccessMessage: 'Aborto cadastrado com sucesso',
      ),
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

    return _offlineApiService.postOrEnqueue(
      module: 'movimentacoes',
      action: SyncOperation.update,
      endpoint: WSConstantes.movimentacoesAdicionarAborto,
      payload: payload,
      priority: SyncPriority.movimentacoes,
      pendingMessage: 'Alteração do aborto salva para sincronizar.',
      rawResponseLog: 'ABORTOS DATASOURCE: UPDATE RAW RESPONSE',
      offlineCacheMutation: MovimentacaoOfflineCacheMutation.forEndpoint(
        WSConstantes.movimentacoesAdicionarAborto,
      ),
      parseResponse: (response) => _parseMutationResponse(
        response,
        operationName: 'UPDATE ABORTO',
        expectedSuccessMessage: 'Aborto atualizado com sucesso',
      ),
    );
  }

  @override
  Future<ApiMessage> deleteAborto(DeleteAbortoEntity aborto) async {
    final payload = DeleteAbortoRequestModel.fromEntity(aborto).data;
    AppLogger.info('ABORTOS DATASOURCE: DELETE PAYLOAD=$payload');

    return _offlineApiService.postOrEnqueue(
      module: 'movimentacoes',
      action: SyncOperation.delete,
      endpoint: WSConstantes.movimentacoesExcluirAborto,
      payload: payload,
      priority: SyncPriority.movimentacoes,
      pendingMessage: 'Exclusao do aborto salva para sincronizar.',
      rawResponseLog: 'ABORTOS DATASOURCE: DELETE RAW RESPONSE',
      offlineCacheMutation: MovimentacaoOfflineCacheMutation.forEndpoint(
        WSConstantes.movimentacoesExcluirAborto,
      ),
      parseResponse: (response) => _parseMutationResponse(
        response,
        operationName: 'DELETE ABORTO',
        expectedSuccessMessage: 'Aborto excluido com sucesso',
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
