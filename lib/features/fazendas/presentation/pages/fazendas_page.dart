import 'package:costeira/app/app_routes.dart';
import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/features/fazendas/domain/entities/fazenda_entity.dart';
import 'package:costeira/features/fazendas/presentation/page_controllers/fazendas_list_page_controller.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:lucide_icons/lucide_icons.dart';

class FazendasPage extends StatefulWidget {
  const FazendasPage({super.key});

  @override
  State<FazendasPage> createState() => _FazendasPageState();
}

class _FazendasPageState extends State<FazendasPage> {
  final FazendasListPageController _pageController =
      Modular.get<FazendasListPageController>();

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
      AppRoutes.fazendasAdd,
    );
    if (!mounted || result?['success'] != true) {
      return;
    }
    await _pageController.reload();
    if (!mounted) {
      return;
    }
    _showMessage(
      result?['message']?.toString() ?? 'Fazenda salva com sucesso.',
      isError: false,
    );
  }

  Future<void> _openEdit(FazendaEntity fazenda) async {
    final result = await Modular.to.pushNamed<Map<String, dynamic>?>(
      AppRoutes.fazendasEdit,
      arguments: fazenda,
    );
    if (!mounted || result?['success'] != true) {
      return;
    }
    await _pageController.reload();
    if (!mounted) {
      return;
    }
    _showMessage(
      result?['message']?.toString() ?? 'Fazenda atualizada com sucesso.',
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
          floatingActionButton: FloatingActionButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(64),
            ),
            onPressed: _openAdd,
            child: const Icon(Icons.add, color: Colors.white),
          ),
          body: RefreshIndicator(
            onRefresh: () => _pageController.reload(),
            child: _buildBody(),
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    if (_pageController.isLoading && _pageController.fazendas.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_pageController.errorMessage != null &&
        _pageController.fazendas.isEmpty) {
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

    if (_pageController.fazendas.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.18),
          const Center(
            child: Icon(
              LucideIcons.warehouse,
              size: 48,
              color: Color(0xFF00823A),
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Nenhuma fazenda cadastrada',
              textAlign: TextAlign.center,
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
              'Toque no + para cadastrar a primeira propriedade.',
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
      itemCount: _pageController.fazendas.length,
      itemBuilder: (context, index) {
        final fazenda = _pageController.fazendas[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _openEdit(fazenda),
            child: Ink(
              padding: const EdgeInsets.all(16),
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Color(0xFFEBEBEB)),
                  borderRadius: BorderRadius.circular(12),
                ),
                shadows: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 24,
                    offset: Offset(0, 0),
                  ),
                ],
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
                      LucideIcons.warehouse,
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
                          fazenda.nome.isEmpty ? 'Fazenda' : fazenda.nome,
                          style: const TextStyle(
                            color: Color(0xFF313131),
                            fontSize: 14,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (fazenda.email.isNotEmpty)
                          Text(
                            fazenda.email,
                            style: const TextStyle(
                              color: Color(0xFF8C8C8C),
                              fontSize: 12,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        if (fazenda.celular.isNotEmpty)
                          Text(
                            fazenda.celular,
                            style: const TextStyle(
                              color: Color(0xFF8C8C8C),
                              fontSize: 12,
                              fontFamily: 'Montserrat',
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
