import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/api/api_response_utils.dart';
import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/core/offline/offline_api_service.dart';
import 'package:costeira/core/offline/sync/sync_operation.dart';
import 'package:costeira/core/offline/sync/sync_priority.dart';
import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/features/movimentacoes/nascimento/domain/entities/delete_nascimento_entity.dart';
import 'package:costeira/features/movimentacoes/nascimento/domain/entities/nascimento_upsert_entity.dart';
import 'package:costeira/features/movimentacoes/nascimento/domain/repository/nascimentos_datasource.dart';
import 'package:costeira/features/movimentacoes/infra/data/movimentacao_offline_cache_mutation.dart';
import 'package:costeira/features/movimentacoes/nascimento/infra/models/delete_nascimento_request_model.dart';
import 'package:costeira/features/movimentacoes/nascimento/infra/models/nascimento_upsert_request_model.dart';

class NascimentosDatasourceImpl implements NascimentosDatasource {
  const NascimentosDatasourceImpl(this._offlineApiService);

  final OfflineApiService _offlineApiService;

  @override
  Future<ApiMessage> createNascimento(NascimentoUpsertEntity nascimento) async {
    if (nascimento.appUsersId == null) {
      throw ApiException('Usuario nao autenticado para cadastrar nascimento.');
    }
    if (nascimento.animais.length != 2) {
      throw ApiException('O nascimento deve conter uma matriz e um terneiro.');
    }

    final payload = NascimentoUpsertRequestModel.create(nascimento).data;
    AppLogger.info('NASCIMENTOS DATASOURCE: CREATE PAYLOAD=$payload');

    return _offlineApiService.postOrEnqueue(
      module: 'movimentacoes',
      action: SyncOperation.create,
      endpoint: WSConstantes.movimentacoesAdicionarNascimento,
      payload: payload,
      priority: SyncPriority.movimentacoes,
      pendingMessage: 'Nascimento salvo localmente para sincronizar.',
      rawResponseLog: 'NASCIMENTOS DATASOURCE: CREATE RAW RESPONSE',
      offlineCacheMutation: MovimentacaoOfflineCacheMutation.forEndpoint(
        WSConstantes.movimentacoesAdicionarNascimento,
      ),
      parseResponse: (response) => _parseMutationResponse(
        response,
        operationName: 'CREATE NASCIMENTO',
        expectedSuccessMessage: 'Nascimento cadastrado com sucesso',
      ),
    );
  }

  @override
  Future<ApiMessage> updateNascimento(NascimentoUpsertEntity nascimento) async {
    if (nascimento.id == null) {
      throw ApiException('Informe o id do nascimento para atualizar.');
    }
    if (nascimento.appUsersId == null) {
      throw ApiException('Usuario nao autenticado para atualizar nascimento.');
    }

    final payload = NascimentoUpsertRequestModel.update(nascimento).data;
    AppLogger.info('NASCIMENTOS DATASOURCE: UPDATE PAYLOAD=$payload');

    return _offlineApiService.postOrEnqueue(
      module: 'movimentacoes',
      action: SyncOperation.update,
      endpoint: WSConstantes.movimentacoesAdicionarNascimento,
      payload: payload,
      priority: SyncPriority.movimentacoes,
      pendingMessage: 'Alteração do nascimento salva para sincronizar.',
      rawResponseLog: 'NASCIMENTOS DATASOURCE: UPDATE RAW RESPONSE',
      offlineCacheMutation: MovimentacaoOfflineCacheMutation.forEndpoint(
        WSConstantes.movimentacoesAdicionarNascimento,
      ),
      parseResponse: (response) => _parseMutationResponse(
        response,
        operationName: 'UPDATE NASCIMENTO',
        expectedSuccessMessage: 'Nascimento atualizado com sucesso',
      ),
    );
  }

  @override
  Future<ApiMessage> deleteNascimento(DeleteNascimentoEntity nascimento) async {
    final payload = DeleteNascimentoRequestModel.fromEntity(nascimento).data;
    AppLogger.info('NASCIMENTOS DATASOURCE: DELETE PAYLOAD=$payload');

    return _offlineApiService.postOrEnqueue(
      module: 'movimentacoes',
      action: SyncOperation.delete,
      endpoint: WSConstantes.movimentacoesExcluirNascimento,
      payload: payload,
      priority: SyncPriority.movimentacoes,
      pendingMessage: 'Exclusao do nascimento salva para sincronizar.',
      rawResponseLog: 'NASCIMENTOS DATASOURCE: DELETE RAW RESPONSE',
      offlineCacheMutation: MovimentacaoOfflineCacheMutation.forEndpoint(
        WSConstantes.movimentacoesExcluirNascimento,
      ),
      parseResponse: (response) => _parseMutationResponse(
        response,
        operationName: 'DELETE NASCIMENTO',
        expectedSuccessMessage: 'Nascimento excluido com sucesso',
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
        'NASCIMENTOS DATASOURCE: $operationName RETORNOU CONTRATO INVALIDO RAW=$response',
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
