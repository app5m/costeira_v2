import 'package:costeira/core/common/get_list/domain/entities/app_menu_entity.dart';
import 'package:costeira/features/auth/models/register_draft.dart';
import 'package:costeira/features/auth/models/user_session.dart';
import 'package:costeira/features/cadastros/domain/entities/parceiro_entity.dart';
import 'package:costeira/features/cadastros/domain/entities/parceiro_kind.dart';
import 'package:costeira/features/usuarios/domain/entities/sub_usuario_entity.dart';

class ValidationCodeRouteData {
  const ValidationCodeRouteData({
    required this.email,
    required this.password,
    required this.latitude,
    required this.longitude,
    required this.userType,
    this.pendingUser,
  });

  final String email;
  final String password;
  final String latitude;
  final String longitude;
  final int userType;
  final UserSession? pendingUser;
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

class ComingSoonRouteData {
  const ComingSoonRouteData({required this.title, this.message, this.menu});

  final String title;
  final String? message;
  final AppMenuEntity? menu;
}

class ParceiroFormRouteData {
  const ParceiroFormRouteData({
    required this.kind,
    required this.appFazendasId,
    this.parceiro,
  });

  final ParceiroKind kind;
  final int appFazendasId;
  final ParceiroEntity? parceiro;
}

class SubUsuarioFormRouteData {
  const SubUsuarioFormRouteData({this.usuario});

  final SubUsuarioEntity? usuario;
}
