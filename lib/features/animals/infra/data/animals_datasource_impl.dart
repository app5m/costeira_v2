import 'package:costeira/core/api/api_client.dart';
import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/api/api_response_utils.dart';
import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/core/offline/cache/api_cache_service.dart';
import 'package:costeira/core/offline/cache/offline_mutation_cache_service.dart';
import 'package:costeira/core/offline/network/network_status_service.dart';
import 'package:costeira/core/offline/sync/sync_operation.dart';
import 'package:costeira/core/offline/sync/sync_priority.dart';
import 'package:costeira/core/offline/sync/sync_queue_service.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/features/animals/domain/entities/animal_charts_entity.dart';
import 'package:costeira/features/animals/domain/entities/animal_charts_filter_entity.dart';
import 'package:costeira/features/animals/domain/entities/animal_lot_upsert_entity.dart';
import 'package:costeira/features/animals/domain/entities/animal_lots_filter_entity.dart';
import 'package:costeira/features/animals/domain/entities/animal_lots_list_entity.dart';
import 'package:costeira/features/animals/domain/entities/animal_upsert_entity.dart';
import 'package:costeira/features/animals/domain/entities/animals_filter_entity.dart';
import 'package:costeira/features/animals/domain/entities/animals_list_entity.dart';
import 'package:costeira/features/animals/domain/entities/delete_animal_entity.dart';
import 'package:costeira/features/animals/domain/entities/delete_animal_lot_entity.dart';
import 'package:costeira/features/animals/domain/repository/animals_datasource.dart';
import 'package:costeira/features/animals/infra/models/animal_charts_filter_request_model.dart';
import 'package:costeira/features/animals/infra/models/animal_charts_response_model.dart';
import 'package:costeira/features/animals/infra/models/animal_lot_upsert_request_model.dart';
import 'package:costeira/features/animals/infra/models/animal_lots_filter_request_model.dart';
import 'package:costeira/features/animals/infra/models/animal_lots_list_response_model.dart';
import 'package:costeira/features/animals/infra/models/animal_upsert_request_model.dart';
import 'package:costeira/features/animals/infra/models/animals_filter_request_model.dart';
import 'package:costeira/features/animals/infra/models/animals_list_response_model.dart';
import 'package:costeira/features/animals/infra/models/delete_animal_lot_request_model.dart';
import 'package:costeira/features/animals/infra/models/delete_animal_request_model.dart';

class AnimalsDatasourceImpl implements AnimalsDatasource {
  const AnimalsDatasourceImpl(
    this._apiClient,
    this._networkStatusService,
    this._apiCacheService,
    this._syncQueueService,
    this._mutationCacheService,
  );

  final ApiClient _apiClient;
  final NetworkStatusService _networkStatusService;
  final ApiCacheService _apiCacheService;
  final SyncQueueService _syncQueueService;
  final OfflineMutationCacheService _mutationCacheService;

  @override
  Future<ApiMessage> createAnimal(AnimalUpsertEntity animal) async {
    if (animal.appUsersId == null) {
      throw ApiException('Usuario nao autenticado para cadastrar animal.');
    }

    final payload = AnimalUpsertRequestModel.create(animal).data;
    AppLogger.info('ANIMAIS DATASOURCE: CREATE PAYLOAD=$payload');

    return _runOnlineOrEnqueue(
      action: SyncOperation.create,
      module: 'animais',
      endpoint: WSConstantes.animaisAdd,
      payload: payload,
      priority: SyncPriority.animais,
      pendingMessage: 'Animal salvo localmente para sincronizar.',
      requestDescription: 'CREATE ANIMAL',
      expectedSuccessMessage: 'Animal cadastrado com sucesso',
      rawResponseLog: 'ANIMAIS DATASOURCE: CREATE RAW RESPONSE',
    );
  }

