import 'package:costeira/features/potreiros/domain/entities/potreiros_list_entity.dart';
import 'package:costeira/features/potreiros/infra/models/potreiro_model.dart';

class PotreirosListResponseModel extends PotreirosListEntity {
  const PotreirosListResponseModel({required super.rows, required super.data});

  factory PotreirosListResponseModel.fromJson(Map<String, dynamic> json) {
    final items = (json['data'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((item) => PotreiroModel.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);

    return PotreirosListResponseModel(
      rows: int.tryParse(json['rows']?.toString() ?? '') ?? items.length,
      data: items,
    );
  }
}
