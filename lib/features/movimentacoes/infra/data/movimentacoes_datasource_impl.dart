import 'package:costeira/core/api/api_client.dart';
import 'package:costeira/core/api/api_response_utils.dart';
import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/core/offline/cache/api_cache_service.dart';
import 'package:costeira/core/offline/offline_api_service.dart';
import 'package:costeira/core/offline/sync/sync_operation.dart';
import 'package:costeira/core/offline/sync/sync_queue_service.dart';
import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/features/movimentacoes/domain/entities/aborto_charts_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/aborto_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/abigeato_charts_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/abigeato_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/compra_animal_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/compra_charts_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/compra_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/consumo_charts_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/consumo_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/morte_animal_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/morte_charts_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/morte_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/movimentacao_charts_filter_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/movimentacao_filter_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/movimentacao_reference_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/movimentacoes_list_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/nascimento_animal_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/nascimento_charts_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/nascimento_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/troca_categoria_charts_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/troca_categoria_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/transferencia_charts_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/transferencia_entity.dart';
import 'package:costeira/features/movimentacoes/vendas/domain/entities/venda_animal_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/venda_charts_entity.dart';
import 'package:costeira/features/movimentacoes/vendas/domain/entities/venda_destino_entity.dart';
import 'package:costeira/features/movimentacoes/vendas/domain/entities/venda_entity.dart';
import 'package:costeira/features/movimentacoes/domain/repository/movimentacoes_datasource.dart';
import 'package:costeira/features/movimentacoes/infra/models/aborto_charts_response_model.dart';
import 'package:costeira/features/movimentacoes/infra/models/aborto_animal_model.dart';
import 'package:costeira/features/movimentacoes/infra/models/aborto_model.dart';
import 'package:costeira/features/movimentacoes/infra/models/abigeato_charts_response_model.dart';
import 'package:costeira/features/movimentacoes/infra/models/abigeato_model.dart';
import 'package:costeira/features/movimentacoes/infra/models/compra_charts_response_model.dart';
import 'package:costeira/features/movimentacoes/infra/models/compra_model.dart';
import 'package:costeira/features/movimentacoes/infra/models/consumo_charts_response_model.dart';
import 'package:costeira/features/movimentacoes/infra/models/consumo_model.dart';
import 'package:costeira/features/movimentacoes/infra/models/morte_charts_response_model.dart';
import 'package:costeira/features/movimentacoes/infra/models/morte_model.dart';
import 'package:costeira/features/movimentacoes/infra/models/movimentacao_charts_filter_request_model.dart';
import 'package:costeira/features/movimentacoes/infra/models/movimentacao_filter_request_model.dart';
import 'package:costeira/features/movimentacoes/infra/models/movimentacoes_list_response_model.dart';
import 'package:costeira/features/movimentacoes/infra/models/nascimento_charts_response_model.dart';
import 'package:costeira/features/movimentacoes/infra/models/nascimento_model.dart';
import 'package:costeira/features/movimentacoes/infra/models/troca_categoria_charts_response_model.dart';
import 'package:costeira/features/movimentacoes/infra/models/troca_categoria_animal_model.dart';
import 'package:costeira/features/movimentacoes/infra/models/troca_categoria_model.dart';
import 'package:costeira/features/movimentacoes/infra/models/transferencia_charts_response_model.dart';
import 'package:costeira/features/movimentacoes/infra/models/transferencia_model.dart';
import 'package:costeira/features/movimentacoes/infra/models/venda_charts_response_model.dart';
import 'package:costeira/features/movimentacoes/infra/models/venda_model.dart';

class MovimentacoesDatasourceImpl implements MovimentacoesDatasource {
  const MovimentacoesDatasourceImpl(
    this._apiClient,
    this._offlineApiService,
    this._syncQueueService,
    this._apiCacheService,
  );

  final ApiClient _apiClient;
  final OfflineApiService _offlineApiService;
  final SyncQueueService _syncQueueService;
  final ApiCacheService _apiCacheService;

  @override
  Future<MovimentacoesListEntity> getMovimentacoes(
    MovimentacaoFilterEntity filter,
  ) async {
    final payload = MovimentacaoFilterRequestModel.fromEntity(filter).data;
    AppLogger.info('MOVIMENTACOES DATASOURCE: LIST PAYLOAD=$payload');
    final previousCache = _apiCacheService.getCache(
      endpoint: WSConstantes.movimentacoesListar,
      requestPayload: payload,
      userId: filter.appUsersId,
    );

    final result = await _offlineApiService.postCached<MovimentacoesListEntity>(
      endpoint: WSConstantes.movimentacoesListar,
      payload: payload,
      userId: filter.appUsersId,
      parser: (response) => MovimentacoesListResponseModel.fromJson(
        _movimentacoesResponseAsMap(response),
      ),
      missingCacheMessage: 'Sem conexão e sem dados salvos para movimentacoes.',
      rawResponseLog: 'MOVIMENTACOES DATASOURCE: LIST RAW RESPONSE',
    );

    final mergedCompras = _mergePendingCompras(
      result,
      filter,
      previousCache?.response,
    );
    final mergedVendas = _mergePendingVendas(
      mergedCompras,
      filter,
      previousCache?.response,
    );
    final merged = _mergePendingMortes(
      mergedVendas,
      filter,
      previousCache?.response,
    );
    final mergedNascimentos = _mergePendingNascimentos(
      merged,
      filter,
      previousCache?.response,
    );
    final mergedTrocas = _mergePendingTrocaCategoria(
      mergedNascimentos,
      filter,
      previousCache?.response,
    );
    final mergedTransferencias = _mergePendingTransferencias(
      mergedTrocas,
      filter,
      previousCache?.response,
    );
    final mergedAbigeatos = _mergePendingAbigeatos(
      mergedTransferencias,
      filter,
      previousCache?.response,
    );
    final mergedAbortos = _mergePendingAbortos(
      mergedAbigeatos,
      filter,
      previousCache?.response,
    );
    final mergedConsumos = _mergePendingConsumos(
      mergedAbortos,
      filter,
      previousCache?.response,
    );
    if (merged.compras.length != result.compras.length ||
        merged.vendas.length != result.vendas.length ||
        merged.mortes.length != result.mortes.length ||
        mergedNascimentos.nascimentos.length != result.nascimentos.length ||
        mergedTrocas.trocaCategoria.length != result.trocaCategoria.length ||
        mergedTransferencias.transferencias.length !=
            result.transferencias.length ||
        mergedAbigeatos.abigeatos.length != result.abigeatos.length ||
        mergedAbortos.abortos.length != result.abortos.length ||
        mergedConsumos.consumos.length != result.consumos.length) {
      await _apiCacheService.saveCache(
        endpoint: WSConstantes.movimentacoesListar,
        requestPayload: payload,
        response: _cacheResponseWithMovimentacoes(
          previousCache?.response,
          mergedConsumos.compras,
          mergedConsumos.vendas,
          mergedConsumos.mortes,
          mergedConsumos.nascimentos,
          mergedConsumos.trocaCategoria,
          mergedConsumos.transferencias,
          mergedConsumos.abigeatos,
          mergedConsumos.abortos,
          mergedConsumos.consumos,
          mergedConsumos.rows,
        ),
        userId: filter.appUsersId,
      );
    }

    return mergedConsumos;
  }

  @override
  Future<CompraChartsEntity> getCompraCharts(
    MovimentacaoChartsFilterEntity filter,
  ) async {
    final response = await _getChartsResponse(filter);
    return CompraChartsResponseModel.fromJson(response);
  }

  @override
  Future<VendaChartsEntity> getVendaCharts(
    MovimentacaoChartsFilterEntity filter,
  ) async {
    final response = await _getChartsResponse(filter);
    return VendaChartsResponseModel.fromJson(response);
  }

  @override
  Future<MorteChartsEntity> getMorteCharts(
    MovimentacaoChartsFilterEntity filter,
  ) async {
    final response = await _getChartsResponse(filter);
    return MorteChartsResponseModel.fromJson(response);
  }

  @override
  Future<NascimentoChartsEntity> getNascimentoCharts(
    MovimentacaoChartsFilterEntity filter,
  ) async {
    final response = await _getChartsResponse(filter);
    return NascimentoChartsResponseModel.fromJson(response);
  }

  @override
  Future<TrocaCategoriaChartsEntity> getTrocaCategoriaCharts(
    MovimentacaoChartsFilterEntity filter,
  ) async {
    final response = await _getChartsResponse(filter);
    return TrocaCategoriaChartsResponseModel.fromJson(response);
  }

  @override
  Future<AbigeatoChartsEntity> getAbigeatoCharts(
    MovimentacaoChartsFilterEntity filter,
  ) async {
    final response = await _getChartsResponse(filter);
    return AbigeatoChartsResponseModel.fromJson(response);
  }

  @override
  Future<AbortoChartsEntity> getAbortoCharts(
    MovimentacaoChartsFilterEntity filter,
  ) async {
    final response = await _getChartsResponse(filter);
    return AbortoChartsResponseModel.fromJson(response);
  }

  @override
  Future<ConsumoChartsEntity> getConsumoCharts(
    MovimentacaoChartsFilterEntity filter,
  ) async {
    final response = await _getChartsResponse(filter);
    return ConsumoChartsResponseModel.fromJson(response);
  }

  @override
  Future<TransferenciaChartsEntity> getTransferenciaCharts(
    MovimentacaoChartsFilterEntity filter,
  ) async {
    final response = await _getChartsResponse(filter);
    return TransferenciaChartsResponseModel.fromJson(response);
  }

  Future<Map<String, dynamic>> _getChartsResponse(
    MovimentacaoChartsFilterEntity filter,
  ) async {
    final payload = MovimentacaoChartsFilterRequestModel.fromEntity(
      filter,
    ).data;
    AppLogger.info('MOVIMENTACOES DATASOURCE: CHARTS PAYLOAD=$payload');

    final response = await _apiClient.post(
      WSConstantes.movimentacoesGraficos,
      data: payload,
    );

    AppLogger.success(
      'MOVIMENTACOES DATASOURCE: CHARTS RAW RESPONSE=$response',
    );
    return responseAsMap(response);
  }