  @override
  Future<ApiMessage> updateAnimal(AnimalUpsertEntity animal) async {
    if (animal.id == null) {
      throw ApiException('Informe o id do animal para atualizar.');
    }
    if (animal.appUsersId == null) {
      throw ApiException('Usuario nao autenticado para atualizar animal.');
    }

    final payload = AnimalUpsertRequestModel.update(animal).data;
    AppLogger.info('ANIMAIS DATASOURCE: UPDATE PAYLOAD=$payload');

    return _runOnlineOrEnqueue(
      action: SyncOperation.update,
      module: 'animais',
      endpoint: WSConstantes.animaisEdit,
      payload: payload,
      priority: SyncPriority.animais,
      pendingMessage: 'Alteração do animal salva para sincronizar.',
      requestDescription: 'UPDATE ANIMAL',
      expectedSuccessMessage: 'Animal atualizado com sucesso',
      rawResponseLog: 'ANIMAIS DATASOURCE: UPDATE RAW RESPONSE',
    );
  }

  @override
  Future<AnimalsListEntity> getAnimals(AnimalsFilterEntity filter) async {
    final payload = AnimalsFilterRequestModel.fromEntity(filter).data;
    AppLogger.info('ANIMAIS DATASOURCE: LIST PAYLOAD=$payload');

    return _getListOnlineOrCached<AnimalsListEntity>(
      endpoint: WSConstantes.animaisListar,
      payload: payload,
      userId: filter.appUsersId,
      parser: (response) => AnimalsListResponseModel.fromJson(responseAsMap(response)),
      missingCacheMessage: 'Sem conexão e sem dados salvos para animais.',
      rawResponseLog: 'ANIMAIS DATASOURCE: LIST RAW RESPONSE',
    );
  }

  @override
  Future<ApiMessage> deleteAnimal(DeleteAnimalEntity animal) async {
    final payload = DeleteAnimalRequestModel.fromEntity(animal).data;
    AppLogger.info('ANIMAIS DATASOURCE: DELETE PAYLOAD=$payload');

    return _runOnlineOrEnqueue(
      action: SyncOperation.delete,
      module: 'animais',
      endpoint: WSConstantes.animaisExcluir,
      payload: payload,
      priority: SyncPriority.animais,
      pendingMessage: 'Exclusão do animal salva para sincronizar.',
      requestDescription: 'DELETE ANIMAL',
      expectedSuccessMessage: 'Animal excluido com sucesso',
      rawResponseLog: 'ANIMAIS DATASOURCE: DELETE RAW RESPONSE',
    );
  }

  @override
  Future<ApiMessage> createAnimalLot(AnimalLotUpsertEntity lot) async {
    if (lot.appUsersId == null) {
      throw ApiException('Usuario nao autenticado para cadastrar lote.');
    }

    final payload = AnimalLotUpsertRequestModel.create(lot).data;
    AppLogger.info('ANIMAIS DATASOURCE: CREATE LOT PAYLOAD=$payload');

    return _runOnlineOrEnqueue(
      action: SyncOperation.create,
      module: 'lotes',
      endpoint: WSConstantes.animaisAdicionarLote,
      payload: payload,
      priority: SyncPriority.lotes,
      pendingMessage: 'Lote salvo localmente para sincronizar.',
      requestDescription: 'CREATE LOT',
      expectedSuccessMessage: 'Lote cadastrado com sucesso',
      rawResponseLog: 'ANIMAIS DATASOURCE: CREATE LOT RAW RESPONSE',
    );
  }

