class MovimentacaoFilterEntity {
  const MovimentacaoFilterEntity({
    required this.appUsersId,
    this.id,
    this.dataIn,
    this.dataOut,
  });

  final int appUsersId;
  final int? id;
  final String? dataIn;
  final String? dataOut;
}
