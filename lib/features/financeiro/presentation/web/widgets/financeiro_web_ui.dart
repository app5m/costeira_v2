import 'package:costeira/features/financeiro/domain/financeiro_mock.dart';
import 'package:costeira/features/financeiro/presentation/widgets/financeiro_ui.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

const financeiroWebFundo = MyColors.surface;
const financeiroWebBorda = MyColors.surfaceBorder;
const financeiroWebCard = MyColors.card;

class FinanceiroWebMetricCard extends StatelessWidget {
  const FinanceiroWebMetricCard({
    super.key,
    required this.label,
    required this.value,
    this.color = MyColors.colorPrimary,
    this.subtitle,
  });

  final String label;
  final String value;
  final Color color;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: MyColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: financeiroWebBorda),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
              color: Color(0xFF8A8A8A),
            ),
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 12,
                color: Color(0xFF8A8A8A),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class FinanceiroWebToolbar extends StatelessWidget {
  const FinanceiroWebToolbar({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.actions = const [],
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 720;
    return ColoredBox(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          compact ? 16 : 28,
          16,
          compact ? 16 : 28,
          16,
        ),
        child: Row(
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 12)],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: compact ? 16 : 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF252A27),
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF7B827D),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            for (final action in actions) ...[
              const SizedBox(width: 8),
              action,
            ],
          ],
        ),
      ),
    );
  }
}

class FinanceiroWebBackButton extends StatelessWidget {
  const FinanceiroWebBackButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Voltar',
      onPressed: onPressed,
      style: IconButton.styleFrom(
        foregroundColor: const Color(0xFF313131),
        backgroundColor: const Color(0xFFF0F2ED),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      icon: const Icon(LucideIcons.chevronLeft, size: 18),
    );
  }
}

class FinanceiroWebPrimaryButton extends StatelessWidget {
  const FinanceiroWebPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon = Icons.add,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: MyColors.colorPrimary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
          textStyle: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class FinanceiroWebStatusChip extends StatelessWidget {
  const FinanceiroWebStatusChip(this.situacao, {super.key});

  final SituacaoLancamento situacao;

  @override
  Widget build(BuildContext context) {
    final (rotulo, fundo, letra) = switch (situacao) {
      SituacaoLancamento.parcial => (
        'Parcial',
        const Color(0xFFFFF4E5),
        const Color(0xFFB86E00),
      ),
      SituacaoLancamento.liquidado => (
        'Liquidado',
        const Color(0xFFE7F6EC),
        MyColors.colorPrimary,
      ),
      SituacaoLancamento.pendente => (
        'Pendente',
        const Color(0xFFFDECEC),
        const Color(0xFFC62828),
      ),
      SituacaoLancamento.rascunho => (
        'Rascunho',
        const Color(0xFFF3F6F4),
        const Color(0xFF3D5346),
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: fundo,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        rotulo,
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: letra,
        ),
      ),
    );
  }
}

class FinanceiroWebPanel extends StatelessWidget {
  const FinanceiroWebPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: MyColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: financeiroWebBorda),
      ),
      child: child,
    );
  }
}

class FinanceiroWebTableHeader extends StatelessWidget {
  const FinanceiroWebTableHeader({super.key, required this.columns});

  final List<(String, int)> columns;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFFF8F7F3),
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          for (final column in columns)
            Expanded(
              flex: column.$2,
              child: Text(
                column.$1.toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF6B6B6B),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class FinanceiroWebEmpty extends StatelessWidget {
  const FinanceiroWebEmpty({
    super.key,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.wallet, size: 36, color: Color(0xFFB0B7AE)),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF8A8A8A),
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              FinanceiroWebPrimaryButton(
                label: actionLabel!,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class FinanceiroWebSectionTitle extends StatelessWidget {
  const FinanceiroWebSectionTitle(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF313131),
            ),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// Formata valores já existentes da loja/mobile.
String financeiroWebReais(num valor) => reais(valor);
