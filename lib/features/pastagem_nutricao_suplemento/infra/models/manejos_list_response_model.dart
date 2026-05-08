import 'package:costeira/features/pastagem_nutricao_suplemento/domain/entities/manejos_list.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/infra/models/manejo_model.dart';

class ManejosListResponseModel extends ManejosListEntity {
  const ManejosListResponseModel({
    required super.rows,
    required super.manejos,
    required super.tiposManejo,
  });

  factory ManejosListResponseModel.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>? ?? const [];
    final firstData = dataList.whereType<Map>().cast<Map>().firstOrNull;
    final data = firstData == null
        ? const <String, dynamic>{}
        : Map<String, dynamic>.from(firstData);

    final manejos = (data['lista'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((item) => ManejoModel.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);

    final tiposManejo = (data['tipos_manejo'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map(
          (item) => TipoManejoModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList(growable: false);

    return ManejosListResponseModel(
      rows: int.tryParse(json['rows']?.toString() ?? '') ?? manejos.length,
      manejos: manejos,
      tiposManejo: tiposManejo,
    );
  }
}
