import 'package:costeira/features/usuarios/domain/entities/sub_usuario_entity.dart';

class SubUsuarioModel extends SubUsuarioEntity {
  const SubUsuarioModel({
    required super.id,
    required super.nome,
    required super.email,
    required super.celular,
    required super.farmIds,
    required super.permissionIds,
  });

  factory SubUsuarioModel.fromJson(Map<String, dynamic> json) {
    return SubUsuarioModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      nome:
          json['nome']?.toString().trim() ??
          json['name']?.toString().trim() ??
          '',
      email: json['email']?.toString().trim() ?? '',
      celular:
          json['celular']?.toString().trim() ??
          json['telefone']?.toString().trim() ??
          '',
      farmIds: _intList(
        json['id_vinculo_fazenda'] ??
            json['fazendas'] ??
            json['app_fazendas_id'],
      ),
      permissionIds: _intList(json['permissoes'] ?? json['app_permissoes_id']),
    );
  }

  static List<int> _intList(dynamic raw) {
    if (raw is List) {
      return raw
          .map((item) {
            if (item is Map) {
              return int.tryParse(item['id']?.toString() ?? '') ?? 0;
            }
            return int.tryParse(item.toString()) ?? 0;
          })
          .where((id) => id > 0)
          .toList(growable: false);
    }
    final single = int.tryParse(raw?.toString() ?? '') ?? 0;
    return single > 0 ? [single] : const [];
  }
}
