import 'dart:io';
import 'dart:convert';

import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/core/offline/cache/api_cache_service.dart';
import 'package:costeira/core/offline/cache/api_cache_storage.dart';
import 'package:costeira/core/offline/cache/offline_mutation_cache_service.dart';
import 'package:costeira/core/offline/sync/sync_operation.dart';
import 'package:costeira/core/offline/sync/sync_status.dart';
import 'package:costeira/features/movimentacoes/infra/data/movimentacao_offline_cache_mutation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempDir;
  late Box<dynamic> box;
  late ApiCacheService apiCacheService;
  late OfflineMutationCacheService service;

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('costeira_cache_test_');
    Hive.init(tempDir.path);
    box = await Hive.openBox<dynamic>('api_cache_test');
  });

  setUp(() async {
    await box.clear();
    apiCacheService = ApiCacheService(ApiCacheStorage(box: box));
    service = OfflineMutationCacheService(apiCacheService);
  });

  tearDownAll(() async {
    await box.close();
    tempDir.deleteSync(recursive: true);
  });

  test(
    'create offline preserves filtered cache and inserts pending item',
    () async {
      const endpoint = '/tarefas/listar';
      const payload = {'app_users_id': 10, 'mes': '06/2026'};

      await apiCacheService.saveCache(
        endpoint: endpoint,
        requestPayload: payload,
        userId: 10,
        response: {
          'rows': 2,
          'data': {
            'lista': [
              {'id': 1, 'descricao': 'Vacinar'},
              {'id': 2, 'descricao': 'Revisar cerca'},
            ],
            'responsaveis': [
              {'id': 7, 'nome': 'Maria'},
            ],
          },
        },
      );

      final didMutate = await service.applyMutation(
        action: SyncOperation.create,
        listEndpoint: endpoint,
        userId: 10,
        listField: 'data.lista',
        idLocal: 'local-task-1',
        item: {'descricao': 'Comprar sal'},
      );

      final cache = apiCacheService.getCache(
        endpoint: endpoint,
        requestPayload: payload,
        userId: 10,
      );
      final response = cache!.response as Map;
      final data = response['data'] as Map;
      final lista = data['lista'] as List;
      final responsaveis = data['responsaveis'] as List;

      expect(didMutate, isTrue);
      expect(response['rows'], 3);
      expect(lista, hasLength(3));
      expect(lista[0]['descricao'], 'Comprar sal');
      expect(lista[0]['idLocal'], 'local-task-1');
      expect(lista[0]['syncStatus'], SyncStatus.pending);
      expect(lista[0]['pendingAction'], SyncOperation.create);
      expect(lista[0]['isLocalOnly'], isTrue);
      expect(lista[1]['descricao'], 'Vacinar');
      expect(lista[2]['descricao'], 'Revisar cerca');
      expect(responsaveis, hasLength(1));
    },
  );

  test('create offline can create a missing list cache', () async {
    const endpoint = '/animais/listar';
    const payload = {'token': 'token', 'app_users_id': 10};
    const filteredPayload = {
      'token': 'token',
      'app_users_id': 10,
      'brinco': 'OLD',
    };

    await apiCacheService.saveCache(
      endpoint: endpoint,
      requestPayload: filteredPayload,
      userId: 10,
      response: {
        'rows': 1,
        'data': [
          {'id': 99, 'brinco': 'OLD'},
        ],
      },
    );

    final didMutate = await service.applyMutation(
      action: SyncOperation.create,
      listEndpoint: endpoint,
      listPayload: payload,
      userId: 10,
      idLocal: 'local-animal-1',
      item: {
        'app_users_id': 10,
        'app_animais_categorias_id': 2,
        'sexo': 1,
        'brinco': 'BR-001',
      },
      createCacheWhenMissing: true,
      emptyResponse: {'rows': 0, 'data': <Map<String, dynamic>>[]},
      allowLatestCacheFallback: false,
    );

    final cache = apiCacheService.getCache(
      endpoint: endpoint,
      requestPayload: payload,
      userId: 10,
    );
    final filteredCache = apiCacheService.getCache(
      endpoint: endpoint,
      requestPayload: filteredPayload,
      userId: 10,
    );
    final response = cache!.response as Map;
    final lista = response['data'] as List;
    final filteredResponse = filteredCache!.response as Map;
    final filteredLista = filteredResponse['data'] as List;

    expect(didMutate, isTrue);
    expect(response['rows'], 1);
    expect(lista, hasLength(1));
    expect(lista.single['brinco'], 'BR-001');
    expect(lista.single['idLocal'], 'local-animal-1');
    expect(lista.single['syncStatus'], SyncStatus.pending);
    expect(lista.single['pendingAction'], SyncOperation.create);
    expect(lista.single['isLocalOnly'], isTrue);
    expect(filteredResponse['rows'], 1);
    expect(filteredLista.single['brinco'], 'OLD');
  });

  test('create offline mutates animal cache stored as json string', () async {
    const endpoint = '/animais/listar';
    const payload = {'token': 'token', 'app_users_id': 10};

    await apiCacheService.saveCache(
      endpoint: endpoint,
      requestPayload: payload,
      userId: 10,
      response: jsonEncode({
        'rows': 1,
        'data': [
          {'id': 1, 'brinco': 'OLD'},
        ],
      }),
    );

    final didMutate = await service.applyMutation(
      action: SyncOperation.create,
      listEndpoint: endpoint,
      listPayload: payload,
      userId: 10,
      idLocal: 'local-animal-string',
      item: {
        'app_users_id': 10,
        'app_animais_categorias_id': 2,
        'sexo': 1,
        'brinco': 'NEW',
      },
      allowLatestCacheFallback: false,
    );

    final cache = apiCacheService.getCache(
      endpoint: endpoint,
      requestPayload: payload,
      userId: 10,
    );
    final response = jsonDecode(cache!.response as String) as Map;
    final lista = response['data'] as List;

    expect(didMutate, isTrue);
    expect(response['rows'], 2);
    expect(lista.map((item) => item['brinco']), ['NEW', 'OLD']);
    expect(lista.first['idLocal'], 'local-animal-string');
  });

  test(
    'update and delete offline mutate animal cache wrapped in a list',
    () async {
      const endpoint = '/animais/listar';
      const payload = {'token': 'token', 'app_users_id': 10};

      await apiCacheService.saveCache(
        endpoint: endpoint,
        requestPayload: payload,
        userId: 10,
        response: [
          {
            'rows': 2,
            'data': [
              {'id': 1, 'brinco': 'A'},
              {'id': 2, 'brinco': 'B'},
            ],
          },
        ],
      );

      final didUpdate = await service.applyMutation(
        action: SyncOperation.update,
        listEndpoint: endpoint,
        listPayload: payload,
        userId: 10,
        itemId: 2,
        idLocal: 'local-animal-update',
        item: {'id': 2, 'brinco': 'B2'},
        allowLatestCacheFallback: false,
      );

      final didDelete = await service.applyMutation(
        action: SyncOperation.delete,
        listEndpoint: endpoint,
        listPayload: payload,
        userId: 10,
        itemId: 1,
        allowLatestCacheFallback: false,
      );

      final cache = apiCacheService.getCache(
        endpoint: endpoint,
        requestPayload: payload,
        userId: 10,
      );
      final wrapper = cache!.response as List;
      final response = wrapper.first as Map;
      final lista = response['data'] as List;

      expect(didUpdate, isTrue);
      expect(didDelete, isTrue);
      expect(response['rows'], 1);
      expect(lista, hasLength(1));
      expect(lista.single['id'], 2);
      expect(lista.single['brinco'], 'B2');
      expect(lista.single['syncStatus'], SyncStatus.pending);
      expect(lista.single['pendingAction'], SyncOperation.update);
    },
  );

  test('update offline changes only the matching item', () async {
    const endpoint = '/insumos/listar';
    const payload = {'app_users_id': 10, 'tipo_insumo': '1'};

    await apiCacheService.saveCache(
      endpoint: endpoint,
      requestPayload: payload,
      userId: 10,
      response: {
        'rows': 2,
        'data': {
          'lista': [
            {'id': 1, 'nome': 'Sal mineral'},
            {'id': 2, 'nome': 'Racao'},
          ],
        },
      },
    );

    final didMutate = await service.applyMutation(
      action: SyncOperation.update,
      listEndpoint: endpoint,
      userId: 10,
      listField: 'data.lista',
      itemId: 2,
      idLocal: 'local-update-1',
      item: {'id': 2, 'nome': 'Racao atualizada'},
    );

    final cache = apiCacheService.getCache(
      endpoint: endpoint,
      requestPayload: payload,
      userId: 10,
    );
    final lista = (cache!.response['data'] as Map)['lista'] as List;

    expect(didMutate, isTrue);
    expect(lista, hasLength(2));
    expect(lista[0]['nome'], 'Sal mineral');
    expect(lista[1]['nome'], 'Racao atualizada');
    expect(lista[1]['syncStatus'], SyncStatus.pending);
    expect(lista[1]['pendingAction'], SyncOperation.update);
  });

  test('delete offline removes only the matching item', () async {
    const endpoint = '/climas/listar';

    await apiCacheService.saveCache(
      endpoint: endpoint,
      requestPayload: {'app_users_id': 10},
      userId: 10,
      response: {
        'rows': 3,
        'data': [
          {'id': 1, 'data': '2026-06-10'},
          {'id': 2, 'data': '2026-06-11'},
          {'id': 3, 'data': '2026-06-12'},
        ],
      },
    );

    final didMutate = await service.applyMutation(
      action: SyncOperation.delete,
      listEndpoint: endpoint,
      userId: 10,
      itemId: 2,
    );

    final cache = apiCacheService.getLatestCacheForEndpoint(
      endpoint: endpoint,
      userId: 10,
    );
    final response = cache!.response as Map;
    final lista = response['data'] as List;

    expect(didMutate, isTrue);
    expect(response['rows'], 2);
    expect(lista.map((item) => item['id']), [1, 3]);
  });

  test('direct list cache keeps the root format when mutated', () async {
    const endpoint = '/potreiros/listar';

    await apiCacheService.saveCache(
      endpoint: endpoint,
      userId: 10,
      response: [
        {'id': 1, 'nome': 'Campo A'},
      ],
    );

    final didMutate = await service.applyMutation(
      action: SyncOperation.create,
      listEndpoint: endpoint,
      userId: 10,
      idLocal: 'local-potreiro-1',
      item: {'nome': 'Campo B'},
    );

    final cache = apiCacheService.getLatestCacheForEndpoint(
      endpoint: endpoint,
      userId: 10,
    );

    expect(didMutate, isTrue);
    expect(cache!.response, isA<List>());
    expect(cache.response, hasLength(2));
    expect(cache.response.first['nome'], 'Campo B');
    expect(cache.response.last['nome'], 'Campo A');
  });

  test('movimentacoes create mutates only the target movement list', () async {
    final payload = {'token': WSConstantes.token, 'app_users_id': 10};
    const filteredPayload = {'app_users_id': 10, 'data_in': '2026-06-01'};

    await apiCacheService.saveCache(
      endpoint: WSConstantes.movimentacoesListar,
      requestPayload: filteredPayload,
      userId: 10,
      response: {
        'rows': 1,
        'data': {
          'compras': [
            {'id': 99, 'data': '2026-06-01'},
          ],
        },
      },
    );

    await apiCacheService.saveCache(
      endpoint: WSConstantes.movimentacoesListar,
      requestPayload: payload,
      userId: 10,
      response: {
        'rows': 4,
        'data': {
          'compras': [
            {'id': 1, 'data': '2026-06-10'},
          ],
          'vendas': [
            {'id': 2, 'data': '2026-06-11'},
          ],
          'mortes': [
            {'id': 3, 'data': '2026-06-12'},
          ],
        },
      },
    );

    final mutation = MovimentacaoOfflineCacheMutation.forEndpoint(
      WSConstantes.movimentacoesAdicionarCompra,
    )!;
    final listPayload = mutation.listPayloadBuilder!.call({'app_users_id': 10});
    final didMutate = await service.applyMutation(
      action: SyncOperation.create,
      listEndpoint: mutation.listEndpoint,
      listPayload: listPayload,
      listField: mutation.listField,
      userId: 10,
      idLocal: 'local-compra-1',
      item: {'data': '2026-06-13', 'valor_total': '1000'},
      createCacheWhenMissing: mutation.createCacheWhenMissing,
      emptyResponse: mutation.emptyResponse,
      allowLatestCacheFallback: mutation.allowLatestCacheFallback,
    );

    final cache = apiCacheService.getCache(
      endpoint: WSConstantes.movimentacoesListar,
      requestPayload: payload,
      userId: 10,
    );
    final response = cache!.response as Map;
    final data = response['data'] as Map;
    final compras = data['compras'] as List;
    final vendas = data['vendas'] as List;
    final mortes = data['mortes'] as List;

    expect(didMutate, isTrue);
    expect(listPayload, payload);
    expect(response['rows'], 4);
    expect(compras, hasLength(2));
    expect(compras.first['idLocal'], 'local-compra-1');
    expect(compras.first['syncStatus'], SyncStatus.pending);
    expect(compras.first['pendingAction'], SyncOperation.create);
    expect(compras.last['id'], 1);
    expect(vendas.single['id'], 2);
    expect(mortes.single['id'], 3);

    final filteredCache = apiCacheService.getCache(
      endpoint: WSConstantes.movimentacoesListar,
      requestPayload: filteredPayload,
      userId: 10,
    );
    final filteredCompras =
        ((filteredCache!.response as Map)['data'] as Map)['compras'] as List;
    expect(filteredCompras.single['id'], 99);
  });

  test('movimentacoes create can create missing default cache', () async {
    final mutation = MovimentacaoOfflineCacheMutation.forEndpoint(
      WSConstantes.movimentacoesAdicionarConsumo,
    )!;
    final listPayload = mutation.listPayloadBuilder!.call({'app_users_id': 10});

    final didMutate = await service.applyMutation(
      action: SyncOperation.create,
      listEndpoint: mutation.listEndpoint,
      listPayload: listPayload,
      listField: mutation.listField,
      userId: 10,
      idLocal: 'local-consumo-1',
      item: {'data': '2026-06-13', 'qtd_animais': 2},
      createCacheWhenMissing: mutation.createCacheWhenMissing,
      emptyResponse: mutation.emptyResponse,
      allowLatestCacheFallback: mutation.allowLatestCacheFallback,
    );

    final cache = apiCacheService.getCache(
      endpoint: WSConstantes.movimentacoesListar,
      requestPayload: listPayload,
      userId: 10,
    );
    final data = (cache!.response as Map)['data'] as Map;
    final consumos = data['consumos'] as List;
    final compras = data['compras'] as List;

    expect(didMutate, isTrue);
    expect(consumos, hasLength(1));
    expect(consumos.single['idLocal'], 'local-consumo-1');
    expect(consumos.single['syncStatus'], SyncStatus.pending);
    expect(consumos.single['pendingAction'], SyncOperation.create);
    expect(consumos.single['isLocalOnly'], isTrue);
    expect(compras, isEmpty);
  });

  test('movimentacoes update mutates only the matching movement', () async {
    const payload = {'app_users_id': 10};
    await apiCacheService.saveCache(
      endpoint: WSConstantes.movimentacoesListar,
      requestPayload: payload,
      userId: 10,
      response: {
        'rows': 2,
        'data': {
          'compras': [
            {'id': 1, 'data': '2026-06-10'},
          ],
          'vendas': [
            {'id': 2, 'data': '2026-06-11', 'valor_total': '900'},
          ],
        },
      },
    );

    final mutation = MovimentacaoOfflineCacheMutation.forEndpoint(
      WSConstantes.movimentacoesAdicionarVenda,
    )!;
    final didMutate = await service.applyMutation(
      action: SyncOperation.update,
      listEndpoint: mutation.listEndpoint,
      listField: mutation.listField,
      userId: 10,
      itemId: 2,
      idLocal: 'local-venda-1',
      item: {'id': 2, 'valor_total': '950'},
    );

    final cache = apiCacheService.getCache(
      endpoint: WSConstantes.movimentacoesListar,
      requestPayload: payload,
      userId: 10,
    );
    final data = (cache!.response as Map)['data'] as Map;
    final compras = data['compras'] as List;
    final vendas = data['vendas'] as List;

    expect(didMutate, isTrue);
    expect(compras.single['data'], '2026-06-10');
    expect(vendas, hasLength(1));
    expect(vendas.single['id'], 2);
    expect(vendas.single['valor_total'], '950');
    expect(vendas.single['syncStatus'], SyncStatus.pending);
    expect(vendas.single['pendingAction'], SyncOperation.update);
  });

  test('movimentacoes delete removes only the matching movement', () async {
    await apiCacheService.saveCache(
      endpoint: WSConstantes.movimentacoesListar,
      requestPayload: {'app_users_id': 10},
      userId: 10,
      response: {
        'rows': 3,
        'data': {
          'transferencias': [
            {'id': 1, 'data': '2026-06-10'},
            {'id': 2, 'data': '2026-06-11'},
          ],
          'abortos': [
            {'id': 3, 'data': '2026-06-12'},
          ],
        },
      },
    );

    final mutation = MovimentacaoOfflineCacheMutation.forEndpoint(
      WSConstantes.movimentacoesExcluirTransferencia,
    )!;
    final didMutate = await service.applyMutation(
      action: SyncOperation.delete,
      listEndpoint: mutation.listEndpoint,
      listField: mutation.listField,
      userId: 10,
      itemId: 2,
    );

    final cache = apiCacheService.getLatestCacheForEndpoint(
      endpoint: WSConstantes.movimentacoesListar,
      userId: 10,
    );
    final data = (cache!.response as Map)['data'] as Map;
    final transferencias = data['transferencias'] as List;
    final abortos = data['abortos'] as List;

    expect(didMutate, isTrue);
    expect(transferencias.map((item) => item['id']), [1]);
    expect(abortos.single['id'], 3);
  });

  test('movimentacoes offline mutation maps all movement endpoints', () {
    const endpoints = [
      WSConstantes.movimentacoesAdicionarCompra,
      WSConstantes.movimentacoesExcluirCompra,
      WSConstantes.movimentacoesAdicionarVenda,
      WSConstantes.movimentacoesExcluirVenda,
      WSConstantes.movimentacoesAdicionarMorte,
      WSConstantes.movimentacoesExcluirMorte,
      WSConstantes.movimentacoesAdicionarNascimento,
      WSConstantes.movimentacoesExcluirNascimento,
      WSConstantes.movimentacoesAdicionarTrocaCategoria,
      WSConstantes.movimentacoesExcluirTrocaCategoria,
      WSConstantes.movimentacoesAdicionarTransferencia,
      WSConstantes.movimentacoesExcluirTransferencia,
      WSConstantes.movimentacoesAdicionarAbigeato,
      WSConstantes.movimentacoesExcluirAbigeato,
      WSConstantes.movimentacoesAdicionarAborto,
      WSConstantes.movimentacoesExcluirAborto,
      WSConstantes.movimentacoesAdicionarConsumo,
      WSConstantes.movimentacoesExcluirConsumo,
    ];

    for (final endpoint in endpoints) {
      final mutation = MovimentacaoOfflineCacheMutation.forEndpoint(endpoint);
      expect(mutation, isNotNull, reason: endpoint);
      expect(mutation!.listEndpoint, WSConstantes.movimentacoesListar);
      expect(mutation.listField, startsWith('data.'));
      expect(mutation.listPayloadBuilder, isNotNull);
      expect(mutation.createCacheWhenMissing, isTrue);
      expect(mutation.allowLatestCacheFallback, isFalse);
    }
  });
}
