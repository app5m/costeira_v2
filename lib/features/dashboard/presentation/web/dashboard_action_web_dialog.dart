import 'package:costeira/core/components/web_dialog_frame.dart';
import 'package:costeira/core/components/web_page_dialog.dart';
import 'package:flutter/material.dart';

class DashboardActionWebDialog extends StatelessWidget {
  const DashboardActionWebDialog({
    super.key,
    required this.title,
    required this.child,
    this.bodyPadding = EdgeInsets.zero,
  });

  final String title;
  final Widget child;
  final EdgeInsetsGeometry bodyPadding;

  @override
  Widget build(BuildContext context) {
    return WebPageDialog(
      title: title,
      width: 760,
      maxHeight: 840,
      sizeMode: WebDialogSizeMode.constrained,
      child: Padding(padding: bodyPadding, child: child),
    );
  }
}
