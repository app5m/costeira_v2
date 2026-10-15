import 'package:costeira/app/app_routes.dart';
import 'package:costeira/core/components/app_buttons.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class WelcomeWebPage extends StatelessWidget {
  const WelcomeWebPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 760) {
            return _CompactWelcome(height: constraints.maxHeight);
          }
          return const Row(
            children: [
              Expanded(flex: 9, child: _WelcomeActions()),
              Expanded(flex: 11, child: _WelcomeHero()),
            ],
          );
        },
      ),
    );
  }
}

class _WelcomeHero extends StatelessWidget {
  const _WelcomeHero({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'images/costeira_tela.png',
          fit: BoxFit.cover,
          alignment: compact ? Alignment.center : Alignment.centerRight,
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x0D001208), Color(0x52001A0D)],
            ),
          ),
        ),
      ],
    );
  }
}

class _WelcomeActions extends StatelessWidget {
  const _WelcomeActions();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 48),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: const _WelcomeCard(),
          ),
        ),
      ),
    );
  }
}

class _CompactWelcome extends StatelessWidget {
  const _CompactWelcome({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: (height * .34).clamp(210.0, 290.0),
          width: double.infinity,
          child: const _WelcomeHero(compact: true),
        ),
        const Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(24, 32, 24, 24),
            child: _WelcomeCard(compact: true),
          ),
        ),
      ],
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 24 : 36),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8ECEA)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1200150A),
            blurRadius: 28,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: const _WelcomeContent(),
    );
  }
}

class _WelcomeContent extends StatelessWidget {
  const _WelcomeContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: ClipRect(
            child: SizedBox(
              width: 240,
              height: 76,
              child: OverflowBox(
                maxWidth: 240,
                maxHeight: 170,
                alignment: Alignment.center,
                child: Image.asset(
                  'images/logosplash.png',
                  width: 240,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Align(
          alignment: Alignment.center,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0x1400823A),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'DESENVOLVIMENTO PECUÁRIO',
              style: TextStyle(
                color: MyColors.colorPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: .8,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Bem-vindo à Costeira',
          style: TextStyle(
            color: Color(0xFF252A28),
            fontSize: 32,
            height: 1.2,
            fontWeight: FontWeight.w600,
            letterSpacing: -.5,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Acesse sua conta ou cadastre sua empresa para começar.',
          style: TextStyle(
            color: Color(0xFF727976),
            fontSize: 15,
            height: 1.55,
          ),
        ),
        const SizedBox(height: 36),
        PrimaryButton(
          label: 'Entrar',
          onPressed: () => Modular.to.pushNamed(AppRoutes.login),
        ),
        const SizedBox(height: 14),
        SecondaryButton(
          label: 'Cadastrar empresa',
          onPressed: () => Modular.to.pushNamed(AppRoutes.registerCompany),
        ),
        const SizedBox(height: 32),
        const Divider(color: Color(0xFFDDE3E0)),
        const SizedBox(height: 20),
        const Row(
          children: [
            Icon(
              Icons.lock_outline_rounded,
              size: 18,
              color: Color(0xFF727976),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Ao continuar, você concorda com os Termos de Uso e a Política de Privacidade.',
                style: TextStyle(
                  color: Color(0xFF727976),
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
