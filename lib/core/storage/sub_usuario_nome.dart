String? subUsuarioNome(Map<String, dynamic> json) {
  for (final key in ['sub_usuario', 'app_sub_users']) {
    final value = json[key];
    if (value is Map) {
      final nome = value['nome']?.toString().trim();
      if (nome != null && nome.isNotEmpty) {
        return nome;
      }
    }
  }

  final flat = json['sub_usuario_nome']?.toString().trim();
  if (flat != null && flat.isNotEmpty) {
    return flat;
  }
  return null;
}
