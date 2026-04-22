class PotreiroChartsLevelEntity {
  const PotreiroChartsLevelEntity({
    required this.nivel,
    required this.quantidade,
    required this.percentual,
  });

  final String nivel;
  final int quantidade;
  final double percentual;
}

class PotreiroAreaTableItemEntity {
  const PotreiroAreaTableItemEntity({
    required this.id,
    required this.nome,
    required this.statusAtual,
    required this.acessoAgua,
    required this.acessoSombra,
    required this.areaTotal,
    required this.areaUtil,
    required this.percentualUso,
  });

  final int id;
  final String nome;
  final String statusAtual;
  final String acessoAgua;
  final String acessoSombra;
  final double areaTotal;
  final double areaUtil;
  final double percentualUso;
}

class PotreiroChartsEntity {
  const PotreiroChartsEntity({
    required this.areaTotalSomada,
    required this.areaUtilSomada,
    required this.areaPerdida,
    required this.percentualCampoPerdido,
    required this.percentualUso,
    required this.sombra,
    required this.agua,
    required this.tabelaAreas,
  });

  final double areaTotalSomada;
  final double areaUtilSomada;
  final double areaPerdida;
  final double percentualCampoPerdido;
  final double percentualUso;
  final List<PotreiroChartsLevelEntity> sombra;
  final List<PotreiroChartsLevelEntity> agua;
  final List<PotreiroAreaTableItemEntity> tabelaAreas;
}
