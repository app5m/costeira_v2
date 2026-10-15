import 'package:costeira/core/components/web_dialog_frame.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

Future<T?> showAdaptiveSelectionModal<T>({
  required BuildContext context,
  required String title,
  required Widget Function(bool embeddedInDialog) builder,
  double mobileBorderRadius = 24,
}) {
  if (kIsWeb) {
    return showDialog<T>(
      context: context,
      barrierDismissible: false,
      builder: (_) => WebDialogFrame(title: title, child: builder(true)),
    );
  }
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(mobileBorderRadius),
      ),
    ),
    builder: (_) => SafeArea(top: false, child: builder(false)),
  );
}
