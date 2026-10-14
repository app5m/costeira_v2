import 'dart:convert';

dynamic recoverEmbeddedJson(dynamic data) {
  if (data is! String) {
    return data;
  }

  final trimmed = data.trim();
  if (trimmed.isEmpty) {
    return data;
  }

  try {
    return jsonDecode(trimmed);
  } catch (_) {
    // Algumas respostas legadas imprimem warnings PHP antes do JSON.
  }

  for (var index = 0; index < trimmed.length; index++) {
    final opening = trimmed[index];
    if (opening != '[' && opening != '{') {
      continue;
    }

    final closing = opening == '[' ? ']' : '}';
    final end = trimmed.lastIndexOf(closing);
    if (end <= index) {
      continue;
    }

    try {
      return jsonDecode(trimmed.substring(index, end + 1));
    } catch (_) {
      continue;
    }
  }

  return data;
}

dynamic _normalizeResponse(dynamic data) {
  if (data is String) {
    return recoverEmbeddedJson(data);
  }

  return data;
}

Map<String, dynamic> responseAsMap(dynamic data) {
  final normalized = _normalizeResponse(data);

  if (normalized is Map<String, dynamic>) {
    return normalized;
  }

  if (normalized is Map) {
    return Map<String, dynamic>.from(normalized);
  }

  if (normalized is List &&
      normalized.isNotEmpty &&
      normalized.first is Map<String, dynamic>) {
    return Map<String, dynamic>.from(normalized.first as Map<String, dynamic>);
  }

  if (normalized is List && normalized.isNotEmpty && normalized.first is Map) {
    return Map<String, dynamic>.from(normalized.first as Map);
  }

  return <String, dynamic>{};
}

List<Map<String, dynamic>> responseAsList(dynamic data) {
  final normalized = _normalizeResponse(data);

  if (normalized is List) {
    return normalized
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
  }

  if (normalized is Map<String, dynamic>) {
    return [normalized];
  }

  if (normalized is Map) {
    return [Map<String, dynamic>.from(normalized)];
  }

  return <Map<String, dynamic>>[];
}
