import 'package:costeira/features/pastagem_nutricao_suplemento/domain/entities/suplementos_list.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/infra/models/suplemento_model.dart';

class SuplementosListResponseModel extends SuplementosListEntity {
  const SuplementosListResponseModel({
    required super.rows,
    required super.data,
  });

  factory SuplementosListResponseModel.fromJson(Map<String, dynamic> json) {
    final items = (json['data'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map(
          (item) => SuplementoModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList(growable: false);

    return SuplementosListResponseModel(
      rows: int.tryParse(json['rows']?.toString() ?? '') ?? items.length,
      data: items,
    );
  }
}
