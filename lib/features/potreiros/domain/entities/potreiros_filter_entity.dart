class PotreirosFilterEntity {
  const PotreirosFilterEntity({
    required this.appUsersId,
    this.appFazendasId,
    this.id,
    this.statusAtual,
  });

  final int appUsersId;
  final int? appFazendasId;
  final int? id;
  final String? statusAtual;

  PotreirosFilterEntity copyWith({
    int? appUsersId,
    int? appFazendasId,
    int? id,
    String? statusAtual,
  }) {
    return PotreirosFilterEntity(
      appUsersId: appUsersId ?? this.appUsersId,
      appFazendasId: appFazendasId ?? this.appFazendasId,
      id: id ?? this.id,
      statusAtual: statusAtual ?? this.statusAtual,
    );
  }
}
