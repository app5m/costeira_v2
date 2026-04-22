import 'package:costeira/features/potreiros/domain/entities/potreiro_charts_entity.dart';

class PotreiroChartsLevelModel extends PotreiroChartsLevelEntity {
  const PotreiroChartsLevelModel({
    required super.nivel,
    required super.quantidade,
    required super.percentual,
  });

  factory PotreiroChartsLevelModel.fromJson(Map<String, dynamic> json) {
    return PotreiroChartsLevelModel(
      nivel: json['nivel']?.toString() ?? '',
      quantidade: int.tryParse(json['quantidade']?.toString() ?? '') ?? 0,
      percentual: _toDouble(json['percentual']),
    );
  }
}

class PotreiroAreaTableItemModel extends PotreiroAreaTableItemEntity {
  const PotreiroAreaTableItemModel({
    required super.id,
    required super.nome,
    required super.statusAtual,
    required super.acessoAgua,
    required super.acessoSombra,
    required super.areaTotal,
    required super.areaUtil,
    required super.percentualUso,
  });

  factory PotreiroAreaTableItemModel.fromJson(Map<String, dynamic> json) {
    return PotreiroAreaTableItemModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      nome: json['nome']?.toString() ?? '',
      statusAtual: json['status_atual']?.toString() ?? '',
      acessoAgua: json['acesso_agua']?.toString() ?? '',
      acessoSombra: json['acesso_sombra']?.toString() ?? '',
      areaTotal: _toDouble(json['area_total']),
      areaUtil: _toDouble(json['area_util']),
      percentualUso: _toDouble(json['percentual_uso']),
    );
  }
}

class PotreiroChartsResponseModel extends PotreiroChartsEntity {
  const PotreiroChartsResponseModel({
    required super.areaTotalSomada,
    required super.areaUtilSomada,
    required super.areaPerdida,
    required super.percentualCampoPerdido,
    required super.percentualUso,
    required super.sombra,
    required super.agua,
    required super.tabelaAreas,
  });

  factory PotreiroChartsResponseModel.fromJson(Map<String, dynamic> json) {
    return PotreiroChartsResponseModel(
      areaTotalSomada: _toDouble(json['area_total_somada']),
      areaUtilSomada: _toDouble(json['area_util_somada']),
      areaPerdida: _toDouble(json['area_perdida']),
      percentualCampoPerdido: _toDouble(json['percentual_campo_perdido']),
      percentualUso: _toDouble(json['percentual_uso']),
      sombra: (json['sombra'] as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map(
            (item) => PotreiroChartsLevelModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(growable: false),
      agua: (json['agua'] as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map(
            (item) => PotreiroChartsLevelModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(growable: false),
      tabelaAreas: (json['tabela_areas'] as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map(
            (item) => PotreiroAreaTableItemModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(growable: false),
    );
  }
}

double _toDouble(dynamic value) {
  return double.tryParse(value?.toString() ?? '') ?? 0;
}
