import 'package:costeira/config/ws_constantes.dart';
import 'package:costeira/core/api/api_client.dart';
import 'package:costeira/core/api/api_response_utils.dart';
import 'package:costeira/features/notifications/models/app_notification.dart';

class NotificationsRepository {
  NotificationsRepository({ApiClient? client})
    : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  Future<List<AppNotification>> fetchNotifications(int userId) async {
    final response = await _client.post(
      WSConstantes.notificacoes,
      data: {'id': userId, 'token': WSConstantes.token},
    );

    final list = responseAsList(response);
    return list.map(AppNotification.fromJson).toList(growable: false);
  }
}
