import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/features/usuarios/domain/entities/sub_usuario_entity.dart';
import 'package:costeira/features/usuarios/presentation/page_controllers/sub_usuarios_list_page_controller.dart';
import 'package:costeira/features/usuarios/presentation/web/sub_usuario_form_web_dialog.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SubUsuariosListWebDialog extends StatefulWidget {
  const SubUsuariosListWebDialog({super.key});

  @override
  State<SubUsuariosListWebDialog> createState() =>
      _SubUsuariosListWebDialogState();
}

class _SubUsuariosListWebDialogState extends State<SubUsuariosListWebDialog> {
  late final SubUsuariosListPageController _controller;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = Modular.get<SubUsuariosListPageController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.loadInitialData();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _openForm([SubUsuarioEntity? usuario]) async {
    final result = await showDialog<Map<String, dynamic>?>(
      context: context,
      barrierDismissible: false,
      builder: (_) => SubUsuarioFormWebDialog(usuario: usuario),
    );
    if (!mounted || result?['success'] != true) return;
    await _controller.reload();
    if (!mounted) return;
    AppSnackBar.show(
      context: context,
      message: result?['message']?.toString() ?? 'Usuário salvo com sucesso.',
      isError: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewport = MediaQuery.sizeOf(context);
    final narrow = viewport.width < 620;
    final height = (viewport.height - 48).clamp(320.0, 760.0);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Dialog(
        backgroundColor: Colors.white,
        insetPadding: EdgeInsets.all(narrow ? 8 : 24),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: SizedBox(
          width: 720,
          height: height,
          child: Column(
            children: [
              _header(narrow),
              const Divider(height: 1, color: Color(0xFFE7E4DD)),
              Expanded(child: _body()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(bool narrow) {
    return Padding(
      padding: EdgeInsets.fromLTRB(narrow ? 16 : 22, 10, 12, 10),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Usuários e acessos',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: Color(0xFF252525),
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: _controller.isLoading ? null : () => _openForm(),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Adicionar'),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              minimumSize: Size(narrow ? 108 : 124, 42),
              backgroundColor: MyColors.colorPrimary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            tooltip: 'Fechar',
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
    );
  }

  Widget _body() {
    if (_controller.isLoading && _controller.usuarios.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_controller.errorMessage != null && _controller.usuarios.isEmpty) {
      return _MessageState(
        icon: LucideIcons.alertTriangle,
        message: _controller.errorMessage!,
        actionLabel: 'Tentar novamente',
        onAction: _controller.reload,
      );
    }
    if (_controller.usuarios.isEmpty) {
      return const _MessageState(
        icon: LucideIcons.users,
        message: 'Nenhum usuário cadastrado',
      );
    }
    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(22, 20, 30, 24),
        itemCount: _controller.usuarios.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final usuario = _controller.usuarios[index];
          return _UsuarioRow(usuario: usuario, onTap: () => _openForm(usuario));
        },
      ),
    );
  }
}

class _UsuarioRow extends StatelessWidget {
  const _UsuarioRow({required this.usuario, required this.onTap});

  final SubUsuarioEntity usuario;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE7E4DD)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0x1400823A),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  LucideIcons.user,
                  size: 19,
                  color: MyColors.colorPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      usuario.nome.isEmpty ? 'Usuário' : usuario.nome,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF313131),
                      ),
                    ),
                    if (usuario.email.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        usuario.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 12,
                          color: Color(0xFF777777),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                LucideIcons.chevronRight,
                size: 18,
                color: Color(0xFF8C8C8C),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final Future<dynamic> Function()? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 44, color: MyColors.colorPrimary),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF313131),
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 14),
              OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
