import 'package:costeira/features/climate_and_rain/domain/entities/climate_entity.dart';

class ClimateModel extends ClimateEntity {
  const ClimateModel({
    required super.id,
    required super.appUsersId,
    required super.quantidade,
    required super.dataIn,
    required super.dataOut,
    super.createAt,
    super.updateAt,
    super.idLocal,
    super.syncStatus,
    super.pendingAction,
    super.isLocalOnly = false,
  });

  factory ClimateModel.fromJson(Map<String, dynamic> json) {
    return ClimateModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      appUsersId: int.tryParse(json['app_users_id']?.toString() ?? '') ?? 0,
      quantidade: _toDouble(json['quantidade']),
      dataIn: json['data_in']?.toString() ?? '',
      dataOut: json['data_out']?.toString() ?? '',
      createAt: json['create_at']?.toString(),
      updateAt: json['update_at']?.toString(),
      idLocal: json['idLocal']?.toString(),
      syncStatus: json['syncStatus']?.toString(),
      pendingAction: json['pendingAction']?.toString(),
      isLocalOnly: json['isLocalOnly'] == true,
    );
  }
}

double _toDouble(dynamic value) {
  return double.tryParse(value?.toString() ?? '') ?? 0;
}
