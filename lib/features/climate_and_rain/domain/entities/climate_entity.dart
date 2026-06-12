class ClimateEntity {
  const ClimateEntity({
    required this.id,
    required this.appUsersId,
    required this.quantidade,
    required this.dataIn,
    required this.dataOut,
    this.createAt,
    this.updateAt,
    this.idLocal,
    this.syncStatus,
    this.pendingAction,
    this.isLocalOnly = false,
  });

  final int id;
  final int appUsersId;
  final double quantidade;
  final String dataIn;
  final String dataOut;
  final String? createAt;
  final String? updateAt;
  final String? idLocal;
  final String? syncStatus;
  final String? pendingAction;
  final bool isLocalOnly;
}
