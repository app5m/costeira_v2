import 'package:costeira/core/api/api_client.dart';
import 'package:costeira/core/api/api_response_utils.dart';
import 'package:costeira/core/common/get_list/domain/entities/get_list_entity.dart';
import 'package:costeira/core/common/get_list/domain/entities/get_list_params_entity.dart';
import 'package:costeira/core/common/get_list/domain/repository/get_list_datasource.dart';
import 'package:costeira/core/common/get_list/infra/models/get_list_request_model.dart';
import 'package:costeira/core/common/get_list/infra/models/get_list_response_model.dart';
import 'package:costeira/core/config/ws_constantes.dart';

class GetListDatasourceImpl implements GetListDatasource {
  const GetListDatasourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<GetListEntity> getList(GetListParamsEntity params) async {
    final response = await _apiClient.post(
      WSConstantes.utilLista,
      data: GetListRequestModel.fromEntity(params).data,
    );

    return GetListResponseModel.fromJson(responseAsMap(response));
  }
}
