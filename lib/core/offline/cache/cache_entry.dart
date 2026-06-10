class CacheEntry {
  const CacheEntry({
    required this.key,
    required this.endpoint,
    required this.response,
    required this.updatedAt,
    this.requestPayload,
    this.userId,
  });

  final String key;
  final String endpoint;
  final Map<String, dynamic>? requestPayload;
  final dynamic response;
  final int? userId;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'endpoint': endpoint,
      'request_payload': requestPayload,
      'response': response,
      'user_id': userId,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory CacheEntry.fromJson(Map<String, dynamic> json) {
    return CacheEntry(
      key: json['key']?.toString() ?? '',
      endpoint: json['endpoint']?.toString() ?? '',
      requestPayload: _mapOrNull(json['request_payload']),
      response: json['response'],
      userId: int.tryParse(json['user_id']?.toString() ?? ''),
      updatedAt:
          DateTime.tryParse(json['updated_at']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  static Map<String, dynamic>? _mapOrNull(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return null;
  }
}
