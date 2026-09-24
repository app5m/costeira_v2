import 'package:costeira/features/usuarios/domain/entities/usuario_permissao_entity.dart';

class UsuarioPermissaoModel extends UsuarioPermissaoEntity {
  const UsuarioPermissaoModel({
    required super.id,
    required super.nome,
    required super.funcionalidade,
    super.descricao,
    super.icon,
    super.status,
  });

  factory UsuarioPermissaoModel.fromJson(Map<String, dynamic> json) {
    return UsuarioPermissaoModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      nome: json['nome']?.toString().trim() ?? '',
      funcionalidade: json['funcionalidade']?.toString().trim() ?? '',
      descricao: _nullableText(json['descricao'] ?? json['description']),
      icon: _nullableText(json['url'] ?? json['icon'] ?? json['icone']),
      status: int.tryParse(json['status']?.toString() ?? '') ?? 1,
    );
  }

  static String? _nullableText(dynamic raw) {
    final value = raw?.toString().trim() ?? '';
    if (value.isEmpty || value == 'null') {
      return null;
    }
    return value;
  }
}
