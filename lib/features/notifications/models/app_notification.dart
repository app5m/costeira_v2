class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.rows,
  });

  final int id;
  final String title;
  final String description;
  final String date;
  final int rows;

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      title: json['titulo']?.toString() ?? '',
      description: json['descricao']?.toString() ?? '',
      date: json['data']?.toString() ?? '',
      rows: int.tryParse(json['rows']?.toString() ?? '') ?? 0,
    );
  }
}
