class RegisterDraft {
  const RegisterDraft({
    this.tipoPessoa = 2,
    this.nome = '',
    this.celular = '',
    this.email = '',
    this.documento = '',
    this.cnpj = '',
    this.razaoSocial = '',
    this.nomeFantasia = '',
    this.ie = '',
    this.password = '',
  });

  final int tipoPessoa;
  final String nome;
  final String celular;
  final String email;
  final String documento;
  final String cnpj;
  final String razaoSocial;
  final String nomeFantasia;
  final String ie;
  final String password;

  RegisterDraft copyWith({
    int? tipoPessoa,
    String? nome,
    String? celular,
    String? email,
    String? documento,
    String? cnpj,
    String? razaoSocial,
    String? nomeFantasia,
    String? ie,
    String? password,
  }) {
    return RegisterDraft(
      tipoPessoa: tipoPessoa ?? this.tipoPessoa,
      nome: nome ?? this.nome,
      celular: celular ?? this.celular,
      email: email ?? this.email,
      documento: documento ?? this.documento,
      cnpj: cnpj ?? this.cnpj,
      razaoSocial: razaoSocial ?? this.razaoSocial,
      nomeFantasia: nomeFantasia ?? this.nomeFantasia,
      ie: ie ?? this.ie,
      password: password ?? this.password,
    );
  }
}
