import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/api/api_response_utils.dart';
import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/core/offline/cache/offline_mutation_cache_service.dart';
import 'package:costeira/core/offline/offline_api_service.dart';
import 'package:costeira/core/offline/sync/sync_operation.dart';
import 'package:costeira/core/offline/sync/sync_priority.dart';
import 'package:costeira/core/offline/sync/sync_queue_service.dart';
import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/features/movimentacoes/domain/entities/movimentacao_filter_entity.dart';
import 'package:costeira/features/movimentacoes/infra/models/movimentacao_filter_request_model.dart';
import 'package:costeira/features/movimentacoes/nascimento/domain/entities/delete_nascimento_entity.dart';
import 'package:costeira/features/movimentacoes/nascimento/domain/entities/nascimento_upsert_entity.dart';
import 'package:costeira/features/movimentacoes/nascimento/domain/repository/nascimentos_datasource.dart';
import 'package:costeira/features/movimentacoes/nascimento/infra/models/delete_nascimento_request_model.dart';
import 'package:costeira/features/movimentacoes/nascimento/infra/models/nascimento_upsert_request_model.dart';

class NascimentosDatasourceImpl implements NascimentosDatasource {
  const NascimentosDatasourceImpl(
    this._offlineApiService,
    this._syncQueueService,
    this._mutationCacheService,
  );

  final OfflineApiService _offlineApiService;
  final SyncQueueService _syncQueueService;
  final OfflineMutationCacheService _mutationCacheService;

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
      offlineCacheMutation: _nascimentosOfflineCacheMutation,
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
      pendingMessage: 'Alteracao do nascimento salva para sincronizar.',
      rawResponseLog: 'NASCIMENTOS DATASOURCE: UPDATE RAW RESPONSE',
      offlineCacheMutation: _nascimentosOfflineCacheMutation,
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
    AppLogger.info(
      'NASCIMENTOS DATASOURCE: DELETE ID=${nascimento.id} IS_LOCAL=${nascimento.id < 0} PAYLOAD=$payload',
    );

    if (nascimento.id < 0) {
      return _cancelPendingLocalNascimento(nascimento, payload);
    }

    final result = await _offlineApiService.postOrEnqueue(
      module: 'movimentacoes',
      action: SyncOperation.delete,
      endpoint: WSConstantes.movimentacoesExcluirNascimento,
      payload: payload,
      priority: SyncPriority.movimentacoes,
      pendingMessage: 'Exclusao do nascimento salva para sincronizar.',
      rawResponseLog: 'NASCIMENTOS DATASOURCE: DELETE RAW RESPONSE',
      offlineCacheMutation: _nascimentosOfflineCacheMutation,
      parseResponse: (response) => _parseMutationResponse(
        response,
        operationName: 'DELETE NASCIMENTO',
        expectedSuccessMessage: 'Nascimento excluido com sucesso',
      ),
    );

    final pendingDeleteItems = _syncQueueService
        .getPendingItems()
        .where(
          (item) =>
              item.module == 'movimentacoes' &&
              item.action == SyncOperation.delete &&
              item.endpoint == WSConstantes.movimentacoesExcluirNascimento &&
              item.payload['app_users_id']?.toString() ==
                  nascimento.appUsersId.toString(),
        )
        .toList(growable: false);
    AppLogger.info(
      'NASCIMENTOS DATASOURCE: EXCLUSOES DE NASCIMENTO PENDENTES NA FILA=${pendingDeleteItems.length} IDS=${pendingDeleteItems.map((item) => item.payload['id']).join(',')}',
    );

