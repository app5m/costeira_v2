import 'package:flutter/foundation.dart';

class AppLogger {
  static const _reset = '\x1B[0m';

  static void info(String message) {
    _print('\x1B[34m[INFO] $message$_reset'); // azul
  }

  static void success(String message) {
    _print('\x1B[32m[SUCCESS] $message$_reset'); // verde
  }

  static void warning(String message) {
    _print('\x1B[33m[WARNING] $message$_reset'); // amarelo
  }

  static void error(String message) {
    _print('\x1B[31m[ERROR] $message$_reset'); // vermelho
  }

  static void fcm(String message) {
    _print('\x1B[1;33m🔥 [FCM] $message$_reset'); // amarelo forte + destaque
  }

  static void debug(String message) {
    _print('\x1B[35m[DEBUG] $message$_reset'); // roxo
  }

  static void _print(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
  }
}
