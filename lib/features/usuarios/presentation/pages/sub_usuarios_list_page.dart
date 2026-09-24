import 'package:costeira/app/app_route_data.dart';
import 'package:costeira/app/app_routes.dart';
import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/core/components/primary_app_bar.dart';
import 'package:costeira/features/usuarios/domain/entities/sub_usuario_entity.dart';
import 'package:costeira/features/usuarios/presentation/page_controllers/sub_usuarios_list_page_controller.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SubUsuariosListPage extends StatefulWidget {
  const SubUsuariosListPage({super.key});

  @override
  State<SubUsuariosListPage> createState() => _SubUsuariosListPageState();
}

class _SubUsuariosListPageState extends State<SubUsuariosListPage> {
  final SubUsuariosListPageController _pageController =
      Modular.get<SubUsuariosListPageController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pageController.loadInitialData();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _openAdd() async {
    final result = await Modular.to.pushNamed<Map<String, dynamic>?>(
      AppRoutes.usuariosAdd,
    );
    if (!mounted || result?['success'] != true) {
      return;
    }
    await _pageController.reload();
    if (!mounted) {
      return;
    }
    _showMessage(
      result?['message']?.toString() ?? 'Usuario salvo com sucesso.',
      isError: false,
    );
  }

  Future<void> _openEdit(SubUsuarioEntity usuario) async {
    final result = await Modular.to.pushNamed<Map<String, dynamic>?>(
      AppRoutes.usuariosEdit,
      arguments: SubUsuarioFormRouteData(usuario: usuario),
    );
    if (!mounted || result?['success'] != true) {
      return;
    }
    await _pageController.reload();
    if (!mounted) {
      return;
    }
    _showMessage(
      result?['message']?.toString() ?? 'Usuario atualizado com sucesso.',
      isError: false,
    );
  }

  void _showMessage(String message, {bool isError = true}) {
    AppSnackBar.show(context: context, message: message, isError: isError);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: PrimarySectionAppBar(
            context: context,
            title: 'Usuários e acessos',
          ),
          floatingActionButton: FloatingActionButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(64),
            ),
            onPressed: _openAdd,
            child: const Icon(Icons.add, color: Colors.white),
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              await _pageController.reload();
            },
            child: _buildBody(),
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    if (_pageController.isLoading && _pageController.usuarios.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_pageController.errorMessage != null &&
        _pageController.usuarios.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 120),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                _pageController.errorMessage!,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      );
    }

    if (_pageController.usuarios.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.18),
          const Center(
            child: Icon(LucideIcons.users, size: 48, color: Color(0xFF00823A)),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Nenhum usuário cadastrado',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF313131),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Toque no + para convidar o primeiro acesso.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6B6B6B),
              ),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 88),
      itemCount: _pageController.usuarios.length,
      itemBuilder: (context, index) {
        final usuario = _pageController.usuarios[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _openEdit(usuario),
            child: Ink(
              padding: const EdgeInsets.all(16),
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Color(0xFFEBEBEB)),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0x14128977),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      LucideIcons.user,
                      size: 20,
                      color: MyColors.colorPrimary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          usuario.nome.isEmpty ? 'Usuario' : usuario.nome,
                          style: const TextStyle(
                            color: Color(0xFF313131),
                            fontSize: 14,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (usuario.email.isNotEmpty)
                          Text(
                            usuario.email,
                            style: const TextStyle(
                              color: Color(0xFF8C8C8C),
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Color(0xFF8C8C8C)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
