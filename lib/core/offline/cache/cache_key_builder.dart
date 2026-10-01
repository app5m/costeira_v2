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
    final userPart = userId?.toString() ?? 'anonymous';

    return '$userPart::$endpoint::${_digest(payloadJson)}';
  }

  static String _digest(String value) {
    var h1 = 0x811c9dc5;
    var h2 = 0x811c9dc5;
    final bytes = utf8.encode(value);
    for (var i = 0; i < bytes.length; i++) {
      final byte = bytes[i];
      h1 = ((h1 ^ byte) * 0x01000193) & 0xFFFFFFFF;
      h2 = ((h2 ^ (byte + i)) * 0x01000193) & 0xFFFFFFFF;
    }
    return '${h1.toRadixString(16).padLeft(8, '0')}'
        '${h2.toRadixString(16).padLeft(8, '0')}';
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
