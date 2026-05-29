import 'package:costeira/features/insumos/domain/entities/insumos.dart';

class InsumoChartsResponseModel extends InsumoChartsEntity {
  const InsumoChartsResponseModel({
    required super.quantidadePorTipo,
    required super.evolucaoMesAMes,
  });

  factory InsumoChartsResponseModel.fromJson(Map<String, dynamic> json) {
    final data = _resolveChartData(json);

    return InsumoChartsResponseModel(
      quantidadePorTipo: _mapList(
        data['quantidade_por_tipo'],
        InsumoQuantidadePorTipoModel.fromJson,
      ),
      evolucaoMesAMes: _mapList(
        data['evolucao_mes_a_mes'],
        InsumoChartPointModel.fromJson,
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

Map<String, dynamic> _resolveChartData(Map<String, dynamic> json) {
  final data = json['data'];

  if (data is Map) {
    return Map<String, dynamic>.from(data);
  }

  if (data is List) {
    final first = data.whereType<Map>().firstOrNull;
    if (first != null) {
      return Map<String, dynamic>.from(first);
    }
  }

  return json;
}

class InsumoQuantidadePorTipoModel extends InsumoQuantidadePorTipoEntity {
  const InsumoQuantidadePorTipoModel({
    required super.tipoInsumo,
    required super.quantidade,
    required super.percentual,
  });

  factory InsumoQuantidadePorTipoModel.fromJson(Map<String, dynamic> json) {
    return InsumoQuantidadePorTipoModel(
      tipoInsumo: json['tipo_insumo']?.toString() ?? '',
      quantidade: double.tryParse(json['quantidade']?.toString() ?? '') ?? 0,
      percentual: double.tryParse(json['percentual']?.toString() ?? '') ?? 0,
    );
  }
}

class InsumoChartPointModel extends InsumoChartPointEntity {
  const InsumoChartPointModel({required super.label, required super.value});

  factory InsumoChartPointModel.fromJson(Map<String, dynamic> json) {
    final label =
        json['mes']?.toString() ??
        json['mes_ano']?.toString() ??
        json['label']?.toString() ??
        json['nome']?.toString() ??
        '';
    final value =
        double.tryParse(json['quantidade']?.toString() ?? '') ??
        double.tryParse(json['valor']?.toString() ?? '') ??
        double.tryParse(json['total']?.toString() ?? '') ??
        0;

    return InsumoChartPointModel(label: label, value: value);
  }
}