  @override
  Future<ApiMessage> updateAnimalLot(AnimalLotUpsertEntity lot) async {
    if (lot.id == null) {
      throw ApiException('Informe o id do lote para atualizar.');
    }
    if (lot.appUsersId == null) {
      throw ApiException('Usuario nao autenticado para atualizar lote.');
    }

    final payload = AnimalLotUpsertRequestModel.update(lot).data;
    AppLogger.info('ANIMAIS DATASOURCE: UPDATE LOT PAYLOAD=$payload');

    return _runOnlineOrEnqueue(
      action: SyncOperation.update,
      module: 'lotes',
      endpoint: WSConstantes.animaisAdicionarLote,
      payload: payload,
      priority: SyncPriority.lotes,
      pendingMessage: 'Alteração do lote salva para sincronizar.',
      requestDescription: 'UPDATE LOT',
      expectedSuccessMessage: 'Lote atualizado com sucesso',
      rawResponseLog: 'ANIMAIS DATASOURCE: UPDATE LOT RAW RESPONSE',
    );
  }

  @override
  Future<AnimalLotsListEntity> getAnimalLots(AnimalLotsFilterEntity filter) async {
    final payload = AnimalLotsFilterRequestModel.fromEntity(filter).data;
    AppLogger.info('ANIMAIS DATASOURCE: LIST LOTS PAYLOAD=$payload');

    return _getListOnlineOrCached<AnimalLotsListEntity>(
      endpoint: WSConstantes.animaisListarLotes,
      payload: payload,
      userId: filter.appUsersId,
      parser: (response) => AnimalLotsListResponseModel.fromJson(responseAsMap(response)),
      missingCacheMessage: 'Sem conexão e sem dados salvos para lotes.',
      rawResponseLog: 'ANIMAIS DATASOURCE: LIST LOTS RAW RESPONSE',
    );
  }

  @override
  Future<ApiMessage> deleteAnimalLot(DeleteAnimalLotEntity lot) async {
    final payload = DeleteAnimalLotRequestModel.fromEntity(lot).data;
    AppLogger.info('ANIMAIS DATASOURCE: DELETE LOT PAYLOAD=$payload');

    return _runOnlineOrEnqueue(
      action: SyncOperation.delete,
      module: 'lotes',
      endpoint: WSConstantes.animaisExcluirLote,
      payload: payload,
      priority: SyncPriority.lotes,
      pendingMessage: 'Exclusão do lote salva para sincronizar.',
      requestDescription: 'DELETE LOT',
      expectedSuccessMessage: 'Lote excluido com sucesso',
      rawResponseLog: 'ANIMAIS DATASOURCE: DELETE LOT RAW RESPONSE',
    );
  }

  @override
  Future<AnimalChartsEntity> getAnimalCharts(AnimalChartsFilterEntity filter) async {
    final payload = AnimalChartsFilterRequestModel.fromEntity(filter).data;
    AppLogger.info('ANIMAIS DATASOURCE: CHARTS PAYLOAD=$payload');

    final response = await _apiClient.post(WSConstantes.animaisGraficos, data: payload);

    AppLogger.success('ANIMAIS DATASOURCE: CHARTS RAW RESPONSE=$response');

    final wrapper = responseAsMap(response);
    final dataList = wrapper['data'] as List<dynamic>? ?? const [];
    final first = dataList.whereType<Map>().cast<Map>().firstOrNull;

    if (first == null) {
      AppLogger.warning('ANIMAIS DATASOURCE: CHARTS SEM DADOS, RETORNANDO VAZIO');
      return const AnimalChartsEntity(
        pesoTotalRebanho: 0,
        pesoMedioFazenda: 0,
        totalUa: 0,
        quantidadeAnimais: 0,
        porCategoria: [],
        porSexo: [],
        distribuicaoCategoria: [],
        proporcaoSexo: [],
      );
    }

    return AnimalChartsResponseModel.fromJson(Map<String, dynamic>.from(first));
  }

