import 'dart:convert';

class CacheKeyBuilder {
  const CacheKeyBuilder._();

  static String build({
    required String endpoint,
    Map<String, dynamic>? requestPayload,
    int? userId,
  }) {
    final normalizedPayload = _normalize(requestPayload ?? const {});
    final payloadJson = jsonEncode(normalizedPayload);
    final encodedPayload = base64Url.encode(utf8.encode(payloadJson));
    final userPart = userId?.toString() ?? 'anonymous';

    return '$userPart::$endpoint::$encodedPayload';
  }

  static dynamic _normalize(dynamic value) {
    if (value is Map) {
      final entries = value.entries.toList()
        ..sort(
          (left, right) => left.key.toString().compareTo(right.key.toString()),
        );

      return {
        for (final entry in entries)
          entry.key.toString(): _normalize(entry.value),
      };
    }

    if (value is Iterable) {
      return value.map(_normalize).toList(growable: false);
    }

    if (value is DateTime) {
      return value.toIso8601String();
    }

    return value;
  }
}