  MovimentacoesListEntity _mergePendingCompras(
    MovimentacoesListEntity result,
    MovimentacaoFilterEntity filter,
    dynamic previousCacheResponse,
  ) {
    final pendingItems = _syncQueueService.getPendingItems();
    final pendingDeleteIds = pendingItems
        .where(
          (item) =>
              item.module == 'movimentacoes' &&
              item.action == SyncOperation.delete &&
              item.endpoint == WSConstantes.movimentacoesExcluirCompra &&
              item.payload['app_users_id']?.toString() ==
                  filter.appUsersId.toString(),
        )
        .map((item) => int.tryParse(item.payload['id']?.toString() ?? ''))
        .whereType<int>()
        .toSet();

    final resultCompras = result.compras
        .where((compra) => !pendingDeleteIds.contains(compra.id))
        .toList(growable: false);
    final cachedCompras = _cachedCompras(previousCacheResponse, filter)
        .where((compra) => !pendingDeleteIds.contains(compra.id))
        .toList(growable: false);
    final pendingCompras = pendingItems
        .where(
          (item) =>
              item.module == 'movimentacoes' &&
              item.action == SyncOperation.create &&
              item.endpoint == WSConstantes.movimentacoesAdicionarCompra &&
              item.payload['app_users_id']?.toString() ==
                  filter.appUsersId.toString(),
        )
        .map((item) => _pendingCompraFromPayload(item.payload, item.idLocal))
        .where((compra) => filter.id == null || compra.id == filter.id)
        .where((compra) => !pendingDeleteIds.contains(compra.id))
        .toList(growable: false);

    if (pendingCompras.isEmpty &&
        cachedCompras.isEmpty &&
        resultCompras.length == result.compras.length) {
      return result;
    }

    final existingIds = resultCompras.map((item) => item.id).toSet();
    final uniqueCached = cachedCompras
        .where((item) => !existingIds.contains(item.id))
        .toList(growable: false);
    final idsAfterCached = {
      ...existingIds,
      ...uniqueCached.map((item) => item.id),
    };
    final uniquePending = pendingCompras
        .where((item) => !idsAfterCached.contains(item.id))
        .toList(growable: false);

    if (uniqueCached.isEmpty && uniquePending.isEmpty) {
      if (resultCompras.length == result.compras.length) {
        return result;
      }
    }

    AppLogger.info(
      'MOVIMENTACOES DATASOURCE: MESCLANDO ${uniqueCached.length} COMPRAS DO CACHE, ${uniquePending.length} COMPRAS PENDENTES E FILTRANDO ${pendingDeleteIds.length} EXCLUSOES PENDENTES',
    );

    return MovimentacoesListEntity(
      rows:
          result.rows +
          uniqueCached.length +
          uniquePending.length -
          (result.compras.length - resultCompras.length),
      compras: [...uniquePending, ...uniqueCached, ...resultCompras],
      vendas: result.vendas,
      mortes: result.mortes,
      nascimentos: result.nascimentos,
      trocaCategoria: result.trocaCategoria,
      abigeatos: result.abigeatos,
      abortos: result.abortos,
      consumos: result.consumos,
      transferencias: result.transferencias,
    );
  }

  MovimentacoesListEntity _mergePendingVendas(
    MovimentacoesListEntity result,
    MovimentacaoFilterEntity filter,
    dynamic previousCacheResponse,
  ) {
    final pendingItems = _syncQueueService.getPendingItems();
    final pendingDeleteIds = pendingItems
        .where(
          (item) =>
              item.module == 'movimentacoes' &&
              item.action == SyncOperation.delete &&
              item.endpoint == WSConstantes.movimentacoesExcluirVenda &&
              item.payload['app_users_id']?.toString() ==
                  filter.appUsersId.toString(),
        )
        .map((item) => int.tryParse(item.payload['id']?.toString() ?? ''))
        .whereType<int>()
        .toSet();

    final resultVendas = result.vendas
        .where((venda) => !pendingDeleteIds.contains(venda.id))
        .toList(growable: false);
    final cachedVendas = _cachedVendas(previousCacheResponse, filter)
        .where((venda) => !pendingDeleteIds.contains(venda.id))
        .toList(growable: false);
    final pendingVendas = pendingItems
        .where(
          (item) =>
              item.module == 'movimentacoes' &&
              item.action == SyncOperation.create &&
              item.endpoint == WSConstantes.movimentacoesAdicionarVenda &&
              item.payload['app_users_id']?.toString() ==
                  filter.appUsersId.toString(),
        )
        .map((item) => _pendingVendaFromPayload(item.payload, item.idLocal))
        .where((venda) => filter.id == null || venda.id == filter.id)
        .where((venda) => !pendingDeleteIds.contains(venda.id))
        .toList(growable: false);

    if (pendingVendas.isEmpty &&
        cachedVendas.isEmpty &&
        resultVendas.length == result.vendas.length) {
      return result;
    }

    final existingIds = resultVendas.map((item) => item.id).toSet();
    final uniqueCached = cachedVendas
        .where((item) => !existingIds.contains(item.id))
        .toList(growable: false);
    final idsAfterCached = {
      ...existingIds,
      ...uniqueCached.map((item) => item.id),
    };
    final uniquePending = pendingVendas
        .where((item) => !idsAfterCached.contains(item.id))
        .toList(growable: false);

    if (uniqueCached.isEmpty && uniquePending.isEmpty) {
      if (resultVendas.length == result.vendas.length) {
        return result;
      }
    }

    AppLogger.info(
      'MOVIMENTACOES DATASOURCE: MESCLANDO ${uniqueCached.length} VENDAS DO CACHE, ${uniquePending.length} VENDAS PENDENTES E FILTRANDO ${pendingDeleteIds.length} EXCLUSOES PENDENTES',
    );

    return MovimentacoesListEntity(
      rows:
          result.rows +
          uniqueCached.length +
          uniquePending.length -
          (result.vendas.length - resultVendas.length),
      compras: result.compras,
      vendas: [...uniquePending, ...uniqueCached, ...resultVendas],
      mortes: result.mortes,
      nascimentos: result.nascimentos,
      trocaCategoria: result.trocaCategoria,
      abigeatos: result.abigeatos,
      abortos: result.abortos,
      consumos: result.consumos,
      transferencias: result.transferencias,
    );
  }

  MovimentacoesListEntity _mergePendingMortes(
    MovimentacoesListEntity result,
    MovimentacaoFilterEntity filter,
    dynamic previousCacheResponse,
  ) {
    final pendingItems = _syncQueueService.getPendingItems();
    final pendingDeleteIds = pendingItems
        .where(
          (item) =>
              item.module == 'movimentacoes' &&
              item.action == SyncOperation.delete &&
              item.endpoint == WSConstantes.movimentacoesExcluirMorte &&
              item.payload['app_users_id']?.toString() ==
                  filter.appUsersId.toString(),
        )
        .map((item) => int.tryParse(item.payload['id']?.toString() ?? ''))
        .whereType<int>()
        .toSet();

    final resultMortes = result.mortes
        .where((morte) => !pendingDeleteIds.contains(morte.id))
        .toList(growable: false);
    final cachedMortes = _cachedMortes(previousCacheResponse, filter)
        .where((morte) => !pendingDeleteIds.contains(morte.id))
        .toList(growable: false);
    final pendingMortes = pendingItems
        .where(
          (item) =>
              item.module == 'movimentacoes' &&
              item.action == SyncOperation.create &&
              item.endpoint == WSConstantes.movimentacoesAdicionarMorte &&
              item.payload['app_users_id']?.toString() ==
                  filter.appUsersId.toString(),
        )
        .map((item) => _pendingMorteFromPayload(item.payload, item.idLocal))
        .where((morte) => filter.id == null || morte.id == filter.id)
        .where((morte) => !pendingDeleteIds.contains(morte.id))
        .toList(growable: false);

    if (pendingMortes.isEmpty &&
        cachedMortes.isEmpty &&
        resultMortes.length == result.mortes.length) {
      return result;
    }

    final existingIds = resultMortes.map((item) => item.id).toSet();
    final uniqueCached = cachedMortes
        .where((item) => !existingIds.contains(item.id))
        .toList(growable: false);
    final idsAfterCached = {
      ...existingIds,
      ...uniqueCached.map((item) => item.id),
    };
    final uniquePending = pendingMortes
        .where((item) => !idsAfterCached.contains(item.id))
        .toList(growable: false);

    if (uniqueCached.isEmpty && uniquePending.isEmpty) {
      if (resultMortes.length == result.mortes.length) {
        return result;
      }
    }

    AppLogger.info(
      'MOVIMENTACOES DATASOURCE: MESCLANDO ${uniqueCached.length} MORTES DO CACHE, ${uniquePending.length} MORTES PENDENTES E FILTRANDO ${pendingDeleteIds.length} EXCLUSOES PENDENTES',
    );

    return MovimentacoesListEntity(
      rows:
          result.rows +
          uniqueCached.length +
          uniquePending.length -
          (result.mortes.length - resultMortes.length),
      compras: result.compras,
      vendas: result.vendas,
      mortes: [...uniquePending, ...uniqueCached, ...resultMortes],
      nascimentos: result.nascimentos,
      trocaCategoria: result.trocaCategoria,
      abigeatos: result.abigeatos,
      abortos: result.abortos,
      consumos: result.consumos,
      transferencias: result.transferencias,
    );
  }

