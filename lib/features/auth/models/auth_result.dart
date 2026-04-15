import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/features/auth/models/user_session.dart';

class AuthResult {
  const AuthResult({required this.message, this.user});

  final ApiMessage message;
  final UserSession? user;
}
