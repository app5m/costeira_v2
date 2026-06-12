class AnimalLotEntity {
  const AnimalLotEntity({
    required this.id,
    required this.appUsersId,
    required this.nome,
    this.appPotreirosId,
    this.createAt,
    this.updateAt,
    this.animalsCount = 0,
    this.idLocal,
    this.syncStatus,
    this.pendingAction,
    this.isLocalOnly = false,
  });

  final int id;
  final int appUsersId;
  final String nome;
  final int? appPotreirosId;
  final String? createAt;
  final String? updateAt;
  final int animalsCount;
  final String? idLocal;
  final String? syncStatus;
  final String? pendingAction;
  final bool isLocalOnly;
}
