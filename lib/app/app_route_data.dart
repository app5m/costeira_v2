import 'package:costeira/features/auth/models/register_draft.dart';

class ValidationCodeRouteData {
  const ValidationCodeRouteData({
    required this.email,
    required this.password,
    required this.latitude,
    required this.longitude,
    required this.userType,
  });

  final String email;
  final String password;
  final String latitude;
  final String longitude;
  final int userType;
}

class PendingApprovalRouteData {
  const PendingApprovalRouteData({this.message, this.email});

  final String? message;
  final String? email;
}

class RegisterStepRouteData {
  const RegisterStepRouteData({required this.draft});

  final RegisterDraft draft;
}
