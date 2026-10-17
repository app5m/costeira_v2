import 'dart:async';

import 'package:costeira/theme/colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppSnackBar {
  static OverlayEntry? _webToast;
  static Timer? _webToastTimer;

  static void show({
    required BuildContext context,
    required String message,
    bool isError = true,
  }) {
    if (kIsWeb) {
      _showWebToast(context: context, message: message, isError: isError);
      return;
    }

    final snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: isError ? MyColors.colorBtnNo : MyColors.colorPrimary,
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: Colors.white,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      duration: const Duration(seconds: 3),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  static void _showWebToast({
    required BuildContext context,
    required String message,
    required bool isError,
  }) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) {
      return;
    }

    _removeWebToast();
    _webToast = OverlayEntry(
      builder: (overlayContext) {
        final viewportWidth = MediaQuery.sizeOf(overlayContext).width;
        final compact = viewportWidth < 520;
        return Positioned(
          right: compact ? 16 : 24,
          bottom: compact ? 16 : 24,
          left: compact ? 16 : null,
          child: Align(
            alignment: Alignment.bottomRight,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: _WebToast(message: message, isError: isError),
            ),
          ),
        );
      },
    );
    overlay.insert(_webToast!);
    _webToastTimer = Timer(const Duration(seconds: 4), _removeWebToast);
  }

  static void _removeWebToast() {
    _webToastTimer?.cancel();
    _webToastTimer = null;
    _webToast?.remove();
    _webToast = null;
  }
}

class _WebToast extends StatelessWidget {
  const _WebToast({required this.message, required this.isError});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final color = isError ? const Color(0xFFC4473A) : MyColors.colorPrimary;
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      tween: Tween(begin: 0, end: 1),
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(18 * (1 - value), 0),
          child: child,
        ),
      ),
      child: Semantics(
        liveRegion: true,
        label: message,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 13, 16, 13),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E4DF)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x26000000),
                  blurRadius: 20,
                  offset: Offset(0, 7),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(
                    isError
                        ? Icons.error_outline_rounded
                        : Icons.check_circle_outline_rounded,
                    size: 20,
                    color: color,
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    message,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                      color: Color(0xFF343A36),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
