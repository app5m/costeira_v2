class FazendaEntity {
  const FazendaEntity({
    required this.id,
    required this.nome,
    required this.email,
    required this.celular,
    required this.mesmoCnpj,
    required this.tipoPessoa,
    required this.documento,
    required this.cnpj,
    required this.razaoSocial,
    required this.nomeFantasia,
    required this.status,
  });

  final int id;
  final String nome;
  final String email;
  final String celular;
  final int mesmoCnpj;
  final int tipoPessoa;
  final String documento;
  final String cnpj;
  final String razaoSocial;
  final String nomeFantasia;
  final int status;

  bool get usesSameCnpj => mesmoCnpj == 1;
}
