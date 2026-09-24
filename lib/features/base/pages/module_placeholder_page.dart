import 'package:costeira/core/common/get_list/domain/entities/app_menu_entity.dart';
import 'package:costeira/core/menus/menu_icon.dart';
import 'package:flutter/material.dart';

class ModulePlaceholderPage extends StatelessWidget {
  const ModulePlaceholderPage({
    super.key,
    required this.title,
    required this.message,
    this.item,
  });

  final String title;
  final String message;
  final AppMenuEntity? item;

  @override
  Widget build(BuildContext context) {
    final icon = MenuIcon.maybe(
      item: item,
      size: 48,
      color: const Color(0xFF00823A),
    );

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[icon, const SizedBox(height: 16)],
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF313131),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6B6B6B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FazendasPlaceholderPage extends StatelessWidget {
  const FazendasPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulePlaceholderPage(
      title: 'Fazendas',
      message: 'Em breve. Aqui você troca e gerencia as propriedades.',
    );
  }
}

class ManejosPlaceholderPage extends StatelessWidget {
  const ManejosPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulePlaceholderPage(
      title: 'Manejos',
      message: 'Em breve. Use o botão + do Dashboard para registrar um manejo.',
    );
  }
}
