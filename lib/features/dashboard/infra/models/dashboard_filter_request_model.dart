import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/features/dashboard/domain/entities/dashboard_filter_entity.dart';

class DashboardFilterRequestModel {
  const DashboardFilterRequestModel._(this.data);

  final Map<String, dynamic> data;

  factory DashboardFilterRequestModel.fromEntity(DashboardFilterEntity filter) {
    return DashboardFilterRequestModel._({
      'token': WSConstantes.token,
      'app_users_id': filter.appUsersId,
      'data_in': _formatDate(filter.dataIn),
      'data_out': _formatDate(filter.dataOut),
    });
  }
}

String _formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year.toString().padLeft(4, '0')}';
}
