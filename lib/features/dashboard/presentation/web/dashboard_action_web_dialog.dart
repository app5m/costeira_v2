import 'package:costeira/core/components/web_page_dialog.dart';
import 'package:flutter/material.dart';

class DashboardActionWebDialog extends StatelessWidget {
  const DashboardActionWebDialog({
    super.key,
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return WebPageDialog(title: title, child: child);
  }
}
