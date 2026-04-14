import 'package:costeira/core/api/api_response_utils.dart';

class ApiMessage {
  const ApiMessage({
    required this.status,
    required this.message,
    this.type,
    this.extra,
  });

  final String status;
  final String message;
  final String? type;
  final dynamic extra;

  bool get isSuccess => status == '01';

  factory ApiMessage.fromResponse(dynamic data) {
    final map = responseAsMap(data);
    return ApiMessage(
      status: map['status']?.toString() ?? '',
      message: map['msg']?.toString() ?? 'Operação concluída.',
      type: map['type']?.toString(),
      extra: map['msg2'],
    );
  }
}
