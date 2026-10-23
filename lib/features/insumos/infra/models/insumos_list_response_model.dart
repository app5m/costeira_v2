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
    final listaRaw = (data['lista'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
    final lista = listaRaw
        .map(InsumoModel.fromJson)
        .toList(growable: false);

    // Nova API: registros vêm aninhados em cada item de lista.
    // Mantém fallback para data.registros (estrutura antiga).
    final registros = _collectRegistros(
      nestedFromLista: listaRaw,
      topLevel: data['registros'],
    );

    return InsumosListResponseModel(
      rows: int.tryParse(json['rows']?.toString() ?? '') ?? lista.length,
      lista: lista,
      registros: registros,
      suplementos: _mapList(data['suplementos'], InsumoReferenceModel.fromJson),
      unidades: _mapList(data['unidades'], InsumoReferenceModel.fromJson),
      tipoInsumos: _mapList(
        data['tipo_insumos'],
        InsumoReferenceModel.fromJson,
      ),
    );
  }

  static List<InsumoRegistroEntity> _collectRegistros({
    required List<Map<String, dynamic>> nestedFromLista,
    required dynamic topLevel,
  }) {
    final fromLista = <InsumoRegistroEntity>[];
    for (final item in nestedFromLista) {
      final nested = item['registros'];
      if (nested is! List) continue;
      for (final raw in nested.whereType<Map>()) {
        final map = Map<String, dynamic>.from(raw);
        map.putIfAbsent(
          'app_estoques_insumos_id',
          () => item['id'],
        );
        map.putIfAbsent(
          'estoque_nome',
          () => item['nome']?.toString() ?? '',
        );
        map.putIfAbsent(
          'tipo_insumo',
          () => item['tipo_insumo']?.toString() ?? '',
        );
        fromLista.add(InsumoRegistroModel.fromJson(map));
      }
    }
    if (fromLista.isNotEmpty) {
      return List<InsumoRegistroEntity>.unmodifiable(fromLista);
    }
    return _mapList(topLevel, InsumoRegistroModel.fromJson);
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
