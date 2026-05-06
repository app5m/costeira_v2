import 'package:costeira/features/insumos/domain/entities/insumos.dart';
import 'package:costeira/features/insumos/infra/models/insumo_tipo_model.dart';

class InsumosTipoListResponseModel extends InsumosTipoListEntity {
  const InsumosTipoListResponseModel({
    required super.rows,
    required super.data,
  });

  factory InsumosTipoListResponseModel.fromJson(Map<String, dynamic> json) {
    final items = (json['data'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map(
          (item) => InsumoTipoModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList(growable: false);

    return InsumosTipoListResponseModel(
      rows: int.tryParse(json['rows']?.toString() ?? '') ?? items.length,
      data: items,
    );
  }
}
