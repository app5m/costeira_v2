import 'package:costeira/features/insumos/domain/entities/insumos.dart';

class InsumoChartsResponseModel extends InsumoChartsEntity {
  const InsumoChartsResponseModel({
    required super.quantidadePorTipo,
    required super.evolucaoMesAMes,
  });

  factory InsumoChartsResponseModel.fromJson(Map<String, dynamic> json) {
    final dataList = (json['data'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
    final data = dataList.isEmpty ? <String, dynamic>{} : dataList.first;

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
