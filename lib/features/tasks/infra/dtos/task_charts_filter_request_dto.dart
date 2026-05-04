import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/features/tasks/domain/entities/task_charts_filter_entity.dart';

class TaskChartsFilterRequestDto {
  const TaskChartsFilterRequestDto._(this.data);

  final Map<String, dynamic> data;

  factory TaskChartsFilterRequestDto.fromEntity(TaskChartsFilterEntity filter) {
    return TaskChartsFilterRequestDto._({
      'token': WSConstantes.token,
      if (filter.appUsersId != null) 'app_users_id': filter.appUsersId,
      if (filter.month != null) 'mes_ano': _monthPayload(filter.month!),
    });
  }
}

String _monthPayload(DateTime date) {
  return '${date.month.toString().padLeft(2, '0')}/${date.year}';
}