  MovimentacoesListEntity _mergePendingNascimentos(
    MovimentacoesListEntity result,
    MovimentacaoFilterEntity filter,
    dynamic previousCacheResponse,
  ) {
    final pendingItems = _syncQueueService.getPendingItems();
    final pendingDeleteIds = pendingItems
        .where(
          (item) =>
              item.module == 'movimentacoes' &&
              item.action == SyncOperation.delete &&
              item.endpoint == WSConstantes.movimentacoesExcluirNascimento &&
              item.payload['app_users_id']?.toString() ==
                  filter.appUsersId.toString(),
        )
        .map((item) => int.tryParse(item.payload['id']?.toString() ?? ''))
        .whereType<int>()
        .toSet();

    final pendingCreateLocalIds = pendingItems
        .where(
          (item) =>
              item.module == 'movimentacoes' &&
              item.action == SyncOperation.create &&
              item.endpoint == WSConstantes.movimentacoesAdicionarNascimento &&
              item.payload['app_users_id']?.toString() ==
                  filter.appUsersId.toString(),
        )
        .map((item) => item.idLocal)
        .toSet();
    final resultNascimentos = result.nascimentos
        .where(
          (nascimento) => !_isStaleLocalNascimento(
            nascimento,
            activeCreateLocalIds: pendingCreateLocalIds,
          ),
        )
        .where((nascimento) => !pendingDeleteIds.contains(nascimento.id))
        .toList(growable: false);
    final cachedNascimentos = _cachedNascimentos(previousCacheResponse, filter)
        .where(
          (nascimento) => !_isStaleLocalNascimento(
            nascimento,
            activeCreateLocalIds: pendingCreateLocalIds,
          ),
        )
        .where((nascimento) => !pendingDeleteIds.contains(nascimento.id))
        .toList(growable: false);
    final pendingNascimentos = pendingItems
        .where(
          (item) =>
              item.module == 'movimentacoes' &&
              item.action == SyncOperation.create &&
              item.endpoint == WSConstantes.movimentacoesAdicionarNascimento &&
              item.payload['app_users_id']?.toString() ==
                  filter.appUsersId.toString(),
        )
        .map(
          (item) => _pendingNascimentoFromPayload(item.payload, item.idLocal),
        )
        .where((nascimento) => filter.id == null || nascimento.id == filter.id)
        .where((nascimento) => !pendingDeleteIds.contains(nascimento.id))
        .toList(growable: false);

    if (pendingNascimentos.isEmpty &&
        cachedNascimentos.isEmpty &&
        resultNascimentos.length == result.nascimentos.length) {
      return result;
    }

    final existingIds = resultNascimentos.map((item) => item.id).toSet();
    final uniqueCached = cachedNascimentos
        .where((item) => !existingIds.contains(item.id))
        .toList(growable: false);
    final idsAfterCached = {
      ...existingIds,
      ...uniqueCached.map((item) => item.id),
    };
    final uniquePending = pendingNascimentos
        .where((item) => !idsAfterCached.contains(item.id))
        .toList(growable: false);

    if (uniqueCached.isEmpty && uniquePending.isEmpty) {
      if (resultNascimentos.length == result.nascimentos.length) {
        return result;
      }
    }

    AppLogger.info(
      'MOVIMENTACOES DATASOURCE: MESCLANDO ${uniqueCached.length} NASCIMENTOS DO CACHE, ${uniquePending.length} NASCIMENTOS PENDENTES E FILTRANDO ${pendingDeleteIds.length} EXCLUSOES PENDENTES',
    );

    return MovimentacoesListEntity(
      rows:
          result.rows +
          uniqueCached.length +
          uniquePending.length -
          (result.nascimentos.length - resultNascimentos.length),
      compras: result.compras,
      vendas: result.vendas,
      mortes: result.mortes,
      nascimentos: [...uniquePending, ...uniqueCached, ...resultNascimentos],
      trocaCategoria: result.trocaCategoria,
      abigeatos: result.abigeatos,
      abortos: result.abortos,
      consumos: result.consumos,
      transferencias: result.transferencias,
    );
  }

  MovimentacoesListEntity _mergePendingTrocaCategoria(
    MovimentacoesListEntity result,
    MovimentacaoFilterEntity filter,
    dynamic previousCacheResponse,
  ) {
    return _mergePendingModule<TrocaCategoriaModel>(
      result: result,
      filter: filter,
      previousCacheResponse: previousCacheResponse,
      createEndpoint: WSConstantes.movimentacoesAdicionarTrocaCategoria,
      deleteEndpoint: WSConstantes.movimentacoesExcluirTrocaCategoria,
      label: 'TROCAS DE CATEGORIA',
      currentItems: (entity) => entity.trocaCategoria
          .map(
            (item) => TrocaCategoriaModel.fromJson(_trocaCategoriaToJson(item)),
          )
          .toList(growable: false),
      cachedItems: _cachedTrocaCategoria,
      pendingFromPayload: _pendingTrocaCategoriaFromPayload,
      itemId: (item) => item.id,
      rebuild: (entity, items, rows) => MovimentacoesListEntity(
        rows: rows,
        compras: entity.compras,
        vendas: entity.vendas,
        mortes: entity.mortes,
        nascimentos: entity.nascimentos,
        trocaCategoria: items,
        abigeatos: entity.abigeatos,
        abortos: entity.abortos,
        consumos: entity.consumos,
        transferencias: entity.transferencias,
      ),
    );
  }

  MovimentacoesListEntity _mergePendingTransferencias(
    MovimentacoesListEntity result,
    MovimentacaoFilterEntity filter,
    dynamic previousCacheResponse,
  ) {
    return _mergePendingModule<TransferenciaModel>(
      result: result,
      filter: filter,
      previousCacheResponse: previousCacheResponse,
      createEndpoint: WSConstantes.movimentacoesAdicionarTransferencia,
      deleteEndpoint: WSConstantes.movimentacoesExcluirTransferencia,
      label: 'TRANSFERENCIAS',
      currentItems: (entity) => entity.transferencias
          .map(
            (item) => TransferenciaModel.fromJson(_transferenciaToJson(item)),
          )
          .toList(growable: false),
      cachedItems: _cachedTransferencias,
      pendingFromPayload: _pendingTransferenciaFromPayload,
      itemId: (item) => item.id,
      rebuild: (entity, items, rows) => MovimentacoesListEntity(
        rows: rows,
        compras: entity.compras,
        vendas: entity.vendas,
        mortes: entity.mortes,
        nascimentos: entity.nascimentos,
        trocaCategoria: entity.trocaCategoria,
        abigeatos: entity.abigeatos,
        abortos: entity.abortos,
        consumos: entity.consumos,
        transferencias: items,
      ),
    );
  }

  MovimentacoesListEntity _mergePendingAbigeatos(
    MovimentacoesListEntity result,
    MovimentacaoFilterEntity filter,
    dynamic previousCacheResponse,
  ) {
    return _mergePendingModule<AbigeatoModel>(
      result: result,
      filter: filter,
      previousCacheResponse: previousCacheResponse,
      createEndpoint: WSConstantes.movimentacoesAdicionarAbigeato,
      deleteEndpoint: WSConstantes.movimentacoesExcluirAbigeato,
      label: 'ABIGEATOS',
      currentItems: (entity) => entity.abigeatos
          .map((item) => AbigeatoModel.fromJson(_abigeatoToJson(item)))
          .toList(growable: false),
      cachedItems: _cachedAbigeatos,
      pendingFromPayload: _pendingAbigeatoFromPayload,
      itemId: (item) => item.id,
      rebuild: (entity, items, rows) => MovimentacoesListEntity(
        rows: rows,
        compras: entity.compras,
        vendas: entity.vendas,
        mortes: entity.mortes,
        nascimentos: entity.nascimentos,
        trocaCategoria: entity.trocaCategoria,
        abigeatos: items,
        abortos: entity.abortos,
        consumos: entity.consumos,
        transferencias: entity.transferencias,
      ),
    );
  }

  MovimentacoesListEntity _mergePendingAbortos(
    MovimentacoesListEntity result,
    MovimentacaoFilterEntity filter,
    dynamic previousCacheResponse,
  ) {
    return _mergePendingModule<AbortoModel>(
      result: result,
      filter: filter,
      previousCacheResponse: previousCacheResponse,
      createEndpoint: WSConstantes.movimentacoesAdicionarAborto,
      deleteEndpoint: WSConstantes.movimentacoesExcluirAborto,
      label: 'ABORTOS',
      currentItems: (entity) => entity.abortos
          .map((item) => AbortoModel.fromJson(_abortoToJson(item)))
          .toList(growable: false),
      cachedItems: _cachedAbortos,
      pendingFromPayload: _pendingAbortoFromPayload,
      itemId: (item) => item.id,
      rebuild: (entity, items, rows) => MovimentacoesListEntity(
        rows: rows,
        compras: entity.compras,
        vendas: entity.vendas,
        mortes: entity.mortes,
        nascimentos: entity.nascimentos,
        trocaCategoria: entity.trocaCategoria,
        abigeatos: entity.abigeatos,
        abortos: items,
        consumos: entity.consumos,
        transferencias: entity.transferencias,
      ),
    );
  }

  MovimentacoesListEntity _mergePendingConsumos(
    MovimentacoesListEntity result,
    MovimentacaoFilterEntity filter,
    dynamic previousCacheResponse,
  ) {
    return _mergePendingModule<ConsumoModel>(
      result: result,
      filter: filter,
      previousCacheResponse: previousCacheResponse,
      createEndpoint: WSConstantes.movimentacoesAdicionarConsumo,
      deleteEndpoint: WSConstantes.movimentacoesExcluirConsumo,
      label: 'CONSUMOS',
      currentItems: (entity) => entity.consumos
          .map((item) => ConsumoModel.fromJson(_consumoToJson(item)))
          .toList(growable: false),
      cachedItems: _cachedConsumos,
      pendingFromPayload: _pendingConsumoFromPayload,
      itemId: (item) => item.id,
      rebuild: (entity, items, rows) => MovimentacoesListEntity(
        rows: rows,
        compras: entity.compras,
        vendas: entity.vendas,
        mortes: entity.mortes,
        nascimentos: entity.nascimentos,
        trocaCategoria: entity.trocaCategoria,
        abigeatos: entity.abigeatos,
        abortos: entity.abortos,
        consumos: items,
        transferencias: entity.transferencias,
      ),
    );
  }

