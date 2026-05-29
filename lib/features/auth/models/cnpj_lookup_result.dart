class CnpjLookupResult {
  const CnpjLookupResult({
    required this.situacaoCadastral,
    required this.nomeResponsavel,
    required this.nomeFantasia,
    required this.razaoSocial,
    required this.inscricaoEstadual,
  });

  final String situacaoCadastral;
  final String nomeResponsavel;
  final String nomeFantasia;
  final String razaoSocial;
  final String inscricaoEstadual;

  factory CnpjLookupResult.fromJson(Map<String, dynamic> json) {
    return CnpjLookupResult(
      situacaoCadastral: json['situacao_cadastral']?.toString() ?? '',
      nomeResponsavel: json['nome_responsavel']?.toString() ?? '',
      nomeFantasia: json['nome_fantasia']?.toString() ?? '',
      razaoSocial: json['razao_social']?.toString() ?? '',
      inscricaoEstadual: json['inscricao_estadual']?.toString() ?? '',
    );
  }
}
