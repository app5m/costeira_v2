import 'package:costeira/features/animals/domain/entities/animal_charts_entity.dart';

class AnimalChartsResponseModel extends AnimalChartsEntity {
  const AnimalChartsResponseModel({
    required super.pesoTotalRebanho,
    required super.pesoMedioFazenda,
    required super.totalUa,
    required super.quantidadeAnimais,
    required super.porCategoria,
    required super.porSexo,
    required super.distribuicaoCategoria,
    required super.proporcaoSexo,
  });

  factory AnimalChartsResponseModel.fromJson(Map<String, dynamic> json) {
    final porCategoria = (json['por_categoria'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map(
          (item) =>
              AnimalCategoryStatModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList(growable: false);
    final porSexo = (json['por_sexo'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map(
          (item) =>
              AnimalSexStatModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList(growable: false);
    final distribuicaoCategoria =
        (json['distribuicao_categoria'] as List<dynamic>? ?? const [])
            .whereType<Map>()
            .map(
              (item) => AnimalCategoryDistributionModel.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList(growable: false);
    final proporcaoSexo = (json['proporcao_sexo'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map(
          (item) =>
              AnimalSexStatModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList(growable: false);
    final quantidadeAnimais = _firstPositive([
      _toInt(json['quantidade_animais']),
      _sumSexStats(proporcaoSexo),
      _sumSexStats(porSexo),
      _sumCategoryStats(porCategoria),
      _sumDistributionStats(distribuicaoCategoria),
    ]);

    return AnimalChartsResponseModel(
      pesoTotalRebanho: _toDouble(json['peso_total_rebanho']),
      pesoMedioFazenda: _toDouble(json['peso_medio_fazenda']),
      totalUa: _toDouble(json['total_ua']),
      quantidadeAnimais: quantidadeAnimais,
      porCategoria: porCategoria,
      porSexo: porSexo,
      distribuicaoCategoria: distribuicaoCategoria,
      proporcaoSexo: proporcaoSexo,
    );
  }
}

class AnimalCategoryStatModel extends AnimalCategoryStatEntity {
  const AnimalCategoryStatModel({
    required super.id,
    required super.nome,
    required super.quantidade,
    required super.pesoTotal,
    required super.ua,
    required super.percentual,
  });

  factory AnimalCategoryStatModel.fromJson(Map<String, dynamic> json) {
    return AnimalCategoryStatModel(
      id: _toInt(json['id']),
      nome: (json['nome']?.toString() ?? '').trim(),
      quantidade: _toInt(json['quantidade']),
      pesoTotal: _toDouble(json['peso_total']),
      ua: _toDouble(json['ua']),
      percentual: _toDouble(json['percentual']),
    );
  }
}

class AnimalSexStatModel extends AnimalSexStatEntity {
  const AnimalSexStatModel({
    required super.sexo,
    required super.sexoNome,
    required super.quantidade,
    required super.percentual,
  });

  factory AnimalSexStatModel.fromJson(Map<String, dynamic> json) {
    return AnimalSexStatModel(
      sexo: _toInt(json['sexo']),
      sexoNome: json['sexo_nome']?.toString() ?? '',
      quantidade: _toInt(json['quantidade']),
      percentual: _toDouble(json['percentual']),
    );
  }
}

class AnimalCategoryDistributionModel extends AnimalCategoryDistributionEntity {
  const AnimalCategoryDistributionModel({
    required super.categoria,
    required super.quantidade,
    required super.percentual,
  });

  factory AnimalCategoryDistributionModel.fromJson(Map<String, dynamic> json) {
    return AnimalCategoryDistributionModel(
      categoria: json['categoria']?.toString() ?? '',
      quantidade: _toInt(json['quantidade']),
      percentual: _toDouble(json['percentual']),
    );
  }
}

double _toDouble(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0;
}

int _toInt(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString()) ?? 0;
}

int _firstPositive(List<int> values) {
  for (final value in values) {
    if (value > 0) {
      return value;
    }
  }
  return 0;
}

int _sumSexStats(List<AnimalSexStatEntity> items) {
  return items.fold<int>(0, (sum, item) => sum + item.quantidade);
}

int _sumCategoryStats(List<AnimalCategoryStatEntity> items) {
  return items.fold<int>(0, (sum, item) => sum + item.quantidade);
}

int _sumDistributionStats(List<AnimalCategoryDistributionEntity> items) {
  return items.fold<int>(0, (sum, item) => sum + item.quantidade);
}
