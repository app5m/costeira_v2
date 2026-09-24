import 'package:costeira/core/common/get_list/domain/entities/app_menu_entity.dart';
import 'package:costeira/core/components/primary_app_bar.dart';
import 'package:costeira/features/base/pages/module_placeholder_page.dart';
import 'package:flutter/material.dart';

class ComingSoonPage extends StatelessWidget {
  const ComingSoonPage({
    super.key,
    required this.title,
    this.message,
    this.menu,
  });

  final String title;
  final String? message;
  final AppMenuEntity? menu;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PrimarySectionAppBar(context: context, title: title),
      body: ModulePlaceholderPage(
        title: title,
        item: menu,
        message: message ?? 'Em breve.',
      ),
    );
  }
}
