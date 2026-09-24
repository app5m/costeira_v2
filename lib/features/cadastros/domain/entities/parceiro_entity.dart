class ParceiroEntity {
  const ParceiroEntity({
    required this.id,
    required this.appFazendasId,
    required this.tipoPessoa,
    required this.nome,
    required this.email,
    required this.celular,
    required this.documento,
    required this.cnpj,
    required this.razaoSocial,
    required this.nomeFantasia,
    required this.endereco,
    required this.numero,
    required this.complemento,
  });

  final int id;
  final int appFazendasId;
  final int tipoPessoa;
  final String nome;
  final String email;
  final String celular;
  final String documento;
  final String cnpj;
  final String razaoSocial;
  final String nomeFantasia;
  final String endereco;
  final String numero;
  final String complemento;

  bool get isPessoaFisica => tipoPessoa == 1;
}
