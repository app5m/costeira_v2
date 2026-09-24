import 'package:costeira/core/common/get_list/domain/entities/app_menu_entity.dart';

class AppMenuModel extends AppMenuEntity {
  const AppMenuModel({
    required super.id,
    required super.name,
    required super.status,
    required super.order,
    super.permissionId,
    super.description,
    super.action,
    super.icon,
    super.children,
  });

  factory AppMenuModel.fromJson(Map<String, dynamic> json) {
    final children =
        _childList(json)
            .whereType<Map>()
            .map(
              (item) => AppMenuModel.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList(growable: false)
          ..sort((a, b) => a.order.compareTo(b.order));

    return AppMenuModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      permissionId: int.tryParse(json['app_permissoes_id']?.toString() ?? ''),
      name:
          json['nome']?.toString().trim() ??
          json['name']?.toString().trim() ??
          '',
      description: json['descricao']?.toString(),
      action: _nullableText(json['action']),
      icon: _nullableText(json['icon']),
      order: int.tryParse(json['ordem']?.toString() ?? '') ?? 0,
      status: int.tryParse(json['status']?.toString() ?? '') ?? 0,
      children: children,
    );
  }

  static List<AppMenuEntity> parseTree(dynamic raw) {
    return _rootList(raw)
        .whereType<Map>()
        .map((item) => AppMenuModel.fromJson(Map<String, dynamic>.from(item)))
        .where((item) => item.name.isNotEmpty)
        .toList(growable: false)
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  static String? _nullableText(dynamic raw) {
    final value = raw?.toString().trim() ?? '';
    if (value.isEmpty || value == 'null') {
      return null;
    }
    return value;
  }

  static List<dynamic> _rootList(dynamic raw) {
    if (raw is List) {
      return raw;
    }
    if (raw is Map) {
      final nested = raw['menus'] ?? raw['data'] ?? raw['items'];
      if (nested is List) {
        return nested;
      }
    }
    return const [];
  }

  static List<dynamic> _childList(Map<String, dynamic> json) {
    final nested =
        json['menus_n1'] ??
        json['menus_n2'] ??
        json['itens'] ??
        json['items'] ??
        json['filhos'];
    return nested is List ? nested : const [];
  }
}
