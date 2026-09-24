class UsuarioPermissaoEntity {
  const UsuarioPermissaoEntity({
    required this.id,
    required this.nome,
    required this.funcionalidade,
    this.descricao,
    this.icon,
    this.status = 1,
  });

  final int id;
  final String nome;
  final String funcionalidade;
  final String? descricao;
  final String? icon;
  final int status;

  bool get isEnabled => status == 1;
}