    return result;
  }

  Future<ApiMessage> _cancelPendingLocalNascimento(
    DeleteNascimentoEntity nascimento,
    Map<String, dynamic> payload,
  ) async {
    final pendingCreate = _syncQueueService
        .getPendingItems()
        .where(
          (item) =>
              item.module == 'movimentacoes' &&
              item.action == SyncOperation.create &&
              item.endpoint == WSConstantes.movimentacoesAdicionarNascimento &&
              item.payload['app_users_id']?.toString() ==
                  nascimento.appUsersId.toString() &&
              _localIdFromIdLocal(item.idLocal) == nascimento.id,
        )
        .firstOrNull;

    await _mutationCacheService.applyMutation(
      action: SyncOperation.delete,
      listEndpoint: WSConstantes.movimentacoesListar,
      listPayload: _defaultListPayload(payload),
      userId: nascimento.appUsersId,
      itemId: nascimento.id,
      idLocal: pendingCreate?.idLocal,
      listField: 'data.nascimentos',
      allowLatestCacheFallback: true,
    );

    if (pendingCreate != null) {
      await _syncQueueService.removeItem(pendingCreate.idLocal);
      AppLogger.success(
        'NASCIMENTOS DATASOURCE: NASCIMENTO LOCAL PENDENTE CANCELADO ID_LOCAL=${pendingCreate.idLocal}',
      );
    } else {
      AppLogger.warning(
        'NASCIMENTOS DATASOURCE: NASCIMENTO LOCAL SEM FILA REMOVIDO DO CACHE ID=${nascimento.id}',
      );
    }

    return const ApiMessage(
      status: '01',
      message: 'Nascimento local removido.',
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

  static final OfflineCacheMutation _nascimentosOfflineCacheMutation =
      OfflineCacheMutation(
        listEndpoint: WSConstantes.movimentacoesListar,
        listPayloadBuilder: _defaultListPayload,
        listField: 'data.nascimentos',
        createCacheWhenMissing: true,
        emptyResponse: _emptyListResponse,
        itemBuilder: _buildCachedNascimentoItem,
      );

  static Map<String, dynamic> _defaultListPayload(
    Map<String, dynamic> payload,
  ) {
    final userId = int.tryParse(payload['app_users_id']?.toString() ?? '');
    if (userId == null) {
      return <String, dynamic>{};
    }

    return MovimentacaoFilterRequestModel.fromEntity(
      MovimentacaoFilterEntity(
        appUsersId: userId,
        appFazendasId: int.tryParse(
          payload['app_fazendas_id']?.toString() ?? '',
        ),
      ),
    ).data;
  }

  static const Map<String, dynamic> _emptyListResponse = {
    'rows': 0,
    'data': {
      'compras': <Map<String, dynamic>>[],
      'vendas': <Map<String, dynamic>>[],
      'mortes': <Map<String, dynamic>>[],
      'nascimentos': <Map<String, dynamic>>[],
      'troca_categoria': <Map<String, dynamic>>[],
      'transferencias': <Map<String, dynamic>>[],
      'abigeatos': <Map<String, dynamic>>[],
      'abortos': <Map<String, dynamic>>[],
      'consumos': <Map<String, dynamic>>[],
    },
  };

  static Map<String, dynamic> _buildCachedNascimentoItem(
    Map<String, dynamic> payload,
    String idLocal,
  ) {
    final pesoTotal = _toDouble(payload['peso_total']);
    final animais = (payload['animais'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((animal) {
          return <String, dynamic>{
            ...Map<String, dynamic>.from(animal),
            'app_users_id': payload['app_users_id'],
            'app_animais_lotes_id': payload['app_animais_lotes_id'],
            'app_potreiros_id': payload['app_potreiros_id'],
            'peso_total': pesoTotal,
          }..removeWhere((key, value) => value == null);
        })
        .toList(growable: false);

    return <String, dynamic>{
      'id': _localIdFromIdLocal(idLocal),
      'app_users_id': payload['app_users_id'],
      'app_movimentacoes_categorias_id': 0,
      'app_potreiros_id': payload['app_potreiros_id'],
      'app_animais_lotes_id': payload['app_animais_lotes_id'],
      'data': payload['data'],
      'qtd_animais': animais.length,
      'peso_total': pesoTotal,
      'peso_medio': pesoTotal == null || animais.isEmpty
          ? null
          : pesoTotal / animais.length,
      'obs': payload['obs'],
      'animais': animais,
    }..removeWhere((key, value) => value == null);
  }

  static double? _toDouble(dynamic value) {
    if (value == null) {
      return null;
    }
    final normalized = value
        .toString()
        .replaceAll('R\$', '')
        .replaceAll(',', '.')
        .trim();
    return double.tryParse(normalized);
  }

  static int _localIdFromIdLocal(String idLocal) {
    var hash = 0;
    for (final codeUnit in idLocal.codeUnits) {
      hash = (hash * 31 + codeUnit) & 0x3fffffff;
    }
    return -hash.abs();
  }
}
