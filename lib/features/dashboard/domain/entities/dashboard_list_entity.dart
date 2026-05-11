import 'package:costeira/features/dashboard/domain/entities/dashboard_entity.dart';

class DashboardListEntity {
  const DashboardListEntity({required this.rows, required this.data});

  final int rows;
  final List<DashboardEntity> data;

  DashboardEntity get firstOrEmpty {
    if (data.isEmpty) {
      return DashboardEntity.empty;
    }
    return data.first;
  }
}
