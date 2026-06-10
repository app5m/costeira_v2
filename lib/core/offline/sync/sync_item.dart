import 'package:costeira/core/offline/sync/sync_status.dart';

class SyncItem {
  const SyncItem({
    required this.idLocal,
    required this.module,
    required this.action,
    required this.endpoint,
    required this.payload,
    required this.status,
    required this.attempts,
    required this.priority,
    required this.createdAt,
    required this.updatedAt,
    this.error,
  });

  final String idLocal;
  final String module;
  final String action;
  final String endpoint;
  final Map<String, dynamic> payload;
  final String status;
  final int attempts;
  final String? error;
  final int priority;
  final DateTime createdAt;
  final DateTime updatedAt;

  SyncItem copyWith({
    String? idLocal,
    String? module,
    String? action,
    String? endpoint,
    Map<String, dynamic>? payload,
    String? status,
    int? attempts,
    String? error,
    int? priority,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SyncItem(
      idLocal: idLocal ?? this.idLocal,
      module: module ?? this.module,
      action: action ?? this.action,
      endpoint: endpoint ?? this.endpoint,
      payload: payload ?? this.payload,
      status: status ?? this.status,
      attempts: attempts ?? this.attempts,
      error: error,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_local': idLocal,
      'module': module,
      'action': action,
      'endpoint': endpoint,
      'payload': payload,
      'status': status,
      'attempts': attempts,
      'error': error,
      'priority': priority,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory SyncItem.fromJson(Map<String, dynamic> json) {
    return SyncItem(
      idLocal: json['id_local']?.toString() ?? json['id']?.toString() ?? '',
      module: json['module']?.toString() ?? '',
      action: json['action']?.toString() ?? '',
      endpoint: json['endpoint']?.toString() ?? '',
      payload: _mapFrom(json['payload']),
      status: json['status']?.toString() ?? SyncStatus.pending,
      attempts: int.tryParse(json['attempts']?.toString() ?? '') ?? 0,
      error: json['error']?.toString(),
      priority: int.tryParse(json['priority']?.toString() ?? '') ?? 0,
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt:
          DateTime.tryParse(json['updated_at']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  static Map<String, dynamic> _mapFrom(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return <String, dynamic>{};
  }
}
