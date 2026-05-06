import 'package:costeira/features/insumos/domain/entities/insumos.dart';
import 'package:costeira/features/insumos/infra/models/insumo_model.dart';
import 'package:costeira/features/insumos/infra/models/insumo_registro_model.dart';
import 'package:costeira/features/insumos/infra/models/insumo_reference_model.dart';

class InsumosListResponseModel extends InsumosListEntity {
  const InsumosListResponseModel({
    required super.rows,
    required super.lista,
    super.registros,
    super.suplementos,
    super.unidades,
    super.tipoInsumos,
  });

  factory InsumosListResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : <String, dynamic>{};
    final lista = _mapList(data['lista'], InsumoModel.fromJson);

    return InsumosListResponseModel(
      rows: int.tryParse(json['rows']?.toString() ?? '') ?? lista.length,
      lista: lista,
      registros: _mapList(data['registros'], InsumoRegistroModel.fromJson),
      suplementos: _mapList(data['suplementos'], InsumoReferenceModel.fromJson),
      unidades: _mapList(data['unidades'], InsumoReferenceModel.fromJson),
      tipoInsumos: _mapList(
        data['tipo_insumos'],
        InsumoReferenceModel.fromJson,
      ),
    );
  }

  static List<T> _mapList<T>(
    dynamic value,
    T Function(Map<String, dynamic>) mapper,
  ) {
    return (value as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((item) => mapper(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }
}
