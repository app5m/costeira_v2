import 'package:costeira/core/api/api_client.dart';
import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/api/api_response_utils.dart';
import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/core/offline/cache/api_cache_service.dart';
import 'package:costeira/core/offline/network/network_status_service.dart';
import 'package:costeira/core/offline/sync/sync_operation.dart';
import 'package:costeira/core/offline/sync/sync_priority.dart';
import 'package:costeira/core/offline/sync/sync_queue_service.dart';
import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/features/potreiros/domain/entities/delete_potreiro_entity.dart';
import 'package:costeira/features/potreiros/domain/entities/potreiro_charts_entity.dart';
import 'package:costeira/features/potreiros/domain/entities/potreiro_charts_filter_entity.dart';
import 'package:costeira/features/potreiros/domain/entities/potreiro_upsert_entity.dart';
import 'package:costeira/features/potreiros/domain/entities/potreiros_filter_entity.dart';
import 'package:costeira/features/potreiros/domain/entities/potreiros_list_entity.dart';
import 'package:costeira/features/potreiros/domain/repository/potreiros_datasource.dart';
import 'package:costeira/features/potreiros/infra/models/delete_potreiro_request_model.dart';
import 'package:costeira/features/potreiros/infra/models/potreiro_charts_filter_request_model.dart';
import 'package:costeira/features/potreiros/infra/models/potreiro_charts_response_model.dart';
import 'package:costeira/features/potreiros/infra/models/potreiro_upsert_request_model.dart';
import 'package:costeira/features/potreiros/infra/models/potreiros_filter_request_model.dart';
import 'package:costeira/features/potreiros/infra/models/potreiros_list_response_model.dart';

class PotreirosDatasourceImpl implements PotreirosDatasource {
  const PotreirosDatasourceImpl(
    this._apiClient,
    this._networkStatusService,
    this._apiCacheService,
    this._syncQueueService,
  );

  final ApiClient _apiClient;
  final NetworkStatusService _networkStatusService;
  final ApiCacheService _apiCacheService;
  final SyncQueueService _syncQueueService;

  @override
  Future<PotreirosListEntity> getPotreiros(PotreirosFilterEntity filter) async {
    final payload = PotreirosFilterRequestModel.fromEntity(filter).data;
    AppLogger.info('POTREIROS DATASOURCE: LIST PAYLOAD=$payload');

    if (!await _networkStatusService.hasConnection()) {
      return _getPotreirosFromCacheOrThrow(
        payload: payload,
        userId: filter.appUsersId,
      );
    }

    try {
      final response = await _apiClient.post(
        WSConstantes.potreirosListar,
        data: payload,
      );
      AppLogger.success('POTREIROS DATASOURCE: LIST RAW RESPONSE=$response');

      await _apiCacheService.saveCache(
        endpoint: WSConstantes.potreirosListar,
        requestPayload: payload,
        response: response,
        userId: filter.appUsersId,
      );

      return PotreirosListResponseModel.fromJson(responseAsMap(response));
    } catch (error) {
      final canUseCacheFallback =
          !await _networkStatusService.hasConnection() ||
          _isConnectionFailure(error);

      if (canUseCacheFallback) {
        final cached = _getPotreirosFromCache(
          payload: payload,
          userId: filter.appUsersId,
        );
        if (cached != null) {
          return cached;
        }
      }
      rethrow;
    }
  }

  @override
  Future<ApiMessage> createPotreiro(PotreiroUpsertEntity potreiro) async {
    if (potreiro.appUsersId == null) {
      throw ApiException('Usuário não autenticado para cadastrar potreiro.');
    }

    final payload = PotreiroUpsertRequestModel.create(potreiro).data;
    AppLogger.info('POTREIROS DATASOURCE: CREATE PAYLOAD=$payload');

    if (!await _networkStatusService.hasConnection()) {
      return _enqueuePotreiroMutation(
        action: SyncOperation.create,
        endpoint: WSConstantes.potreirosAdd,
        payload: payload,
        successMessage: 'Potreiro salvo localmente para sincronizar.',
      );
    }

    try {
      final response = await _apiClient.post(
        WSConstantes.potreirosAdd,
        data: payload,
      );
      AppLogger.success('POTREIROS DATASOURCE: CREATE RAW RESPONSE=$response');

      return _parseMutationResponse(
        response,
        operationName: 'CREATE POTREIRO',
        expectedSuccessMessage: 'Potreiro cadastrado com sucesso',
      );
    } catch (error) {
      if (_isConnectionFailure(error)) {
        return _enqueuePotreiroMutation(
          action: SyncOperation.create,
          endpoint: WSConstantes.potreirosAdd,
          payload: payload,
          successMessage: 'Potreiro salvo localmente para sincronizar.',
        );
      }
      rethrow;
    }
  }

