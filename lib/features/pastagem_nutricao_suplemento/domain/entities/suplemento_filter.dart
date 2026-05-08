class SuplementoFilterEntity {
  const SuplementoFilterEntity({
    required this.appUsersId,
    this.id,
    this.idPotreiro,
    this.idLote,
    this.idProduto,
  });

  final int appUsersId;
  final int? id;
  final int? idPotreiro;
  final int? idLote;
  final int? idProduto;
}
