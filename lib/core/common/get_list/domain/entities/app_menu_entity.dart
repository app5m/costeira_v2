class AppMenuEntity {
  const AppMenuEntity({
    required this.id,
    required this.name,
    required this.status,
    required this.order,
    this.permissionId,
    this.description,
    this.action,
    this.icon,
    this.children = const [],
  });

  final int id;
  final int? permissionId;
  final String name;
  final String? description;
  final String? action;
  final String? icon;
  final int order;
  final int status;
  final List<AppMenuEntity> children;

  bool get isEnabled => status == 1;

  AppMenuEntity copyWith({List<AppMenuEntity>? children}) {
    return AppMenuEntity(
      id: id,
      permissionId: permissionId,
      name: name,
      description: description,
      action: action,
      icon: icon,
      order: order,
      status: status,
      children: children ?? this.children,
    );
  }
}
