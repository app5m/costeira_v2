class FazendaUpsertEntity {
  const FazendaUpsertEntity({
    this.id,
    this.appUsersId,
    required this.mesmoCnpj,
    required this.nome,
    required this.email,
    required this.celular,
    this.tipoPessoa,
    this.documento,
    this.cnpj,
    this.razaoSocial,
    this.nomeFantasia,
    this.status,
  });

  final int? id;
  final int? appUsersId;
  final int mesmoCnpj;
  final String nome;
  final String email;
  final String celular;
  final int? tipoPessoa;
  final String? documento;
  final String? cnpj;
  final String? razaoSocial;
  final String? nomeFantasia;
  final int? status;

  FazendaUpsertEntity copyWith({int? appUsersId}) {
    return FazendaUpsertEntity(
      id: id,
      appUsersId: appUsersId ?? this.appUsersId,
      mesmoCnpj: mesmoCnpj,
      nome: nome,
      email: email,
      celular: celular,
      tipoPessoa: tipoPessoa,
      documento: documento,
      cnpj: cnpj,
      razaoSocial: razaoSocial,
      nomeFantasia: nomeFantasia,
      status: status,
    );
  }
}
