import 'package:costeira/core/api/api_client.dart';
import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/api/api_response_utils.dart';
import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/features/indicadores/domain/indicadores_lista.dart';
import 'package:costeira/features/indicadores/infra/models/indicadores_request_model.dart';
import 'package:costeira/features/indicadores/infra/models/indicadores_response_model.dart';

class IndicadoresDatasource {
  const IndicadoresDatasource(this._apiClient);

  final ApiClient _apiClient;

  Future<IndicadoresLista> listar(IndicadoresRequestModel request) async {
    final corpo = request.toJson();
    AppLogger.info('INDICADORES LISTA PAYLOAD: $corpo');
    final response = await _apiClient.post(
      WSConstantes.indicadoresLista,
      data: corpo,
    );
    final mapa = responseAsMap(response);
    final status = mapa['status']?.toString();
    if (status != null && status != '01') {
      throw ApiException(
        mapa['msg']?.toString() ?? 'Não foi possível carregar os indicadores.',
      );
    }
    return IndicadoresResponseModel.fromJson(mapa);
  }
}
