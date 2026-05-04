import 'package:costeira/features/tasks/domain/entities/task_date_info_entity.dart';

class TaskDateInfoModel extends TaskDateInfoEntity {
  const TaskDateInfoModel({required super.data, super.mesAno});

  factory TaskDateInfoModel.fromJson(Map<String, dynamic> json) {
    return TaskDateInfoModel(
      data: json['data']?.toString() ?? '',
      mesAno: json['mes_ano']?.toString(),
    );
  }
}
