class PotreiroEntity {
  const PotreiroEntity({
    required this.id,
    required this.appUsersId,
    required this.nome,
    this.areaTotal,
    this.areaUtil,
    this.statusAtual,
    this.tipoForragem,
    this.acessoAgua,
    this.acessoSombra,
    this.lotacaoMedia,
    this.createAt,
    this.updateAt,
    this.obs,
    this.animalsCount = 0,
  });

  final int id;
  final int appUsersId;
  final String nome;
  final double? areaTotal;
  final double? areaUtil;
  final String? statusAtual;
  final String? tipoForragem;
  final String? acessoAgua;
  final String? acessoSombra;
  final double? lotacaoMedia;
  final String? createAt;
  final String? updateAt;
  final String? obs;
  final int animalsCount;
}
