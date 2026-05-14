import 'package:costeira/core/api/api_client.dart';
import 'package:costeira/core/api/api_response_utils.dart';
import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/features/movimentacoes/domain/entities/compra_charts_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/morte_charts_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/movimentacao_charts_filter_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/movimentacao_filter_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/movimentacoes_list_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/nascimento_charts_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/troca_categoria_charts_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/venda_charts_entity.dart';
import 'package:costeira/features/movimentacoes/domain/repository/movimentacoes_datasource.dart';
import 'package:costeira/features/movimentacoes/infra/models/compra_charts_response_model.dart';
import 'package:costeira/features/movimentacoes/infra/models/morte_charts_response_model.dart';
import 'package:costeira/features/movimentacoes/infra/models/movimentacao_charts_filter_request_model.dart';
import 'package:costeira/features/movimentacoes/infra/models/movimentacao_filter_request_model.dart';
import 'package:costeira/features/movimentacoes/infra/models/movimentacoes_list_response_model.dart';
import 'package:costeira/features/movimentacoes/infra/models/nascimento_charts_response_model.dart';
import 'package:costeira/features/movimentacoes/infra/models/troca_categoria_charts_response_model.dart';
import 'package:costeira/features/movimentacoes/infra/models/venda_charts_response_model.dart';

class MovimentacoesDatasourceImpl implements MovimentacoesDatasource {
  const MovimentacoesDatasourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<MovimentacoesListEntity> getMovimentacoes(
    MovimentacaoFilterEntity filter,
  ) async {
    final payload = MovimentacaoFilterRequestModel.fromEntity(filter).data;
    AppLogger.info('MOVIMENTACOES DATASOURCE: LIST PAYLOAD=$payload');

    final response = await _apiClient.post(
      WSConstantes.movimentacoesListar,
      data: payload,
    );

    AppLogger.success('MOVIMENTACOES DATASOURCE: LIST RAW RESPONSE=$response');
    return MovimentacoesListResponseModel.fromJson(responseAsMap(response));
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
}
