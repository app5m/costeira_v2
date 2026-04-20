import 'dart:async';
import 'dart:io';

import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class PushTokenService {
  PushTokenService._();

  static final PushTokenService instance = PushTokenService._();

  StreamSubscription<String>? _tokenSubscription;

  Future<void> initialize() async {
    final messaging = FirebaseMessaging.instance;

    try {
      final token = await messaging.getToken();
      if (token != null && token.isNotEmpty) {
        await SessionStorage.savePendingPushToken(token);
      }
    } catch (_) {
      // Não interrompemos o app se o token falhar aqui.
    }

    _tokenSubscription ??= messaging.onTokenRefresh.listen((token) async {
      if (token.isNotEmpty) {
        await SessionStorage.savePendingPushToken(token);
      }
    });
  }

  Future<void> dispose() async {
    await _tokenSubscription?.cancel();
    _tokenSubscription = null;
  }

  Future<String?> getDeviceToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        await SessionStorage.savePendingPushToken(token);
        return token;
      }
    } catch (_) {
      // Fallback para o último token persistido.
    }
    return SessionStorage.getPendingPushToken();
  }

  int get platformType {
    if (Platform.isAndroid) {
      return WSConstantes.fcmTypeAndroid;
    }
    if (Platform.isIOS) {
      return WSConstantes.fcmTypeIos;
    }
    return 0;
  }
}
