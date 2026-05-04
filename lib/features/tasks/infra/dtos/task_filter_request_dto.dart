import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/features/tasks/domain/entities/task_filter_entity.dart';

class TaskFilterRequestDto {
  const TaskFilterRequestDto._(this.data);

  final Map<String, dynamic> data;

  factory TaskFilterRequestDto.fromEntity(TaskFilterEntity filter) {
    return TaskFilterRequestDto._({
      'token': WSConstantes.token,
      if (filter.appUsersId != null) 'app_users_id': filter.appUsersId,
      if (filter.dataIn != null) 'data_in': _formatDate(filter.dataIn!),
      if (filter.dataOut != null) 'data_out': _formatDate(filter.dataOut!),
      if (filter.month != null) 'mes_ano': _monthPayload(filter.month!),
      if (filter.urgencia != null) 'urgencia': filter.urgencia,
      if (filter.status != null) 'status': filter.status,
    });
  }
}

String _monthPayload(DateTime date) {
  return '${date.month.toString().padLeft(2, '0')}/${date.year}';
}

String _formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';
}
