import 'package:costeira/features/dashboard/domain/entities/dashboard_filter_entity.dart';
import 'package:costeira/features/dashboard/domain/entities/dashboard_list_entity.dart';
import 'package:costeira/features/dashboard/domain/repository/dashboard_datasource.dart';

class GetDashboardUsecase {
  const GetDashboardUsecase(this._datasource);

  final DashboardDatasource _datasource;

  Future<DashboardListEntity> call(DashboardFilterEntity filter) {
    return _datasource.getDashboard(filter);
  }
}