  MovimentacoesListEntity _mergePendingModule<T>({
    required MovimentacoesListEntity result,
    required MovimentacaoFilterEntity filter,
    required dynamic previousCacheResponse,
    required String createEndpoint,
    required String deleteEndpoint,
    required String label,
    required List<T> Function(MovimentacoesListEntity entity) currentItems,
    required List<T> Function(
      dynamic previousCacheResponse,
      MovimentacaoFilterEntity filter,
    )
    cachedItems,
    required T Function(Map<String, dynamic> payload, String idLocal)
    pendingFromPayload,
    required int Function(T item) itemId,
    required MovimentacoesListEntity Function(
      MovimentacoesListEntity entity,
      List<T> items,
      int rows,
    )
    rebuild,
  }) {
    final pendingItems = _syncQueueService.getPendingItems();
    final pendingDeleteIds = pendingItems
        .where(
          (item) =>
              item.module == 'movimentacoes' &&
              item.action == SyncOperation.delete &&
              item.endpoint == deleteEndpoint &&
              item.payload['app_users_id']?.toString() ==
                  filter.appUsersId.toString(),
        )
        .map((item) => int.tryParse(item.payload['id']?.toString() ?? ''))
        .whereType<int>()
        .toSet();
    final activeCreateLocalIds = pendingItems
        .where(
          (item) =>
              item.module == 'movimentacoes' &&
              item.action == SyncOperation.create &&
              item.endpoint == createEndpoint &&
              item.payload['app_users_id']?.toString() ==
                  filter.appUsersId.toString(),
        )
        .map((item) => item.idLocal)
        .toSet();

    bool isStaleLocal(T item) {
      final id = itemId(item);
      if (id >= 0) {
        return false;
      }
      return !activeCreateLocalIds.any(
        (idLocal) => _localIdFromIdLocal(idLocal) == id,
      );
    }

    final resultItems = currentItems(result)
        .where((item) => !isStaleLocal(item))
        .where((item) => !pendingDeleteIds.contains(itemId(item)))
        .toList(growable: false);
    final cached = cachedItems(previousCacheResponse, filter)
        .where((item) => !pendingDeleteIds.contains(itemId(item)))
        .where((item) => !isStaleLocal(item))
        .toList(growable: false);
    final pending = pendingItems
        .where(
          (item) =>
              item.module == 'movimentacoes' &&
              item.action == SyncOperation.create &&
              item.endpoint == createEndpoint &&
              item.payload['app_users_id']?.toString() ==
                  filter.appUsersId.toString(),
        )
        .map((item) => pendingFromPayload(item.payload, item.idLocal))
        .where((item) => filter.id == null || itemId(item) == filter.id)
        .where((item) => !pendingDeleteIds.contains(itemId(item)))
        .toList(growable: false);

    final originalItems = currentItems(result);
    if (pending.isEmpty &&
        cached.isEmpty &&
        resultItems.length == originalItems.length) {
      return result;
    }

    final existingIds = resultItems.map(itemId).toSet();
    final uniqueCached = cached
        .where((item) => !existingIds.contains(itemId(item)))
        .toList(growable: false);
    final idsAfterCached = {...existingIds, ...uniqueCached.map(itemId)};
    final uniquePending = pending
        .where((item) => !idsAfterCached.contains(itemId(item)))
        .toList(growable: false);

    if (uniqueCached.isEmpty && uniquePending.isEmpty) {
      if (resultItems.length == originalItems.length) {
        return result;
      }
    }

    AppLogger.info(
      'MOVIMENTACOES DATASOURCE: MESCLANDO ${uniqueCached.length} $label DO CACHE, ${uniquePending.length} $label PENDENTES E FILTRANDO ${pendingDeleteIds.length} EXCLUSOES PENDENTES',
    );

    return rebuild(
      result,
      [...uniquePending, ...uniqueCached, ...resultItems],
      result.rows +
          uniqueCached.length +
          uniquePending.length -
          (originalItems.length - resultItems.length),
    );
  }

  List<CompraModel> _cachedCompras(
    dynamic previousCacheResponse,
    MovimentacaoFilterEntity filter,
  ) {
    if (previousCacheResponse == null) {
      return const [];
    }

    try {
      final cached = MovimentacoesListResponseModel.fromJson(
        _movimentacoesResponseAsMap(previousCacheResponse),
      );
      return cached.compras
          .where((compra) => filter.id == null || compra.id == filter.id)
          .map(
            (compra) => CompraModel(
              id: compra.id,
              appUsersId: compra.appUsersId,
              appMovimentacoesCategoriasId: compra.appMovimentacoesCategoriasId,
              data: compra.data,
              qtdAnimais: compra.qtdAnimais,
              pesoMedio: compra.pesoMedio,
              pesoTotal: compra.pesoTotal,
              valorTotal: compra.valorTotal,
              valorTotalRaw: compra.valorTotalRaw,
              valorUnitario: compra.valorUnitario,
              valorUnitarioRaw: compra.valorUnitarioRaw,
              municipio: compra.municipio,
              obs: compra.obs,
              dataCadastro: compra.dataCadastro,
              updateAt: compra.updateAt,
              categoriaMovimentacao: compra.categoriaMovimentacao,
              animais: compra.animais,
              tipoCompra: compra.tipoCompra,
              fornecedor: compra.fornecedor,
              appPotreirosId: compra.appPotreirosId,
              appAnimaisLotesId: compra.appAnimaisLotesId,
              potreiro: compra.potreiro,
              lote: compra.lote,
            ),
          )
          .toList(growable: false);
    } catch (error, stackTrace) {
      AppLogger.error(
        'MOVIMENTACOES DATASOURCE: ERRO AO LER COMPRAS DO CACHE ANTERIOR ERROR=$error STACK=$stackTrace',
      );
      return const [];
    }
  }

  List<VendaModel> _cachedVendas(
    dynamic previousCacheResponse,
    MovimentacaoFilterEntity filter,
  ) {
    if (previousCacheResponse == null) {
      return const [];
    }

    try {
      final cached = MovimentacoesListResponseModel.fromJson(
        _movimentacoesResponseAsMap(previousCacheResponse),
      );
      return cached.vendas
          .where((venda) => filter.id == null || venda.id == filter.id)
          .map(
            (venda) => VendaModel(
              id: venda.id,
              appUsersId: venda.appUsersId,
              appMovimentacoesCategoriasId: venda.appMovimentacoesCategoriasId,
              data: venda.data,
              qtdAnimais: venda.qtdAnimais,
              pesoMedio: venda.pesoMedio,
              pesoTotal: venda.pesoTotal,
              valorTotal: venda.valorTotal,
              valorTotalRaw: venda.valorTotalRaw,
              valorUnitario: venda.valorUnitario,
              valorUnitarioRaw: venda.valorUnitarioRaw,
              comprador: venda.comprador,
              municipio: venda.municipio,
              obs: venda.obs,
              dataCadastro: venda.dataCadastro,
              updateAt: venda.updateAt,
              animais: venda.animais,
              destinos: venda.destinos,
            ),
          )
          .toList(growable: false);
    } catch (error, stackTrace) {
      AppLogger.error(
        'MOVIMENTACOES DATASOURCE: ERRO AO LER VENDAS DO CACHE ANTERIOR ERROR=$error STACK=$stackTrace',
      );
      return const [];
    }
  }

  List<MorteModel> _cachedMortes(
    dynamic previousCacheResponse,
    MovimentacaoFilterEntity filter,
  ) {
    if (previousCacheResponse == null) {
      return const [];
    }

    try {
      final cached = MovimentacoesListResponseModel.fromJson(
        _movimentacoesResponseAsMap(previousCacheResponse),
      );
      return cached.mortes
          .where((morte) => filter.id == null || morte.id == filter.id)
          .map(
            (morte) => MorteModel(
              id: morte.id,
              appUsersId: morte.appUsersId,
              appMovimentacoesCategoriasId: morte.appMovimentacoesCategoriasId,
              data: morte.data,
              qtdAnimais: morte.qtdAnimais,
              pesoMedio: morte.pesoMedio,
              pesoTotal: morte.pesoTotal,
              valorTotal: morte.valorTotal,
              valorTotalRaw: morte.valorTotalRaw,
              valorUnitario: morte.valorUnitario,
              valorUnitarioRaw: morte.valorUnitarioRaw,
              municipio: morte.municipio,
              obs: morte.obs,
              dataCadastro: morte.dataCadastro,
              updateAt: morte.updateAt,
              categoriaMovimentacao: morte.categoriaMovimentacao,
              animais: morte.animais,
              appPotreirosId: morte.appPotreirosId,
              potreiro: morte.potreiro,
            ),
          )
          .toList(growable: false);
    } catch (error, stackTrace) {
      AppLogger.error(
        'MOVIMENTACOES DATASOURCE: ERRO AO LER MORTES DO CACHE ANTERIOR ERROR=$error STACK=$stackTrace',
      );
      return const [];
    }
  }

  List<NascimentoModel> _cachedNascimentos(
    dynamic previousCacheResponse,
    MovimentacaoFilterEntity filter,
  ) {
    if (previousCacheResponse == null) {
      return const [];
    }

    try {
      final cached = MovimentacoesListResponseModel.fromJson(
        _movimentacoesResponseAsMap(previousCacheResponse),
      );
      return cached.nascimentos
          .where(
            (nascimento) => filter.id == null || nascimento.id == filter.id,
          )
          .map(
            (nascimento) => NascimentoModel(
              id: nascimento.id,
              appUsersId: nascimento.appUsersId,
              appMovimentacoesCategoriasId:
                  nascimento.appMovimentacoesCategoriasId,
              data: nascimento.data,
              qtdAnimais: nascimento.qtdAnimais,
              pesoMedio: nascimento.pesoMedio,
              pesoTotal: nascimento.pesoTotal,
              valorTotal: nascimento.valorTotal,
              valorTotalRaw: nascimento.valorTotalRaw,
              valorUnitario: nascimento.valorUnitario,
              valorUnitarioRaw: nascimento.valorUnitarioRaw,
              municipio: nascimento.municipio,
              obs: nascimento.obs,
              dataCadastro: nascimento.dataCadastro,
              updateAt: nascimento.updateAt,
              categoriaMovimentacao: nascimento.categoriaMovimentacao,
              animais: nascimento.animais,
              appPotreirosId: nascimento.appPotreirosId,
              appAnimaisLotesId: nascimento.appAnimaisLotesId,
              potreiro: nascimento.potreiro,
              lote: nascimento.lote,
            ),
          )
          .toList(growable: false);
    } catch (error, stackTrace) {
      AppLogger.error(
        'MOVIMENTACOES DATASOURCE: ERRO AO LER NASCIMENTOS DO CACHE ANTERIOR ERROR=$error STACK=$stackTrace',
      );
      return const [];
    }
  }

