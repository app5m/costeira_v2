class TaskDateInfoEntity {
  const TaskDateInfoEntity({required this.data, this.mesAno});

  final String data;
  final String? mesAno;

  DateTime? get dateTime => _parseApiDate(data);
}

DateTime? _parseApiDate(String value) {
  final match = RegExp(r'(\d{2})/(\d{2})/(\d{4})').firstMatch(value);
  if (match == null) {
    return null;
  }

  return DateTime(
    int.parse(match.group(3)!),
    int.parse(match.group(2)!),
    int.parse(match.group(1)!),
  );
}
