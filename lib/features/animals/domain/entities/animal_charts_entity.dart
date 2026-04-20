class AnimalChartsEntity {
  const AnimalChartsEntity({
    required this.pesoTotalRebanho,
    required this.pesoMedioFazenda,
    required this.totalUa,
    required this.quantidadeAnimais,
    required this.porCategoria,
    required this.porSexo,
    required this.distribuicaoCategoria,
    required this.proporcaoSexo,
  });

  final double pesoTotalRebanho;
  final double pesoMedioFazenda;
  final double totalUa;
  final int quantidadeAnimais;
  final List<AnimalCategoryStatEntity> porCategoria;
  final List<AnimalSexStatEntity> porSexo;
  final List<AnimalCategoryDistributionEntity> distribuicaoCategoria;
  final List<AnimalSexStatEntity> proporcaoSexo;
}

class AnimalCategoryStatEntity {
  const AnimalCategoryStatEntity({
    required this.id,
    required this.nome,
    required this.quantidade,
    required this.pesoTotal,
    required this.ua,
    required this.percentual,
  });

  final int id;
  final String nome;
  final int quantidade;
  final double pesoTotal;
  final double ua;
  final double percentual;
}

class AnimalSexStatEntity {
  const AnimalSexStatEntity({
    required this.sexo,
    required this.sexoNome,
    required this.quantidade,
    required this.percentual,
  });

  final int sexo;
  final String sexoNome;
  final int quantidade;
  final double percentual;
}

class AnimalCategoryDistributionEntity {
  const AnimalCategoryDistributionEntity({
    required this.categoria,
    required this.quantidade,
    required this.percentual,
  });

  final String categoria;
  final int quantidade;
  final double percentual;
}