  List<TrocaCategoriaModel> _cachedTrocaCategoria(
    dynamic previousCacheResponse,
    MovimentacaoFilterEntity filter,
  ) {
    if (previousCacheResponse == null) {
      return const [];
    }

    try {
      final cached = MovimentacoesListResponseModel.fromJson(
        _movimentacoesResponseAsMap(previousCacheResponse),
      );
      return cached.trocaCategoria
          .where((troca) => filter.id == null || troca.id == filter.id)
          .map(
            (troca) =>
                TrocaCategoriaModel.fromJson(_trocaCategoriaToJson(troca)),
          )
          .toList(growable: false);
    } catch (error, stackTrace) {
      AppLogger.error(
        'MOVIMENTACOES DATASOURCE: ERRO AO LER TROCAS DE CATEGORIA DO CACHE ANTERIOR ERROR=$error STACK=$stackTrace',
      );
      return const [];
    }
  }

  List<TransferenciaModel> _cachedTransferencias(
    dynamic previousCacheResponse,
    MovimentacaoFilterEntity filter,
  ) {
    if (previousCacheResponse == null) {
      return const [];
    }

    try {
      final cached = MovimentacoesListResponseModel.fromJson(
        _movimentacoesResponseAsMap(previousCacheResponse),
      );
      return cached.transferencias
          .where(
            (transferencia) =>
                filter.id == null || transferencia.id == filter.id,
          )
          .map(
            (transferencia) => TransferenciaModel.fromJson(
              _transferenciaToJson(transferencia),
            ),
          )
          .toList(growable: false);
    } catch (error, stackTrace) {
      AppLogger.error(
        'MOVIMENTACOES DATASOURCE: ERRO AO LER TRANSFERENCIAS DO CACHE ANTERIOR ERROR=$error STACK=$stackTrace',
      );
      return const [];
    }
  }

  List<AbigeatoModel> _cachedAbigeatos(
    dynamic previousCacheResponse,
    MovimentacaoFilterEntity filter,
  ) {
    if (previousCacheResponse == null) {
      return const [];
    }

    try {
      final cached = MovimentacoesListResponseModel.fromJson(
        _movimentacoesResponseAsMap(previousCacheResponse),
      );
      return cached.abigeatos
          .where((abigeato) => filter.id == null || abigeato.id == filter.id)
          .map((abigeato) => AbigeatoModel.fromJson(_abigeatoToJson(abigeato)))
          .toList(growable: false);
    } catch (error, stackTrace) {
      AppLogger.error(
        'MOVIMENTACOES DATASOURCE: ERRO AO LER ABIGEATOS DO CACHE ANTERIOR ERROR=$error STACK=$stackTrace',
      );
      return const [];
    }
  }

  List<AbortoModel> _cachedAbortos(
    dynamic previousCacheResponse,
    MovimentacaoFilterEntity filter,
  ) {
    if (previousCacheResponse == null) {
      return const [];
    }

    try {
      final cached = MovimentacoesListResponseModel.fromJson(
        _movimentacoesResponseAsMap(previousCacheResponse),
      );
      return cached.abortos
          .where((aborto) => filter.id == null || aborto.id == filter.id)
          .map((aborto) => AbortoModel.fromJson(_abortoToJson(aborto)))
          .toList(growable: false);
    } catch (error, stackTrace) {
      AppLogger.error(
        'MOVIMENTACOES DATASOURCE: ERRO AO LER ABORTOS DO CACHE ANTERIOR ERROR=$error STACK=$stackTrace',
      );
      return const [];
    }
  }

  List<ConsumoModel> _cachedConsumos(
    dynamic previousCacheResponse,
    MovimentacaoFilterEntity filter,
  ) {
    if (previousCacheResponse == null) {
      return const [];
    }

    try {
      final cached = MovimentacoesListResponseModel.fromJson(
        _movimentacoesResponseAsMap(previousCacheResponse),
      );
      return cached.consumos
          .where((consumo) => filter.id == null || consumo.id == filter.id)
          .map((consumo) => ConsumoModel.fromJson(_consumoToJson(consumo)))
          .toList(growable: false);
    } catch (error, stackTrace) {
      AppLogger.error(
        'MOVIMENTACOES DATASOURCE: ERRO AO LER CONSUMOS DO CACHE ANTERIOR ERROR=$error STACK=$stackTrace',
      );
      return const [];
    }
  }

  Map<String, dynamic> _cacheResponseWithMovimentacoes(
    dynamic baseResponse,
    List<CompraEntity> compras,
    List<VendaEntity> vendas,
    List<MorteEntity> mortes,
    List<NascimentoEntity> nascimentos,
    List<TrocaCategoriaEntity> trocaCategoria,
    List<TransferenciaEntity> transferencias,
    List<AbigeatoEntity> abigeatos,
    List<AbortoEntity> abortos,
    List<ConsumoEntity> consumos,
    int rows,
  ) {
    final response = _movimentacoesResponseAsMap(baseResponse);

    response['rows'] = rows;
    response['data'] = {
      'compras': compras.map(_compraToJson).toList(growable: false),
      'vendas': vendas.map(_vendaToJson).toList(growable: false),
      'mortes': mortes.map(_morteToJson).toList(growable: false),
      'nascimentos': nascimentos.map(_nascimentoToJson).toList(growable: false),
      'troca_categoria': trocaCategoria
          .map(_trocaCategoriaToJson)
          .toList(growable: false),
      'transferencias': transferencias
          .map(_transferenciaToJson)
          .toList(growable: false),
      'abigeatos': abigeatos.map(_abigeatoToJson).toList(growable: false),
      'abortos': abortos.map(_abortoToJson).toList(growable: false),
      'consumos': consumos.map(_consumoToJson).toList(growable: false),
    };
    return response;
  }

  Map<String, dynamic> _compraToJson(CompraEntity compra) {
    return <String, dynamic>{
      'id': compra.id,
      'app_users_id': compra.appUsersId,
      'app_movimentacoes_categorias_id': compra.appMovimentacoesCategoriasId,
      'data': compra.data,
      'qtd_animais': compra.qtdAnimais,
      'peso_medio': compra.pesoMedio,
      'peso_total': compra.pesoTotal,
      'valor_total': compra.valorTotal,
      'valor_total_raw': compra.valorTotalRaw,
      'valor_unitario': compra.valorUnitario,
      'valor_unitario_raw': compra.valorUnitarioRaw,
      'municipio': compra.municipio,
      'obs': compra.obs,
      'data_cadastro': compra.dataCadastro,
      'update_at': compra.updateAt,
      'categoria_movimentacao': _referenceToJson(compra.categoriaMovimentacao),
      'animais': compra.animais
          .map(_compraAnimalToJson)
          .toList(growable: false),
      'tipo_compra': compra.tipoCompra,
      'fornecedor': compra.fornecedor,
      'app_potreiros_id': compra.appPotreirosId,
      'app_animais_lotes_id': compra.appAnimaisLotesId,
      'potreiro': _referenceToJson(compra.potreiro),
      'lote': _referenceToJson(compra.lote),
    }..removeWhere((key, value) => value == null);
  }

  Map<String, dynamic> _compraAnimalToJson(CompraAnimalEntity animal) {
    return <String, dynamic>{
      'movimentacao_animal_id': animal.movimentacaoAnimalId,
      'tipo': animal.tipo,
      'data_vinculo': animal.dataVinculo,
      'id': animal.id,
      'app_users_id': animal.appUsersId,
      'app_animais_categorias_id': animal.appAnimaisCategoriasId,
      'app_animais_subcategorias_id': animal.appAnimaisSubcategoriasId,
      'ut_bases_raciais_id': animal.utBasesRaciaisId,
      'app_animais_lotes_id': animal.appAnimaisLotesId,
      'app_potreiros_id': animal.appPotreirosId,
      'sexo': animal.sexo,
      'brinco': animal.brinco,
      'peso_total': animal.pesoTotal,
      'create_at': animal.createAt,
      'update_at': animal.updateAt,
      'obs': animal.obs,
      'status': animal.status,
      'categoria': _referenceToJson(animal.categoria),
      'subcategoria': _referenceToJson(animal.subcategoria),
      'base_racial': _referenceToJson(animal.baseRacial),
      'lote': _referenceToJson(animal.lote),
      'potreiro': _referenceToJson(animal.potreiro),
    }..removeWhere((key, value) => value == null);
  }

  Map<String, dynamic> _vendaToJson(VendaEntity venda) {
    return <String, dynamic>{
      'id': venda.id,
      'app_users_id': venda.appUsersId,
      'app_movimentacoes_categorias_id': venda.appMovimentacoesCategoriasId,
      'data': venda.data,
      'qtd_animais': venda.qtdAnimais,
      'peso_medio': venda.pesoMedio,
      'peso_total': venda.pesoTotal,
      'valor_total': venda.valorTotal,
      'valor_total_raw': venda.valorTotalRaw,
      'valor_unitario': venda.valorUnitario,
      'valor_unitario_raw': venda.valorUnitarioRaw,
      'comprador': venda.comprador,
      'municipio': venda.municipio,
      'obs': venda.obs,
      'data_cadastro': venda.dataCadastro,
      'update_at': venda.updateAt,
      'animais': venda.animais.map(_vendaAnimalToJson).toList(growable: false),
      'destinos': venda.destinos
          .map(_vendaDestinoToJson)
          .toList(growable: false),
    }..removeWhere((key, value) => value == null);
  }

