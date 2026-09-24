class SubUsuarioUpsertEntity {
  const SubUsuarioUpsertEntity({
    this.id,
    required this.ownerUserId,
    required this.nome,
    required this.email,
    required this.celular,
    required this.farmIds,
    required this.permissionIds,
  });

  final int? id;
  final int ownerUserId;
  final String nome;
  final String email;
  final String celular;
  final List<int> farmIds;
  final List<int> permissionIds;
}
