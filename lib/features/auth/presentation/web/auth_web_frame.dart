import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

abstract final class AuthWebBreakpoints {
  static const double compact = 760;
  static const double desktop = 1120;
}

class AuthWebFrame extends StatelessWidget {
  const AuthWebFrame({
    super.key,
    required this.title,
    required this.subtitle,
    required this.body,
    this.footer,
    this.illustrationAsset = 'images/costeira_tela.png',
    this.illustrationAlignment = Alignment.center,
    this.fallbackRoute,
    this.showBack = true,
    this.contentMaxWidth = 520,
    this.header,
  });

  final String title;
  final String subtitle;
  final Widget body;
  final Widget? footer;
  final String illustrationAsset;
  final Alignment illustrationAlignment;
  final String? fallbackRoute;
  final bool showBack;
  final double contentMaxWidth;
  final Widget? header;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < AuthWebBreakpoints.compact) {
            return _compactLayout(context, constraints);
          }

          final isDesktop = constraints.maxWidth >= AuthWebBreakpoints.desktop;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: isDesktop ? 9 : 7,
                child: _contentPanel(
                  context,
                  horizontalPadding: isDesktop ? 64 : 40,
                ),
              ),
              Expanded(
                flex: isDesktop ? 11 : 5,
                child: _BrandPanel(
                  asset: illustrationAsset,
                  alignment: illustrationAlignment,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _compactLayout(BuildContext context, BoxConstraints constraints) {
    final heroHeight = (constraints.maxHeight * .25).clamp(160.0, 220.0);
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: heroHeight,
          child: _BrandPanel(
            asset: illustrationAsset,
            alignment: illustrationAlignment,
          ),
        ),
        Expanded(child: _contentPanel(context, horizontalPadding: 24)),
      ],
    );
  }

  Widget _contentPanel(
    BuildContext context, {
    required double horizontalPadding,
  }) {
    return SafeArea(
      top: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          const verticalPadding = 36.0;
          final isNarrowPanel = constraints.maxWidth < 520;
          final minimumContentHeight =
              (constraints.maxHeight - verticalPadding * 2).clamp(
                0.0,
                double.infinity,
              );

          return Scrollbar(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: minimumContentHeight),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: contentMaxWidth),
                    child: Container(
                      padding: EdgeInsets.all(isNarrowPanel ? 24 : 36),
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
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child:
                                header ?? _ContentLogo(compact: isNarrowPanel),
                          ),
                          const SizedBox(height: 40),
                          Text(
                            title,
                            style: const TextStyle(
                              color: Color(0xFF252A28),
                              fontSize: 30,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              color: Color(0xFF727976),
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              height: 1.55,
                            ),
                          ),
                          const SizedBox(height: 32),
                          body,
                          if (footer != null) ...[
                            const SizedBox(height: 32),
                            footer!,
                          ],
                          if (showBack) ...[
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 48,
                              child: OutlinedButton(
                                onPressed: () =>
                                    authWebBack(context, fallbackRoute ?? '/'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: MyColors.colorPrimary,
                                  side: const BorderSide(
                                    color: MyColors.colorPrimary,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Voltar',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ContentLogo extends StatelessWidget {
  const _ContentLogo({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: SizedBox(
        width: compact ? 220 : 280,
        height: compact ? 86 : 104,
        child: OverflowBox(
          maxWidth: compact ? 220 : 280,
          maxHeight: compact ? 156 : 198,
          alignment: Alignment.center,
          child: Image.asset(
            'images/logosplash.png',
            width: compact ? 220 : 280,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel({required this.asset, required this.alignment});

  final String asset;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: MyColors.colorPrimary),
        Image.asset(asset, fit: BoxFit.cover, alignment: alignment),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x0D001208), Color(0x52001A0D)],
              stops: [0, 1],
            ),
          ),
        ),
      ],
    );
  }
}

class AuthPasswordToggle extends StatelessWidget {
  const AuthPasswordToggle({
    super.key,
    required this.obscured,
    required this.onPressed,
  });

  final bool obscured;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: obscured ? 'Mostrar senha' : 'Ocultar senha',
      icon: Icon(
        obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        color: Colors.grey,
      ),
    );
  }
}

class AuthRouteRedirect extends StatefulWidget {
  const AuthRouteRedirect({super.key, required this.route});

  final String route;

  @override
  State<AuthRouteRedirect> createState() => _AuthRouteRedirectState();
}

class _AuthRouteRedirectState extends State<AuthRouteRedirect> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Modular.to.navigate(widget.route);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

void authWebBack(BuildContext context, String fallbackRoute) {
  final navigator = Navigator.of(context);
  if (navigator.canPop()) {
    navigator.pop();
    return;
  }
  Modular.to.navigate(fallbackRoute);
}