  Map<String, dynamic> _vendaAnimalToJson(VendaAnimalEntity animal) {
    return <String, dynamic>{
      'movimentacao_animal_id': animal.movimentacaoAnimalId,
      'tipo': animal.tipo,
      'data_vinculo': animal.dataVinculo,
      'id': animal.id,
      'app_users_id': animal.appUsersId,
      'app_animais_categorias_id': animal.appAnimaisCategoriasId,
      'app_animais_subcategorias_id': animal.appAnimaisSubcategoriasId,
      'ut_bases_raciais_id': animal.utBasesRaciaisId,
      'app_animais_lotes_id': animal.appAnimaisLotesId,
      'app_potreiros_id': animal.appPotreirosId,
      'sexo': animal.sexo,
      'brinco': animal.brinco,
      'peso_total': animal.pesoTotal,
      'create_at': animal.createAt,
      'update_at': animal.updateAt,
      'obs': animal.obs,
      'status': animal.status,
      'categoria': _referenceToJson(animal.categoria),
      'subcategoria': _referenceToJson(animal.subcategoria),
      'base_racial': _referenceToJson(animal.baseRacial),
      'lote': _referenceToJson(animal.lote),
      'potreiro': _referenceToJson(animal.potreiro),
    }..removeWhere((key, value) => value == null);
  }

  Map<String, dynamic> _vendaDestinoToJson(VendaDestinoEntity destino) {
    return <String, dynamic>{
      'id': destino.id,
      'app_movimentacoes_id': destino.appMovimentacoesId,
      'destino': _referenceToJson(destino.destinoReference) ?? destino.destino,
      'tipo': destino.tipo,
      'data': destino.data,
    }..removeWhere((key, value) => value == null);
  }

  Map<String, dynamic> _morteToJson(MorteEntity morte) {
    return <String, dynamic>{
      'id': morte.id,
      'app_users_id': morte.appUsersId,
      'app_movimentacoes_categorias_id': morte.appMovimentacoesCategoriasId,
      'data': morte.data,
      'qtd_animais': morte.qtdAnimais,
      'peso_medio': morte.pesoMedio,
      'peso_total': morte.pesoTotal,
      'valor_total': morte.valorTotal,
      'valor_total_raw': morte.valorTotalRaw,
      'valor_unitario': morte.valorUnitario,
      'valor_unitario_raw': morte.valorUnitarioRaw,
      'municipio': morte.municipio,
      'obs': morte.obs,
      'data_cadastro': morte.dataCadastro,
      'update_at': morte.updateAt,
      'categoria_movimentacao': _referenceToJson(morte.categoriaMovimentacao),
      'animais': morte.animais.map(_morteAnimalToJson).toList(growable: false),
      'app_potreiros_id': morte.appPotreirosId,
      'potreiro': _referenceToJson(morte.potreiro),
    }..removeWhere((key, value) => value == null);
  }

  Map<String, dynamic> _morteAnimalToJson(MorteAnimalEntity animal) {
    return <String, dynamic>{
      'movimentacao_animal_id': animal.movimentacaoAnimalId,
      'tipo': animal.tipo,
      'data_vinculo': animal.dataVinculo,
      'id': animal.id,
      'app_users_id': animal.appUsersId,
      'app_animais_categorias_id': animal.appAnimaisCategoriasId,
      'app_animais_subcategorias_id': animal.appAnimaisSubcategoriasId,
      'ut_bases_raciais_id': animal.utBasesRaciaisId,
      'app_animais_lotes_id': animal.appAnimaisLotesId,
      'app_potreiros_id': animal.appPotreirosId,
      'sexo': animal.sexo,
      'brinco': animal.brinco,
      'peso_total': animal.pesoTotal,
      'create_at': animal.createAt,
      'update_at': animal.updateAt,
      'obs': animal.obs,
      'causa': animal.causa,
      'status': animal.status,
      'categoria': _referenceToJson(animal.categoria),
      'subcategoria': _referenceToJson(animal.subcategoria),
      'base_racial': _referenceToJson(animal.baseRacial),
      'lote': _referenceToJson(animal.lote),
      'potreiro': _referenceToJson(animal.potreiro),
    }..removeWhere((key, value) => value == null);
  }

  Map<String, dynamic> _nascimentoToJson(NascimentoEntity nascimento) {
    return <String, dynamic>{
      'id': nascimento.id,
      'app_users_id': nascimento.appUsersId,
      'app_movimentacoes_categorias_id':
          nascimento.appMovimentacoesCategoriasId,
      'data': nascimento.data,
      'qtd_animais': nascimento.qtdAnimais,
      'peso_medio': nascimento.pesoMedio,
      'peso_total': nascimento.pesoTotal,
      'valor_total': nascimento.valorTotal,
      'valor_total_raw': nascimento.valorTotalRaw,
      'valor_unitario': nascimento.valorUnitario,
      'valor_unitario_raw': nascimento.valorUnitarioRaw,
      'municipio': nascimento.municipio,
      'obs': nascimento.obs,
      'data_cadastro': nascimento.dataCadastro,
      'update_at': nascimento.updateAt,
      'categoria_movimentacao': _referenceToJson(
        nascimento.categoriaMovimentacao,
      ),
      'animais': nascimento.animais
          .map(_nascimentoAnimalToJson)
          .toList(growable: false),
      'app_potreiros_id': nascimento.appPotreirosId,
      'app_animais_lotes_id': nascimento.appAnimaisLotesId,
      'potreiro': _referenceToJson(nascimento.potreiro),
      'lote': _referenceToJson(nascimento.lote),
    }..removeWhere((key, value) => value == null);
  }

  Map<String, dynamic> _nascimentoAnimalToJson(NascimentoAnimalEntity animal) {
    return <String, dynamic>{
      'movimentacao_animal_id': animal.movimentacaoAnimalId,
      'tipo': animal.tipo,
      'data_vinculo': animal.dataVinculo,
      'id': animal.id,
      'app_users_id': animal.appUsersId,
      'app_animais_categorias_id': animal.appAnimaisCategoriasId,
      'app_animais_subcategorias_id': animal.appAnimaisSubcategoriasId,
      'ut_bases_raciais_id': animal.utBasesRaciaisId,
      'app_animais_lotes_id': animal.appAnimaisLotesId,
      'app_potreiros_id': animal.appPotreirosId,
      'sexo': animal.sexo,
      'brinco': animal.brinco,
      'peso_total': animal.pesoTotal,
      'create_at': animal.createAt,
      'update_at': animal.updateAt,
      'obs': animal.obs,
      'status': animal.status,
      'categoria': _referenceToJson(animal.categoria),
      'subcategoria': _referenceToJson(animal.subcategoria),
      'base_racial': _referenceToJson(animal.baseRacial),
      'lote': _referenceToJson(animal.lote),
      'potreiro': _referenceToJson(animal.potreiro),
    }..removeWhere((key, value) => value == null);
  }

  Map<String, dynamic> _trocaCategoriaToJson(TrocaCategoriaEntity troca) {
    return <String, dynamic>{
      'id': troca.id,
      'app_users_id': troca.appUsersId,
      'app_movimentacoes_categorias_id': troca.appMovimentacoesCategoriasId,
      'data': troca.data,
      'qtd_animais': troca.qtdAnimais,
      'peso_medio': troca.pesoMedio,
      'peso_total': troca.pesoTotal,
      'valor_total': troca.valorTotal,
      'valor_total_raw': troca.valorTotalRaw,
      'valor_unitario': troca.valorUnitario,
      'valor_unitario_raw': troca.valorUnitarioRaw,
      'municipio': troca.municipio,
      'obs': troca.obs,
      'data_cadastro': troca.dataCadastro,
      'update_at': troca.updateAt,
      'categoria_movimentacao': _referenceToJson(troca.categoriaMovimentacao),
      'animais': troca.animais
          .map(_movimentacaoAnimalToJson)
          .toList(growable: false),
      'app_potreiros_id': troca.appPotreirosId,
      'app_animais_lotes_id': troca.appAnimaisLotesId,
      'potreiro': _referenceToJson(troca.potreiro),
      'lote': _referenceToJson(troca.lote),
    }..removeWhere((key, value) => value == null);
  }

  Map<String, dynamic> _transferenciaToJson(TransferenciaEntity transferencia) {
    return <String, dynamic>{
      'id': transferencia.id,
      'app_users_id': transferencia.appUsersId,
      'app_movimentacoes_categorias_id':
          transferencia.appMovimentacoesCategoriasId,
      'data': transferencia.data,
      'qtd_animais': transferencia.qtdAnimais,
      'peso_medio': transferencia.pesoMedio,
      'peso_total': transferencia.pesoTotal,
      'valor_total': transferencia.valorTotal,
      'valor_total_raw': transferencia.valorTotalRaw,
      'valor_unitario': transferencia.valorUnitario,
      'valor_unitario_raw': transferencia.valorUnitarioRaw,
      'municipio': transferencia.municipio,
      'obs': transferencia.obs,
      'data_cadastro': transferencia.dataCadastro,
      'update_at': transferencia.updateAt,
      'categoria_movimentacao': _referenceToJson(
        transferencia.categoriaMovimentacao,
      ),
      'potreiro_destino': _referenceToJson(transferencia.potreiroDestino),
      'lote_destino': _referenceToJson(transferencia.loteDestino),
    }..removeWhere((key, value) => value == null);
  }

  Map<String, dynamic> _abigeatoToJson(AbigeatoEntity abigeato) {
    return <String, dynamic>{
      'id': abigeato.id,
      'app_users_id': abigeato.appUsersId,
      'app_movimentacoes_categorias_id': abigeato.appMovimentacoesCategoriasId,
      'data': abigeato.data,
      'qtd_animais': abigeato.qtdAnimais,
      'peso_medio': abigeato.pesoMedio,
      'peso_total': abigeato.pesoTotal,
      'valor_total': abigeato.valorTotal,
      'valor_total_raw': abigeato.valorTotalRaw,
      'valor_unitario': abigeato.valorUnitario,
      'valor_unitario_raw': abigeato.valorUnitarioRaw,
      'municipio': abigeato.municipio,
      'obs': abigeato.obs,
      'data_cadastro': abigeato.dataCadastro,
      'update_at': abigeato.updateAt,
      'categoria_movimentacao': _referenceToJson(
        abigeato.categoriaMovimentacao,
      ),
      'animais': abigeato.animais
          .map(_movimentacaoAnimalToJson)
          .toList(growable: false),
      'app_potreiros_id': abigeato.appPotreirosId,
      'app_animais_lotes_id': abigeato.appAnimaisLotesId,
      'potreiro': _referenceToJson(abigeato.potreiro),
      'lote': _referenceToJson(abigeato.lote),
    }..removeWhere((key, value) => value == null);
  }

