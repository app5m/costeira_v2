import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/core/offline/cache/offline_mutation_cache_service.dart';
import 'package:costeira/core/offline/sync/sync_operation.dart';
import 'package:costeira/core/offline/sync/sync_queue_service.dart';
import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/features/movimentacoes/domain/entities/movimentacao_filter_entity.dart';
import 'package:costeira/features/movimentacoes/infra/models/movimentacao_filter_request_model.dart';

class MovimentacaoOfflineDatasourceSupport {
  const MovimentacaoOfflineDatasourceSupport._();

  static const Map<String, dynamic> emptyListResponse = {
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

  static Map<String, dynamic> defaultListPayload(Map<String, dynamic> payload) {
    final userId = int.tryParse(payload['app_users_id']?.toString() ?? '');
    if (userId == null) {
      return <String, dynamic>{};
    }

    return MovimentacaoFilterRequestModel.fromEntity(
      MovimentacaoFilterEntity(appUsersId: userId),
    ).data;
  }

  static Future<ApiMessage> cancelPendingLocal({
    required SyncQueueService syncQueueService,
    required OfflineMutationCacheService mutationCacheService,
    required String createEndpoint,
    required String listField,
    required String moduleLabel,
    required int appUsersId,
    required int itemId,
    required Map<String, dynamic> payload,
  }) async {
    final pendingCreate = syncQueueService
        .getPendingItems()
        .where(
          (item) =>
              item.module == 'movimentacoes' &&
              item.action == SyncOperation.create &&
              item.endpoint == createEndpoint &&
              item.payload['app_users_id']?.toString() ==
                  appUsersId.toString() &&
              localIdFromIdLocal(item.idLocal) == itemId,
        )
        .firstOrNull;

    await mutationCacheService.applyMutation(
      action: SyncOperation.delete,
      listEndpoint: WSConstantes.movimentacoesListar,
      listPayload: defaultListPayload(payload),
      userId: appUsersId,
      itemId: itemId,
      idLocal: pendingCreate?.idLocal,
      listField: listField,
      allowLatestCacheFallback: true,
    );

    if (pendingCreate != null) {
      await syncQueueService.removeItem(pendingCreate.idLocal);
      AppLogger.success(
        '$moduleLabel DATASOURCE: ITEM LOCAL PENDENTE CANCELADO ID_LOCAL=${pendingCreate.idLocal}',
      );
    } else {
      AppLogger.warning(
        '$moduleLabel DATASOURCE: ITEM LOCAL SEM FILA REMOVIDO DO CACHE ID=$itemId',
      );
    }

    return ApiMessage(status: '01', message: '$moduleLabel local removido.');
  }

  static int localIdFromIdLocal(String idLocal) {
    var hash = 0;
    for (final codeUnit in idLocal.codeUnits) {
      hash = (hash * 31 + codeUnit) & 0x3fffffff;
    }
    return -hash.abs();
  }
}
