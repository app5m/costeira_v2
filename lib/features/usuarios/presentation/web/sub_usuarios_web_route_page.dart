import 'package:costeira/app/app_routes.dart';
import 'package:costeira/features/usuarios/presentation/web/sub_usuarios_list_web_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

/// Abre a lista de usuários em dialog na web e fecha a rota ao concluir.
class SubUsuariosWebRoutePage extends StatefulWidget {
  const SubUsuariosWebRoutePage({super.key});

  @override
  State<SubUsuariosWebRoutePage> createState() =>
      _SubUsuariosWebRoutePageState();
}

class _SubUsuariosWebRoutePageState extends State<SubUsuariosWebRoutePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _openDialog());
  }

  Future<void> _openDialog() async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const SubUsuariosListWebDialog(),
    );
    if (!mounted) return;
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return;
    }
    Modular.to.navigate(AppRoutes.appShell);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF7F9F8),
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