  Future<T> _getListOnlineOrCached<T>({
    required String endpoint,
    required Map<String, dynamic> payload,
    required int userId,
    required T Function(dynamic response) parser,
    required String missingCacheMessage,
    required String rawResponseLog,
  }) async {
    if (!await _networkStatusService.hasConnection()) {
      return _getCachedListOrThrow(
        endpoint: endpoint,
        payload: payload,
        userId: userId,
        parser: parser,
        missingCacheMessage: missingCacheMessage,
      );
    }

    try {
      final response = await _apiClient.post(endpoint, data: payload);
      AppLogger.success('$rawResponseLog=$response');

      await _apiCacheService.saveCache(
        endpoint: endpoint,
        requestPayload: payload,
        response: response,
        userId: userId,
      );

      return parser(response);
    } catch (error) {
      final canUseCacheFallback =
          !await _networkStatusService.hasConnection() || _isConnectionFailure(error);

      if (canUseCacheFallback) {
        final cached = _getCachedList(
          endpoint: endpoint,
          payload: payload,
          userId: userId,
          parser: parser,
        );
        if (cached != null) {
          return cached;
        }
      }
      rethrow;
    }
  }

  T _getCachedListOrThrow<T>({
    required String endpoint,
    required Map<String, dynamic> payload,
    required int userId,
    required T Function(dynamic response) parser,
    required String missingCacheMessage,
  }) {
    final cached = _getCachedList(
      endpoint: endpoint,
      payload: payload,
      userId: userId,
      parser: parser,
    );
    if (cached != null) {
      return cached;
    }

    AppLogger.warning('ANIMAIS DATASOURCE: CACHE NAO ENCONTRADO');
    throw ApiException(missingCacheMessage);
  }

  T? _getCachedList<T>({
    required String endpoint,
    required Map<String, dynamic> payload,
    required int userId,
    required T Function(dynamic response) parser,
  }) {
    final cache = _apiCacheService.getCache(
      endpoint: endpoint,
      requestPayload: payload,
      userId: userId,
    );

    if (cache == null) {
      final latestCache = _apiCacheService.getLatestCacheForEndpoint(
        endpoint: endpoint,
        userId: userId,
      );
      if (latestCache != null) {
        AppLogger.success(
          'ANIMAIS DATASOURCE: LIST USANDO ULTIMO CACHE DO ENDPOINT KEY=${latestCache.key}',
        );
        return parser(latestCache.response);
      }

      return null;
    }

    AppLogger.success('ANIMAIS DATASOURCE: LIST USANDO CACHE KEY=${cache.key}');
    return parser(cache.response);
  }

  Future<ApiMessage> _runOnlineOrEnqueue({
    required String action,
    required String module,
    required String endpoint,
    required Map<String, dynamic> payload,
    required int priority,
    required String pendingMessage,
    required String requestDescription,
    required String expectedSuccessMessage,
    required String rawResponseLog,
  }) async {
    if (!await _networkStatusService.hasConnection()) {
      return _enqueueMutation(
        action: action,
        module: module,
        endpoint: endpoint,
        payload: payload,
        priority: priority,
        successMessage: pendingMessage,
      );
    }

    try {
      final response = await _apiClient.post(endpoint, data: payload);
      AppLogger.success('$rawResponseLog=$response');
      return _parseMutationResponse(
        response,
        operationName: requestDescription,
        expectedSuccessMessage: expectedSuccessMessage,
      );
    } catch (error) {
      if (_isConnectionFailure(error)) {
        return _enqueueMutation(
          action: action,
          module: module,
          endpoint: endpoint,
          payload: payload,
          priority: priority,
          successMessage: pendingMessage,
        );
      }
      rethrow;
    }
  }

  Future<ApiMessage> _enqueueMutation({
    required String action,
    required String module,
    required String endpoint,
    required Map<String, dynamic> payload,
    required int priority,
    required String successMessage,
  }) async {
    final item = await _syncQueueService.addItem(
      module: module,
      action: action,
      endpoint: endpoint,
      payload: payload,
      priority: priority,
    );
    await _applyOfflineCacheMutation(
      action: action,
      module: module,
      payload: payload,
      idLocal: item.idLocal,
    );

    AppLogger.success(
      'ANIMAIS DATASOURCE: MUTATION ENFILEIRADA ID=${item.idLocal} MODULE=$module ACTION=$action',
    );

    return ApiMessage(
      status: '01',
      message: successMessage,
      extra: {'sync_pending': true, 'id_local': item.idLocal},
    );
  }