  @override
  Future<ApiMessage> updatePotreiro(PotreiroUpsertEntity potreiro) async {
    if (potreiro.id == null) {
      throw ApiException('Informe o id do potreiro para atualizar.');
    }
    if (potreiro.appUsersId == null) {
      throw ApiException('Usuário não autenticado para atualizar potreiro.');
    }

    final payload = PotreiroUpsertRequestModel.update(potreiro).data;
    AppLogger.info('POTREIROS DATASOURCE: UPDATE PAYLOAD=$payload');

    if (!await _networkStatusService.hasConnection()) {
      return _enqueuePotreiroMutation(
        action: SyncOperation.update,
        endpoint: WSConstantes.potreirosAdd,
        payload: payload,
        successMessage: 'Alteração do potreiro salva para sincronizar.',
      );
    }

    try {
      final response = await _apiClient.post(
        WSConstantes.potreirosAdd,
        data: payload,
      );
      AppLogger.success('POTREIROS DATASOURCE: UPDATE RAW RESPONSE=$response');

      return _parseMutationResponse(
        response,
        operationName: 'UPDATE POTREIRO',
        expectedSuccessMessage: 'Potreiro atualizado com sucesso',
      );
    } catch (error) {
      if (_isConnectionFailure(error)) {
        return _enqueuePotreiroMutation(
          action: SyncOperation.update,
          endpoint: WSConstantes.potreirosAdd,
          payload: payload,
          successMessage: 'Alteração do potreiro salva para sincronizar.',
        );
      }
      rethrow;
    }
  }

  @override
  Future<ApiMessage> deletePotreiro(DeletePotreiroEntity potreiro) async {
    final payload = DeletePotreiroRequestModel.fromEntity(potreiro).data;
    AppLogger.info('POTREIROS DATASOURCE: DELETE PAYLOAD=$payload');

    if (!await _networkStatusService.hasConnection()) {
      return _enqueuePotreiroMutation(
        action: SyncOperation.delete,
        endpoint: WSConstantes.potreirosExcluir,
        payload: payload,
        successMessage: 'Exclusão do potreiro salva para sincronizar.',
      );
    }

    try {
      final response = await _apiClient.post(
        WSConstantes.potreirosExcluir,
        data: payload,
      );
      AppLogger.success('POTREIROS DATASOURCE: DELETE RAW RESPONSE=$response');

      return _parseMutationResponse(
        response,
        operationName: 'DELETE POTREIRO',
        expectedSuccessMessage: 'Potreiro excluído com sucesso',
      );
    } catch (error) {
      if (_isConnectionFailure(error)) {
        return _enqueuePotreiroMutation(
          action: SyncOperation.delete,
          endpoint: WSConstantes.potreirosExcluir,
          payload: payload,
          successMessage: 'Exclusão do potreiro salva para sincronizar.',
        );
      }
      rethrow;
    }
  }

  @override
  Future<PotreiroChartsEntity> getPotreiroCharts(
    PotreiroChartsFilterEntity filter,
  ) async {
    final payload = PotreiroChartsFilterRequestModel.fromEntity(filter).data;
    AppLogger.info('POTREIROS DATASOURCE: CHARTS PAYLOAD=$payload');

    final response = await _apiClient.post(
      WSConstantes.potreirosGraficos,
      data: payload,
    );
    AppLogger.success('POTREIROS DATASOURCE: CHARTS RAW RESPONSE=$response');

    final wrapper = responseAsMap(response);
    final dataList = wrapper['data'] as List<dynamic>? ?? const [];
    final first = dataList.whereType<Map>().cast<Map>().firstOrNull;

    if (first == null) {
      return const PotreiroChartsEntity(
        areaTotalSomada: 0,
        areaUtilSomada: 0,
        areaPerdida: 0,
        percentualCampoPerdido: 0,
        percentualUso: 0,
        sombra: [],
        agua: [],
        tabelaAreas: [],
      );
    }

    return PotreiroChartsResponseModel.fromJson(
      Map<String, dynamic>.from(first),
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
        'Resposta inesperada da API ao executar $operationName. '
        'Esperado status/msg, recebido: $response',
      );
    }

    final message = ApiMessage.fromResponse(response);
    AppLogger.success(
      'POTREIROS DATASOURCE: $operationName PARSED STATUS=${message.status} MSG=${message.message}',
    );

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

  PotreirosListEntity _getPotreirosFromCacheOrThrow({
    required Map<String, dynamic> payload,
    required int userId,
  }) {
    final cached = _getPotreirosFromCache(payload: payload, userId: userId);
    if (cached != null) {
      return cached;
    }

    AppLogger.warning('POTREIROS DATASOURCE: CACHE NAO ENCONTRADO');
    throw ApiException('Sem conexão e sem dados salvos para potreiros.');
  }

  PotreirosListEntity? _getPotreirosFromCache({
    required Map<String, dynamic> payload,
    required int userId,
  }) {
    final cache = _apiCacheService.getCache(
      endpoint: WSConstantes.potreirosListar,
      requestPayload: payload,
      userId: userId,
    );

    if (cache == null) {
      return null;
    }

    AppLogger.success(
      'POTREIROS DATASOURCE: LIST USANDO CACHE KEY=${cache.key}',
    );
    return PotreirosListResponseModel.fromJson(responseAsMap(cache.response));
  }

  bool _isConnectionFailure(Object error) {
    return error is ApiException && error.statusCode == null;
  }

  Future<ApiMessage> _enqueuePotreiroMutation({
    required String action,
    required String endpoint,
    required Map<String, dynamic> payload,
    required String successMessage,
  }) async {
    final item = await _syncQueueService.addItem(
      module: 'potreiros',
      action: action,
      endpoint: endpoint,
      payload: payload,
      priority: SyncPriority.potreiros,
    );

    AppLogger.success(
      'POTREIROS DATASOURCE: MUTATION ENFILEIRADA ID=${item.idLocal} ACTION=$action',
    );

    return ApiMessage(
      status: '01',
      message: successMessage,
      extra: {'sync_pending': true, 'id_local': item.idLocal},
    );
  }
}
