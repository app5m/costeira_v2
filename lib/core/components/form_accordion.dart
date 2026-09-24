import 'package:costeira/core/components/custom_button.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';

class FormAccordion extends StatefulWidget {
  const FormAccordion({
    super.key,
    required this.title,
    required this.child,
    this.initiallyExpanded = true,
    this.complete = false,
  });

  final String title;
  final Widget child;
  final bool initiallyExpanded;

  /// `true` = ok (verde), `false` = pendente (amarelo), `null` = opcional/neutro.
  final bool? complete;

  @override
  State<FormAccordion> createState() => _FormAccordionState();
}

class _FormAccordionState extends State<FormAccordion> {
  late bool _expanded = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final complete = widget.complete;
    final border = switch (complete) {
      true => const Color(0xFF8CC9A6),
      false => _expanded ? const Color(0xFFE8C56B) : const Color(0xFFE8D48A),
      null => const Color(0xFFD0D5DD),
    };
    final accent = switch (complete) {
      true => MyColors.colorPrimary,
      false => const Color(0xFFB8860B),
      null => const Color(0xFF8C8C8C),
    };

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  _StatusBadge(complete: complete),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.title.toUpperCase(),
                      style: TextStyle(
                        color: complete == true
                            ? MyColors.colorPrimary
                            : const Color(0xFF313131),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: accent,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: widget.child,
            ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.complete});

  final bool? complete;

  @override
  Widget build(BuildContext context) {
    final color = switch (complete) {
      true => MyColors.colorPrimary,
      false => const Color(0xFFC9A227),
      null => const Color(0xFFB0B0B0),
    };
    final icon = switch (complete) {
      true => Icons.check_rounded,
      false => Icons.priority_high_rounded,
      null => Icons.remove_rounded,
    };

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 1.5),
      ),
      child: Icon(icon, size: 14, color: color),
    );
  }
}

class FormStickyFooter extends StatelessWidget {
  const FormStickyFooter({
    super.key,
    required this.lines,
    required this.buttonText,
    required this.enabled,
    required this.isLoading,
    required this.onSubmit,
  });

  final List<(String label, String value)> lines;
  final String buttonText;
  final bool enabled;
  final bool isLoading;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 16,
      shadowColor: const Color(0x33000000),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  for (var i = 0; i < lines.length; i++) ...[
                    if (i > 0) const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lines[i].$1,
                            style: const TextStyle(
                              color: Color(0xFF8C8C8C),
                              fontSize: 11,
                            ),
                          ),
                          Text(
                            lines[i].$2,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: MyColors.colorPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 10),
              CustomButton(
                onPressed: onSubmit,
                text: buttonText,
                enabled: enabled,
                isLoading: isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