  Future<void> _applyOfflineCacheMutation({
    required String action,
    required String module,
    required Map<String, dynamic> payload,
    required String idLocal,
  }) async {
    final userId = int.tryParse(payload['app_users_id']?.toString() ?? '');
    final listEndpoint = module == 'lotes'
        ? WSConstantes.animaisListarLotes
        : WSConstantes.animaisListar;
    final isAnimalsModule = module == 'animais';
    final isLotsModule = module == 'lotes';
    final isAnimalCreate = isAnimalsModule && action == SyncOperation.create;
    final isLotCreate = isLotsModule && action == SyncOperation.create;
    final listPayload = userId == null
        ? null
        : isAnimalsModule
        ? await _defaultAnimalsListPayload(payload)
        : isLotsModule
        ? await _defaultLotsListPayload(payload)
        : null;

    await _mutationCacheService.applyMutation(
      action: action,
      listEndpoint: listEndpoint,
      listPayload: listPayload,
      userId: userId,
      item: action == SyncOperation.delete ? null : _cacheItemFrom(payload),
      itemId: payload['id'],
      idLocal: idLocal,
      createCacheWhenMissing: isAnimalCreate || isLotCreate,
      emptyResponse: isAnimalCreate || isLotCreate ? _emptyListResponse() : null,
      allowLatestCacheFallback: !(isAnimalsModule || isLotsModule),
    );
  }

  Map<String, dynamic> _cacheItemFrom(Map<String, dynamic> payload) {
    return Map<String, dynamic>.from(payload)..remove('token');
  }

  Future<Map<String, dynamic>?> _defaultAnimalsListPayload(
    Map<String, dynamic> payload,
  ) async {
    final userId = int.tryParse(payload['app_users_id']?.toString() ?? '');
    if (userId == null) {
      return null;
    }

    final farmId = int.tryParse(payload['app_fazendas_id']?.toString() ?? '') ??
        await SessionStorage.getSelectedFarmId();
    if (farmId == null || farmId <= 0) {
      return null;
    }

    return AnimalsFilterRequestModel.fromEntity(
      AnimalsFilterEntity(appUsersId: userId, appFazendasId: farmId),
    ).data;
  }

  Future<Map<String, dynamic>?> _defaultLotsListPayload(
    Map<String, dynamic> payload,
  ) async {
    final userId = int.tryParse(payload['app_users_id']?.toString() ?? '');
    if (userId == null) {
      return null;
    }

    final farmId = int.tryParse(payload['app_fazendas_id']?.toString() ?? '') ??
        await SessionStorage.getSelectedFarmId();
    if (farmId == null || farmId <= 0) {
      return null;
    }

    return AnimalLotsFilterRequestModel.fromEntity(
      AnimalLotsFilterEntity(appUsersId: userId, appFazendasId: farmId),
    ).data;
  }

  Map<String, dynamic> _emptyListResponse() {
    return {'rows': 0, 'data': <Map<String, dynamic>>[]};
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
        'ANIMAIS DATASOURCE: $operationName RETORNOU CONTRATO INVALIDO RAW=$response',
      );
      throw ApiException(
        'Resposta inesperada da API ao executar $operationName. '
        'Esperado status/msg, recebido: $response',
      );
    }

    final message = ApiMessage.fromResponse(response);
    AppLogger.success(
      'ANIMAIS DATASOURCE: $operationName PARSED STATUS=${message.status} MSG=${message.message}',
    );

    if (!message.isSuccess) {
      throw ApiException(message.message);
    }

    if (message.message.trim().isEmpty) {
      return ApiMessage(status: message.status, message: expectedSuccessMessage);
    }

    return message;
  }

  bool _isConnectionFailure(Object error) {
    return error is ApiException && error.statusCode == null;
  }
}
