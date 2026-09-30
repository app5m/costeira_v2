import 'package:costeira/core/api/api_response_utils.dart';
import 'package:costeira/core/utils/app_logger.dart';

class ApiMessage {
  const ApiMessage({
    required this.status,
    required this.message,
    this.type,
    this.extra,
    this.resourceId,
  });

  final String status;
  final String message;
  final String? type;
  final dynamic extra;
  final int? resourceId;

  bool get isSuccess => status == '01';

  factory ApiMessage.fromResponse(dynamic data) {
    final map = responseAsMap(data);

    if (map.isEmpty) {
      AppLogger.warning(
        'API MESSAGE: RESPOSTA VAZIA OU NAO MAPEAVEL, ASSUMINDO SUCESSO PADRAO',
      );
      return const ApiMessage(status: '01', message: 'Operação concluída.');
    }

    final status = map['status']?.toString() ?? '';
    final message = map['msg']?.toString() ?? 'Operação concluída.';

    AppLogger.debug(
      'API MESSAGE: STATUS=${status.isEmpty ? '01' : status} MESSAGE=$message RAW_MAP=$map',
    );

    return ApiMessage(
      status: status.isEmpty ? '01' : status,
      message: message,
      type: map['type']?.toString(),
      extra: map['msg2'],
      resourceId: _resourceId(map),
    );
  }

  static int? _resourceId(Map<String, dynamic> map) {
    final direct = int.tryParse(map['id']?.toString() ?? '');
    if (direct != null && direct > 0) {
      return direct;
    }

    for (final key in ['data', 'msg2', 'insumo']) {
      final value = map[key];
      if (value is! Map) {
        continue;
      }
      for (final idKey in ['id', 'insumo_id', 'app_estoques_insumos_id']) {
        final id = int.tryParse(value[idKey]?.toString() ?? '');
        if (id != null && id > 0) {
          return id;
        }
      }
    }

    return null;
  }
}
