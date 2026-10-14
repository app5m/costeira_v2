import 'package:costeira/app/app_routes.dart';
import 'package:costeira/core/components/app_buttons.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/features/auth/presentation/web/auth_web_frame.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class PendingApprovalWebPage extends StatelessWidget {
  const PendingApprovalWebPage({super.key, this.message, this.email});

  final String? message;
  final String? email;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String>?>(
      future: SessionStorage.getWebPendingApproval(),
      builder: (context, snapshot) {
        final stored = snapshot.data;
        return _buildPage(
          context,
          resolvedMessage: message ?? stored?['message'],
          resolvedEmail: email ?? stored?['email'],
        );
      },
    );
  }

  Widget _buildPage(
    BuildContext context, {
    required String? resolvedMessage,
    required String? resolvedEmail,
  }) {
    return AuthWebFrame(
      showBack: false,
      header: Container(
        width: 96,
        height: 96,
        decoration: BoxDecoration(
          color: const Color(0x1400823A),
          borderRadius: BorderRadius.circular(28),
        ),
        child: const Icon(
          Icons.pending_actions_rounded,
          size: 44,
          color: MyColors.colorPrimary,
        ),
      ),
      title: 'Estamos analisando o seu acesso',
      subtitle:
          resolvedMessage ??
          'Seu cadastro foi recebido e agora depende da aprovação do administrador para liberar o acesso ao aplicativo.',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0x1900823A),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'Cadastro em análise',
              style: TextStyle(
                color: MyColors.colorPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F8F8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE4E7E7)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.verified_user_outlined,
                      color: MyColors.colorPrimary,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Próximos passos',
                      style: TextStyle(
                        color: Color(0xFF313131),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'O administrador vai validar o seu cadastro antes da liberação.',
                  style: TextStyle(
                    color: Color(0xFF6C7278),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Assim que o acesso for aprovado, você poderá entrar normalmente com seus dados.',
                  style: TextStyle(
                    color: Color(0xFF6C7278),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                if ((resolvedEmail ?? '').isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    'E-mail informado: $resolvedEmail',
                    style: const TextStyle(
                      color: Color(0xFF313131),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      footer: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PrimaryButton(
            label: 'Sair',
            onPressed: () async {
              await Future.wait([
                SessionStorage.clearWebPendingApproval(),
                SessionStorage.clearPendingUser(),
              ]);
              if (!context.mounted) {
                return;
              }
              Modular.to.navigate(AppRoutes.welcome);
            },
          ),
        ],
      ),
    );
  }
}