  Map<String, dynamic> _abortoToJson(AbortoEntity aborto) {
    return <String, dynamic>{
      'id': aborto.id,
      'app_users_id': aborto.appUsersId,
      'app_movimentacoes_categorias_id': aborto.appMovimentacoesCategoriasId,
      'data': aborto.data,
      'qtd_animais': aborto.qtdAnimais,
      'peso_medio': aborto.pesoMedio,
      'peso_total': aborto.pesoTotal,
      'valor_total': aborto.valorTotal,
      'valor_total_raw': aborto.valorTotalRaw,
      'valor_unitario': aborto.valorUnitario,
      'valor_unitario_raw': aborto.valorUnitarioRaw,
      'municipio': aborto.municipio,
      'obs': aborto.obs,
      'data_cadastro': aborto.dataCadastro,
      'update_at': aborto.updateAt,
      'categoria_movimentacao': _referenceToJson(aborto.categoriaMovimentacao),
      'animais': aborto.animais
          .map(_movimentacaoAnimalToJson)
          .toList(growable: false),
      'app_potreiros_id': aborto.appPotreirosId,
      'app_animais_lotes_id': aborto.appAnimaisLotesId,
      'potreiro': _referenceToJson(aborto.potreiro),
      'lote': _referenceToJson(aborto.lote),
    }..removeWhere((key, value) => value == null);
  }

  Map<String, dynamic> _consumoToJson(ConsumoEntity consumo) {
    return <String, dynamic>{
      'id': consumo.id,
      'app_users_id': consumo.appUsersId,
      'app_movimentacoes_categorias_id': consumo.appMovimentacoesCategoriasId,
      'data': consumo.data,
      'qtd_animais': consumo.qtdAnimais,
      'peso_medio': consumo.pesoMedio,
      'peso_total': consumo.pesoTotal,
      'valor_total': consumo.valorTotal,
      'valor_total_raw': consumo.valorTotalRaw,
      'valor_unitario': consumo.valorUnitario,
      'valor_unitario_raw': consumo.valorUnitarioRaw,
      'municipio': consumo.municipio,
      'obs': consumo.obs,
      'data_cadastro': consumo.dataCadastro,
      'update_at': consumo.updateAt,
      'categoria_movimentacao': _referenceToJson(consumo.categoriaMovimentacao),
      'animais': consumo.animais
          .map(_movimentacaoAnimalToJson)
          .toList(growable: false),
      'potreiro': _referenceToJson(consumo.potreiro),
      'lote': _referenceToJson(consumo.lote),
    }..removeWhere((key, value) => value == null);
  }

  Map<String, dynamic> _movimentacaoAnimalToJson(dynamic animal) {
    return <String, dynamic>{
      'movimentacao_animal_id': animal.movimentacaoAnimalId,
      'tipo': animal.tipo,
      'data_vinculo': animal.dataVinculo,
      'id': animal.id,
      'app_users_id': animal.appUsersId,
      'app_animais_categorias_id': animal.appAnimaisCategoriasId,
      'app_animais_subcategorias_id': animal.appAnimaisSubcategoriasId,
      'ut_bases_raciais_id': animal.utBasesRaciaisId,
      'app_animais_lotes_id': animal.appAnimaisLotesId,
      'app_potreiros_id': animal.appPotreirosId,
      'sexo': animal.sexo,
      'brinco': animal.brinco,
      'peso_total': animal.pesoTotal,
      'create_at': animal.createAt,
      'update_at': animal.updateAt,
      'obs': animal.obs,
      if (_hasCausa(animal)) 'causa': animal.causa,
      if (_hasCategoriaDestino(animal))
        'catg_destino': _referenceToJson(animal.catgDestino),
      if (_hasCategoriaOrigem(animal))
        'catg_origem': _referenceToJson(animal.catgOrigem),
      'status': animal.status,
      'categoria': _referenceToJson(animal.categoria),
      'subcategoria': _referenceToJson(animal.subcategoria),
      'base_racial': _referenceToJson(animal.baseRacial),
      'lote': _referenceToJson(animal.lote),
      'potreiro': _referenceToJson(animal.potreiro),
    }..removeWhere((key, value) => value == null);
  }

  bool _hasCausa(dynamic animal) => animal is AbortoAnimalModel;

  bool _hasCategoriaDestino(dynamic animal) =>
      animal is TrocaCategoriaAnimalModel;

  bool _hasCategoriaOrigem(dynamic animal) =>
      animal is TrocaCategoriaAnimalModel;

  Map<String, dynamic>? _referenceToJson(MovimentacaoReferenceEntity? value) {
    if (value == null) {
      return null;
    }
    return {'id': value.id, 'nome': value.nome};
  }

