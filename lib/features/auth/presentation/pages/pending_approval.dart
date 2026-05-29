import 'package:costeira/app/app_routes.dart';
import 'package:costeira/theme/colors.dart';
import 'package:costeira/core/components/app_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class PendingApprovalPage extends StatelessWidget {
  const PendingApprovalPage({super.key, this.message, this.email});

  final String? message;
  final String? email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.colorPrimary,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
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
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: Container(
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
                    ),
                    const SizedBox(height: 28),
                    const Center(
                      child: Text(
                        'Estamos analisando o seu acesso',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF313131),
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        message ??
                            'Seu cadastro foi recebido e agora depende da aprovação do administrador para liberar o acesso ao aplicativo.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF8C8C8C),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          height: 1.5,
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
                          if ((email ?? '').isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(
                              'E-mail informado: $email',
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
                    const Spacer(),
                    PrimaryButton(
                      label: 'Voltar para o início',
                      onPressed: () {
                        Modular.to.navigate(AppRoutes.welcome);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
