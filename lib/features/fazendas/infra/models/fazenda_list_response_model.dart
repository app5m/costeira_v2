import 'package:costeira/features/fazendas/domain/entities/fazenda_list_entity.dart';
import 'package:costeira/features/fazendas/infra/models/fazenda_model.dart';

class FazendaListResponseModel extends FazendaListEntity {
  const FazendaListResponseModel({required super.rows, required super.data});

  factory FazendaListResponseModel.fromJson(Map<String, dynamic> json) {
    final items = _extractItems(
      json,
    ).map(FazendaModel.fromJson).toList(growable: false);

    return FazendaListResponseModel(
      rows: int.tryParse(json['rows']?.toString() ?? '') ?? items.length,
      data: items,
    );
  }

  factory FazendaListResponseModel.fromList(List<Map<String, dynamic>> items) {
    final data = items.map(FazendaModel.fromJson).toList(growable: false);
    return FazendaListResponseModel(rows: data.length, data: data);
  }

  static List<Map<String, dynamic>> _extractItems(Map<String, dynamic> json) {
    final raw = json['data'] ?? json['fazendas'] ?? json['items'];
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList(growable: false);
    }
    if (raw is Map) {
      final nested = raw['data'];
      if (nested is List) {
        return nested
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList(growable: false);
      }
    }
    return const [];
  }
}