  CompraModel _pendingCompraFromPayload(
    Map<String, dynamic> payload,
    String idLocal,
  ) {
    final animais = (payload['animais'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((animal) {
          return <String, dynamic>{
            ...Map<String, dynamic>.from(animal),
            'app_users_id': payload['app_users_id'],
            'app_animais_lotes_id': payload['app_animais_lotes_id'],
            'app_potreiros_id': payload['app_potreiros_id'],
            'tipo': 'compra',
          }..removeWhere((key, value) => value == null);
        })
        .toList(growable: false);

    final pesoTotal = animais.fold<double>(
      0,
      (sum, animal) => sum + (_toDouble(animal['peso_total']) ?? 0),
    );
    final valorUnitario = _toDouble(payload['valor_unitario']);
    final valorTotal = valorUnitario == null
        ? null
        : valorUnitario * animais.length;

    return CompraModel.fromJson(
      <String, dynamic>{
        'id': _localIdFromIdLocal(idLocal),
        'app_users_id': payload['app_users_id'],
        'app_movimentacoes_categorias_id': 0,
        'app_potreiros_id': payload['app_potreiros_id'],
        'app_animais_lotes_id': payload['app_animais_lotes_id'],
        'data': payload['data'],
        'tipo_compra': payload['tipo_compra'],
        'valor_unitario': payload['valor_unitario'],
        'valor_unitario_raw': valorUnitario,
        'valor_total': valorTotal?.toStringAsFixed(2),
        'valor_total_raw': valorTotal,
        'fornecedor': payload['fornecedor'],
        'municipio': payload['municipio'],
        'obs': payload['obs'],
        'qtd_animais': animais.length,
        'peso_total': pesoTotal == 0 ? null : pesoTotal,
        'peso_medio': animais.isEmpty ? null : pesoTotal / animais.length,
        'animais': animais,
      }..removeWhere((key, value) => value == null),
    );
  }

  VendaModel _pendingVendaFromPayload(
    Map<String, dynamic> payload,
    String idLocal,
  ) {
    final animais = (payload['animais'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((animal) {
          return <String, dynamic>{
            ...Map<String, dynamic>.from(animal),
            'app_users_id': payload['app_users_id'],
            'tipo': 'venda',
          }..removeWhere((key, value) => value == null);
        })
        .toList(growable: false);
    final destinos = (payload['destinos'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((destino) => Map<String, dynamic>.from(destino))
        .toList(growable: false);
    final valorUnitario = _toDouble(payload['valor_unitario']);
    final valorTotal = valorUnitario == null
        ? null
        : valorUnitario * animais.length;

    return VendaModel.fromJson(
      <String, dynamic>{
        'id': _localIdFromIdLocal(idLocal),
        'app_users_id': payload['app_users_id'],
        'app_movimentacoes_categorias_id': 0,
        'data': payload['data'],
        'valor_unitario': payload['valor_unitario'],
        'valor_unitario_raw': valorUnitario,
        'valor_total': valorTotal?.toStringAsFixed(2),
        'valor_total_raw': valorTotal,
        'comprador': payload['comprador'],
        'municipio': payload['municipio'],
        'obs': payload['obs'],
        'qtd_animais': animais.length,
        'animais': animais,
        'destinos': destinos,
      }..removeWhere((key, value) => value == null),
    );
  }

  MorteModel _pendingMorteFromPayload(
    Map<String, dynamic> payload,
    String idLocal,
  ) {
    final animais = (payload['animais'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((animal) {
          return <String, dynamic>{
            ...Map<String, dynamic>.from(animal),
            'app_users_id': payload['app_users_id'],
            'app_potreiros_id': payload['app_potreiros_id'],
            'tipo': 'morte',
          }..removeWhere((key, value) => value == null);
        })
        .toList(growable: false);
    final pesoTotal = animais.fold<double>(
      0,
      (sum, animal) => sum + (_toDouble(animal['peso_total']) ?? 0),
    );

    return MorteModel.fromJson(
      <String, dynamic>{
        'id': _localIdFromIdLocal(idLocal),
        'app_users_id': payload['app_users_id'],
        'app_movimentacoes_categorias_id': 0,
        'app_potreiros_id': payload['app_potreiros_id'],
        'data': payload['data'],
        'qtd_animais': animais.length,
        'peso_total': pesoTotal == 0 ? null : pesoTotal,
        'peso_medio': animais.isEmpty || pesoTotal == 0
            ? null
            : pesoTotal / animais.length,
        'animais': animais,
      }..removeWhere((key, value) => value == null),
    );
  }

  NascimentoModel _pendingNascimentoFromPayload(
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

    return NascimentoModel.fromJson(
      <String, dynamic>{
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
      }..removeWhere((key, value) => value == null),
    );
  }

  TrocaCategoriaModel _pendingTrocaCategoriaFromPayload(
    Map<String, dynamic> payload,
    String idLocal,
  ) {
    final animais = _pendingAnimaisFromPayload(
      payload,
      tipo: 'troca_categoria',
    );

    return TrocaCategoriaModel.fromJson(
      <String, dynamic>{
        'id': _localIdFromIdLocal(idLocal),
        'app_users_id': payload['app_users_id'],
        'app_movimentacoes_categorias_id': 0,
        'app_potreiros_id': payload['app_potreiros_id'],
        'app_animais_lotes_id': payload['app_animais_lotes_id'],
        'data': payload['data'],
        'qtd_animais': animais.length,
        'obs': payload['obs'],
        'animais': animais,
      }..removeWhere((key, value) => value == null),
    );
  }

  TransferenciaModel _pendingTransferenciaFromPayload(
    Map<String, dynamic> payload,
    String idLocal,
  ) {
    final animais = payload['tipo'] == 'animais'
        ? (payload['animais'] as List<dynamic>? ?? const [])
        : (payload['lotes'] as List<dynamic>? ?? const []);

    return TransferenciaModel.fromJson(
      <String, dynamic>{
        'id': _localIdFromIdLocal(idLocal),
        'app_users_id': payload['app_users_id'],
        'app_movimentacoes_categorias_id': 0,
        'data': payload['data'],
        'qtd_animais': animais.length,
        'obs': payload['obs'],
        'potreiro_destino': {'id': payload['potreiro_destino']},
        if (payload['lote_destino'] != null)
          'lote_destino': {'id': payload['lote_destino']},
      }..removeWhere((key, value) => value == null),
    );
  }

  AbigeatoModel _pendingAbigeatoFromPayload(
    Map<String, dynamic> payload,
    String idLocal,
  ) {
    final animais = _pendingAnimaisFromPayload(payload, tipo: 'abigeato');

    return AbigeatoModel.fromJson(
      <String, dynamic>{
        'id': _localIdFromIdLocal(idLocal),
        'app_users_id': payload['app_users_id'],
        'app_movimentacoes_categorias_id': 0,
        'data': payload['data'],
        'qtd_animais': animais.length,
        'obs': payload['obs'],
        'animais': animais,
      }..removeWhere((key, value) => value == null),
    );
  }

  AbortoModel _pendingAbortoFromPayload(
    Map<String, dynamic> payload,
    String idLocal,
  ) {
    final animais = _pendingAnimaisFromPayload(payload, tipo: 'aborto');

    return AbortoModel.fromJson(
      <String, dynamic>{
        'id': _localIdFromIdLocal(idLocal),
        'app_users_id': payload['app_users_id'],
        'app_movimentacoes_categorias_id': 0,
        'app_potreiros_id': payload['app_potreiros_id'],
        'app_animais_lotes_id': payload['app_animais_lotes_id'],
        'data': payload['data'],
        'qtd_animais': animais.length,
        'obs': payload['obs'],
        'animais': animais,
      }..removeWhere((key, value) => value == null),
    );
  }

  ConsumoModel _pendingConsumoFromPayload(
    Map<String, dynamic> payload,
    String idLocal,
  ) {
    final animais = _pendingAnimaisFromPayload(payload, tipo: 'consumo');

    return ConsumoModel.fromJson(
      <String, dynamic>{
        'id': _localIdFromIdLocal(idLocal),
        'app_users_id': payload['app_users_id'],
        'app_movimentacoes_categorias_id': 0,
        'data': payload['data'],
        'qtd_animais': animais.length,
        'obs': payload['obs'],
        'animais': animais,
      }..removeWhere((key, value) => value == null),
    );
  }

  List<Map<String, dynamic>> _pendingAnimaisFromPayload(
    Map<String, dynamic> payload, {
    required String tipo,
  }) {
    return (payload['animais'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((animal) {
          return <String, dynamic>{
            ...Map<String, dynamic>.from(animal),
            'app_users_id': payload['app_users_id'],
            'app_animais_lotes_id': payload['app_animais_lotes_id'],
            'app_potreiros_id': payload['app_potreiros_id'],
            'tipo': tipo,
          }..removeWhere((key, value) => value == null);
        })
        .toList(growable: false);
  }

  double? _toDouble(dynamic value) {
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

  Map<String, dynamic> _movimentacoesResponseAsMap(dynamic response) {
    if (response is List && response.isNotEmpty) {
      final first = response.first;
      if (first is Map) {
        final map = Map<String, dynamic>.from(first);
        final data = map['data'] is Map
            ? Map<String, dynamic>.from(map['data'] as Map)
            : <String, dynamic>{};
        final compras = [
          ...(data['compras'] as List<dynamic>? ?? const []),
          ...response.skip(1).whereType<Map>().where(_looksLikeCompraItem),
        ];
        final vendas = [
          ...(data['vendas'] as List<dynamic>? ?? const []),
          ...response.skip(1).whereType<Map>().where(_looksLikeVendaItem),
        ];
        final mortes = [
          ...(data['mortes'] as List<dynamic>? ?? const []),
          ...response.skip(1).whereType<Map>().where(_looksLikeMorteItem),
        ];
        final nascimentos = [
          ...(data['nascimentos'] as List<dynamic>? ?? const []),
          ...response.skip(1).whereType<Map>().where(_looksLikeNascimentoItem),
        ];
        final trocaCategoria = [
          ...(data['troca_categoria'] as List<dynamic>? ?? const []),
          ...response
              .skip(1)
              .whereType<Map>()
              .where(_looksLikeTrocaCategoriaItem),
        ];
        final transferencias = [
          ...(data['transferencias'] as List<dynamic>? ?? const []),
          ...response
              .skip(1)
              .whereType<Map>()
              .where(_looksLikeTransferenciaItem),
        ];
        final abigeatos = [
          ...(data['abigeatos'] as List<dynamic>? ?? const []),
          ...response.skip(1).whereType<Map>().where(_looksLikeAbigeatoItem),
        ];
        final abortos = [
          ...(data['abortos'] as List<dynamic>? ?? const []),
          ...response.skip(1).whereType<Map>().where(_looksLikeAbortoItem),
        ];
        final consumos = [
          ...(data['consumos'] as List<dynamic>? ?? const []),
          ...response.skip(1).whereType<Map>().where(_looksLikeConsumoItem),
        ];
        data['compras'] = compras;
        data['vendas'] = vendas;
        data['mortes'] = mortes;
        data['nascimentos'] = nascimentos;
        data['troca_categoria'] = trocaCategoria;
        data['transferencias'] = transferencias;
        data['abigeatos'] = abigeatos;
        data['abortos'] = abortos;
        data['consumos'] = consumos;
        map['data'] = data;
        return map;
      }
    }

    return responseAsMap(response);
  }

  bool _looksLikeCompraItem(Map<dynamic, dynamic> item) {
    return item.containsKey('tipo_compra') ||
        item.containsKey('fornecedor') ||
        (item.containsKey('app_potreiros_id') &&
            item.containsKey('app_animais_lotes_id') &&
            item.containsKey('animais') &&
            !_looksLikeNascimentoItem(item));
  }

  bool _looksLikeVendaItem(Map<dynamic, dynamic> item) {
    return item.containsKey('comprador') ||
        (item.containsKey('destinos') &&
            item.containsKey('animais') &&
            !item.containsKey('tipo_compra'));
  }

  bool _looksLikeMorteItem(Map<dynamic, dynamic> item) {
    return item.containsKey('app_potreiros_id') &&
        item.containsKey('animais') &&
        !item.containsKey('app_animais_lotes_id') &&
        !item.containsKey('tipo_compra') &&
        !item.containsKey('fornecedor') &&
        !item.containsKey('comprador') &&
        !item.containsKey('destinos');
  }

  bool _looksLikeNascimentoItem(Map<dynamic, dynamic> item) {
    return item.containsKey('app_potreiros_id') &&
        item.containsKey('app_animais_lotes_id') &&
        item.containsKey('animais') &&
        !item.containsKey('tipo_compra') &&
        !item.containsKey('fornecedor') &&
        !item.containsKey('comprador') &&
        !item.containsKey('destinos');
  }

  bool _looksLikeTrocaCategoriaItem(Map<dynamic, dynamic> item) {
    return item.containsKey('catg_destino') ||
        (item.containsKey('app_potreiros_id') &&
            item.containsKey('app_animais_lotes_id') &&
            item.containsKey('animais') &&
            item.containsKey('obs') &&
            !item.containsKey('status_destino') &&
            !item.containsKey('tipo_compra') &&
            !item.containsKey('fornecedor') &&
            !item.containsKey('comprador') &&
            !item.containsKey('destinos'));
  }

  bool _looksLikeTransferenciaItem(Map<dynamic, dynamic> item) {
    return item.containsKey('potreiro_destino') ||
        item.containsKey('lote_destino');
  }

  bool _looksLikeAbigeatoItem(Map<dynamic, dynamic> item) {
    return item.containsKey('animais') &&
        !item.containsKey('app_potreiros_id') &&
        !item.containsKey('app_animais_lotes_id') &&
        !item.containsKey('tipo_compra') &&
        !item.containsKey('fornecedor') &&
        !item.containsKey('comprador') &&
        !item.containsKey('destinos');
  }

  bool _looksLikeAbortoItem(Map<dynamic, dynamic> item) {
    return item.containsKey('status_destino') ||
        (item.containsKey('app_potreiros_id') &&
            item.containsKey('app_animais_lotes_id') &&
            item.containsKey('animais') &&
            !_looksLikeNascimentoItem(item) &&
            !_looksLikeCompraItem(item));
  }

  bool _looksLikeConsumoItem(Map<dynamic, dynamic> item) {
    return item.containsKey('animais') &&
        !item.containsKey('app_potreiros_id') &&
        !item.containsKey('app_animais_lotes_id') &&
        !item.containsKey('tipo_compra') &&
        !item.containsKey('fornecedor') &&
        !item.containsKey('comprador') &&
        !item.containsKey('destinos');
  }

  bool _isStaleLocalNascimento(
    NascimentoEntity nascimento, {
    required Set<String> activeCreateLocalIds,
  }) {
    if (nascimento.id >= 0) {
      return false;
    }

    return !activeCreateLocalIds.any(
      (idLocal) => _localIdFromIdLocal(idLocal) == nascimento.id,
    );
  }

  int _localIdFromIdLocal(String idLocal) {
    var hash = 0;
    for (final codeUnit in idLocal.codeUnits) {
      hash = (hash * 31 + codeUnit) & 0x3fffffff;
    }
    return -hash.abs();
  }
}
