import 'package:costeira/core/api/api_client.dart';
import 'package:costeira/core/api/api_response_utils.dart';
import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/features/dashboard/domain/entities/dashboard_filter_entity.dart';
import 'package:costeira/features/dashboard/domain/entities/dashboard_list_entity.dart';
import 'package:costeira/features/dashboard/domain/repository/dashboard_datasource.dart';
import 'package:costeira/features/dashboard/infra/models/dashboard_filter_request_model.dart';
import 'package:costeira/features/dashboard/infra/models/dashboard_response_model.dart';

class DashboardDatasourceImpl implements DashboardDatasource {
  const DashboardDatasourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<DashboardListEntity> getDashboard(DashboardFilterEntity filter) async {
    final payload = DashboardFilterRequestModel.fromEntity(filter).data;
    AppLogger.info('DASHBOARD DATASOURCE: LIST PAYLOAD=$payload');

    final response = await _apiClient.post(
      WSConstantes.dashboardListar,
      data: payload,
    );

    AppLogger.success('DASHBOARD DATASOURCE: LIST RAW RESPONSE=$response');
    return DashboardListResponseModel.fromJson(responseAsMap(response));
  }
}
