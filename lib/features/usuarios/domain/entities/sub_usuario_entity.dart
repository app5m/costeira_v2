class SubUsuarioEntity {
  const SubUsuarioEntity({
    required this.id,
    required this.nome,
    required this.email,
    required this.celular,
    required this.farmIds,
    required this.permissionIds,
  });

  final int id;
  final String nome;
  final String email;
  final String celular;
  final List<int> farmIds;
  final List<int> permissionIds;
}
