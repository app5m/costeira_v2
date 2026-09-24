import 'package:costeira/core/api/api_response_utils.dart';
import 'package:costeira/core/common/get_list/domain/entities/get_list_entity.dart';
import 'package:costeira/core/common/get_list/domain/entities/get_list_params_entity.dart';
import 'package:costeira/core/common/get_list/domain/repository/get_list_datasource.dart';
import 'package:costeira/core/common/get_list/infra/models/get_list_request_model.dart';
import 'package:costeira/core/common/get_list/infra/models/get_list_response_model.dart';
import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/core/offline/offline_api_service.dart';
import 'package:costeira/core/utils/app_logger.dart';

class GetListDatasourceImpl implements GetListDatasource {
  const GetListDatasourceImpl(this._offlineApiService);

  final OfflineApiService _offlineApiService;

  @override
  Future<GetListEntity> getList(GetListParamsEntity params) async {
    final payload = GetListRequestModel.fromEntity(params).data;
    AppLogger.info('GET LIST DATASOURCE: PAYLOAD=$payload');

    return _offlineApiService.postCached<GetListEntity>(
      endpoint: WSConstantes.utilLista,
      payload: payload,
      userId: params.userId,
      parser: (response) =>
          GetListResponseModel.fromJson(responseAsMap(response)),
      missingCacheMessage:
          'Sem conexão e sem dados salvos para listas auxiliares.',
      rawResponseLog: 'GET LIST DATASOURCE: RAW RESPONSE',
    );
  }
}
