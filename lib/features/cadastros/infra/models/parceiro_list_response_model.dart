import 'package:costeira/features/cadastros/domain/entities/parceiro_list_entity.dart';
import 'package:costeira/features/cadastros/infra/models/parceiro_model.dart';

class ParceiroListResponseModel extends ParceiroListEntity {
  const ParceiroListResponseModel({required super.rows, required super.data});

  factory ParceiroListResponseModel.fromJson(Map<String, dynamic> json) {
    final items = _extractItems(
      json,
    ).map(ParceiroModel.fromJson).toList(growable: false);

    return ParceiroListResponseModel(
      rows: int.tryParse(json['rows']?.toString() ?? '') ?? items.length,
      data: items,
    );
  }

  factory ParceiroListResponseModel.fromList(List<Map<String, dynamic>> items) {
    final data = items.map(ParceiroModel.fromJson).toList(growable: false);
    return ParceiroListResponseModel(rows: data.length, data: data);
  }

  static List<Map<String, dynamic>> _extractItems(Map<String, dynamic> json) {
    final raw =
        json['data'] ??
        json['fornecedores'] ??
        json['compradores'] ??
        json['items'];
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
