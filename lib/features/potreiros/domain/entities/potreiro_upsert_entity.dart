class PotreiroUpsertEntity {
  const PotreiroUpsertEntity({
    this.id,
    this.appUsersId,
    required this.nome,
    this.areaTotal,
    this.areaUtil,
    this.statusAtual,
    this.tipoForragem,
    this.acessoAgua,
    this.acessoSombra,
    this.lotacaoMedia,
    this.obs,
  });

  final int? id;
  final int? appUsersId;
  final String nome;
  final String? areaTotal;
  final String? areaUtil;
  final String? statusAtual;
  final String? tipoForragem;
  final String? acessoAgua;
  final String? acessoSombra;
  final String? lotacaoMedia;
  final String? obs;

  PotreiroUpsertEntity copyWith({
    int? id,
    int? appUsersId,
    String? nome,
    String? areaTotal,
    String? areaUtil,
    String? statusAtual,
    String? tipoForragem,
    String? acessoAgua,
    String? acessoSombra,
    String? lotacaoMedia,
    String? obs,
  }) {
    return PotreiroUpsertEntity(
      id: id ?? this.id,
      appUsersId: appUsersId ?? this.appUsersId,
      nome: nome ?? this.nome,
      areaTotal: areaTotal ?? this.areaTotal,
      areaUtil: areaUtil ?? this.areaUtil,
      statusAtual: statusAtual ?? this.statusAtual,
      tipoForragem: tipoForragem ?? this.tipoForragem,
      acessoAgua: acessoAgua ?? this.acessoAgua,
      acessoSombra: acessoSombra ?? this.acessoSombra,
      lotacaoMedia: lotacaoMedia ?? this.lotacaoMedia,
      obs: obs ?? this.obs,
    );
  }
}
