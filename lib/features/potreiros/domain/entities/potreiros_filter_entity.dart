class PotreirosFilterEntity {
  const PotreirosFilterEntity({
    required this.appUsersId,
    this.id,
    this.statusAtual,
  });

  final int appUsersId;
  final int? id;
  final String? statusAtual;

  PotreirosFilterEntity copyWith({
    int? appUsersId,
    int? id,
    String? statusAtual,
  }) {
    return PotreirosFilterEntity(
      appUsersId: appUsersId ?? this.appUsersId,
      id: id ?? this.id,
      statusAtual: statusAtual ?? this.statusAtual,
    );
  }
}
