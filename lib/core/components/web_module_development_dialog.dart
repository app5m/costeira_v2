import 'package:costeira/core/components/web_dialog_frame.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class WebModuleDevelopmentDialog extends StatelessWidget {
  const WebModuleDevelopmentDialog({super.key, required this.moduleName});

  final String moduleName;

  @override
  Widget build(BuildContext context) {
    return WebDialogFrame(
      title: 'Em desenvolvimento',
      width: 460,
      maxHeight: 320,
      footer: Padding(
        padding: const EdgeInsets.fromLTRB(28, 16, 28, 22),
        child: SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: MyColors.colorPrimary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: const Text('Entendi'),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 24, 28, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _DevelopmentIcon(),
            const SizedBox(height: 18),
            Text(
              'O módulo $moduleName ainda está em desenvolvimento.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.45,
                color: Color(0xFF4F4F4F),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DevelopmentIcon extends StatelessWidget {
  const _DevelopmentIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: const Color(0xFFE7F2EB),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Icon(
        LucideIcons.hardHat,
        size: 27,
        color: MyColors.colorPrimary,
      ),
    );
  }
}
