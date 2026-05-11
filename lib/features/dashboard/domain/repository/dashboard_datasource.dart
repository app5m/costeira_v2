import 'package:costeira/features/dashboard/domain/entities/dashboard_filter_entity.dart';
import 'package:costeira/features/dashboard/domain/entities/dashboard_list_entity.dart';

abstract class DashboardDatasource {
  Future<DashboardListEntity> getDashboard(DashboardFilterEntity filter);
}
