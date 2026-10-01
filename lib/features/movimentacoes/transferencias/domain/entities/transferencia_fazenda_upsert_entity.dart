class TransferenciaFazendaAnimalEntity {
  const TransferenciaFazendaAnimalEntity({required this.id});

  final int id;
}

class TransferenciaFazendaUpsertEntity {
  const TransferenciaFazendaUpsertEntity({
    this.id,
    this.appUsersId,
    this.appFazendasId,
    this.idCategoria = 9,
    this.idFazendaOrigem,
    required this.idFazendaDestino,
    required this.valorUnitario,
    required this.valorTotal,
    required this.data,
    this.gtaDocumento,
    this.animais = const [],
  });

  final int? id;
  final int? appUsersId;
  final int? appFazendasId;
  final int idCategoria;
  final int? idFazendaOrigem;
  final int idFazendaDestino;
  final String valorUnitario;
  final String valorTotal;
  final String data;
  final String? gtaDocumento;
  final List<TransferenciaFazendaAnimalEntity> animais;

  TransferenciaFazendaUpsertEntity copyWith({
    int? id,
    int? appUsersId,
    int? appFazendasId,
    int? idCategoria,
    int? idFazendaOrigem,
    int? idFazendaDestino,
    String? valorUnitario,
    String? valorTotal,
    String? data,
    String? gtaDocumento,
    List<TransferenciaFazendaAnimalEntity>? animais,
  }) {
    return TransferenciaFazendaUpsertEntity(
      id: id ?? this.id,
      appUsersId: appUsersId ?? this.appUsersId,
      appFazendasId: appFazendasId ?? this.appFazendasId,
      idCategoria: idCategoria ?? this.idCategoria,
      idFazendaOrigem: idFazendaOrigem ?? this.idFazendaOrigem,
      idFazendaDestino: idFazendaDestino ?? this.idFazendaDestino,
      valorUnitario: valorUnitario ?? this.valorUnitario,
      valorTotal: valorTotal ?? this.valorTotal,
      data: data ?? this.data,
      gtaDocumento: gtaDocumento ?? this.gtaDocumento,
      animais: animais ?? this.animais,
    );
  }
}
