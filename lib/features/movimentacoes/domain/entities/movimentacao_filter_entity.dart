class MovimentacaoFilterEntity {
  const MovimentacaoFilterEntity({
    required this.appUsersId,
    this.appFazendasId,
    this.id,
    this.dataIn,
    this.dataOut,
  });

  final int appUsersId;
  final int? appFazendasId;
  final int? id;
  final String? dataIn;
  final String? dataOut;
}
