import 'package:costeira/features/pastagem_nutricao_suplemento/domain/entities/manejo.dart';

class ManejoChartsResponseModel extends ManejoChartsEntity {
  const ManejoChartsResponseModel({
    required super.manejosPorPotreiro,
    required super.manejosTipoPotreiroMes,
  });

  factory ManejoChartsResponseModel.fromJson(Map<String, dynamic> json) {
    final manejosPorPotreiro =
        (json['manejos_por_potreiro'] as List<dynamic>? ?? const [])
            .whereType<Map>()
            .map(
              (item) => ManejoPorPotreiroModel.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList(growable: false);

    final manejosTipoPotreiroMes =
        (json['manejos_tipo_potreiro_mes'] as List<dynamic>? ?? const [])
            .whereType<Map>()
            .map(
              (item) => ManejoTipoPotreiroMesModel.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList(growable: false);

    return ManejoChartsResponseModel(
      manejosPorPotreiro: manejosPorPotreiro,
      manejosTipoPotreiroMes: manejosTipoPotreiroMes,
    );
  }
}

class ManejoPorPotreiroModel extends ManejoPorPotreiroEntity {
  const ManejoPorPotreiroModel({
    required super.appPotreirosId,
    required super.potreiroNome,
    required super.quantidade,
  });

  factory ManejoPorPotreiroModel.fromJson(Map<String, dynamic> json) {
    return ManejoPorPotreiroModel(
      appPotreirosId: _asInt(json['app_potreiros_id']),
      potreiroNome: json['potreiro_nome']?.toString() ?? '',
      quantidade: _asDouble(json['quantidade']) ?? 0,
    );
  }
}

class ManejoTipoPotreiroMesModel extends ManejoTipoPotreiroMesEntity {
  const ManejoTipoPotreiroMesModel({
    required super.ano,
    required super.mes,
    required super.appPotreirosId,
    required super.potreiroNome,
    required super.tipoManejo,
    required super.quantidade,
  });

  factory ManejoTipoPotreiroMesModel.fromJson(Map<String, dynamic> json) {
    return ManejoTipoPotreiroMesModel(
      ano: _asInt(json['ano']),
      mes: _asInt(json['mes']),
      appPotreirosId: _asInt(json['app_potreiros_id']),
      potreiroNome: json['potreiro_nome']?.toString() ?? '',
      tipoManejo: json['tipo_manejo']?.toString() ?? '',
      quantidade: _asDouble(json['quantidade']) ?? 0,
    );
  }
}

int _asInt(dynamic value) => int.tryParse(value?.toString() ?? '') ?? 0;

double? _asDouble(dynamic value) {
  if (value == null) return null;
  return double.tryParse(value.toString().replaceAll(',', '.'));
}
