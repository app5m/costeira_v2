import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/core/offline/offline_api_service.dart';
import 'package:costeira/features/movimentacoes/domain/entities/movimentacao_filter_entity.dart';
import 'package:costeira/features/movimentacoes/infra/models/movimentacao_filter_request_model.dart';

class MovimentacaoOfflineCacheMutation {
  const MovimentacaoOfflineCacheMutation._();

  static OfflineCacheMutation? forEndpoint(String endpoint) {
    final listField = switch (endpoint) {
      WSConstantes.movimentacoesAdicionarCompra ||
      WSConstantes.movimentacoesExcluirCompra => 'data.compras',
      WSConstantes.movimentacoesAdicionarVenda ||
      WSConstantes.movimentacoesExcluirVenda => 'data.vendas',
      WSConstantes.movimentacoesAdicionarMorte ||
      WSConstantes.movimentacoesExcluirMorte => 'data.mortes',
      WSConstantes.movimentacoesAdicionarNascimento ||
      WSConstantes.movimentacoesExcluirNascimento => 'data.nascimentos',
      WSConstantes.movimentacoesAdicionarTrocaCategoria ||
      WSConstantes.movimentacoesExcluirTrocaCategoria => 'data.troca_categoria',
      WSConstantes.movimentacoesAdicionarTransferencia ||
      WSConstantes.movimentacoesExcluirTransferencia => 'data.transferencias',
      WSConstantes.movimentacoesAdicionarAbigeato ||
      WSConstantes.movimentacoesExcluirAbigeato => 'data.abigeatos',
      WSConstantes.movimentacoesAdicionarAborto ||
      WSConstantes.movimentacoesExcluirAborto => 'data.abortos',
      WSConstantes.movimentacoesAdicionarConsumo ||
      WSConstantes.movimentacoesExcluirConsumo => 'data.consumos',
      _ => null,
    };

    if (listField == null) {
      return null;
    }

    return OfflineCacheMutation(
      listEndpoint: WSConstantes.movimentacoesListar,
      listPayloadBuilder: _defaultListPayload,
      listField: listField,
      createCacheWhenMissing: true,
      emptyResponse: _emptyListResponse,
      allowLatestCacheFallback: false,
    );
  }

  static Map<String, dynamic> _defaultListPayload(
    Map<String, dynamic> payload,
  ) {
    final userId = int.tryParse(payload['app_users_id']?.toString() ?? '');
    if (userId == null) {
      return <String, dynamic>{};
    }

    return MovimentacaoFilterRequestModel.fromEntity(
      MovimentacaoFilterEntity(appUsersId: userId),
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
}
