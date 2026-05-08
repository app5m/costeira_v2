import 'package:costeira/features/pastagem_nutricao_suplemento/domain/entities/manejo.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/presentation/controllers/delete_manejo_controller.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/presentation/controllers/list_manejos_controller.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/presentation/pages/manejo/detail_manejo.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'add_manejo.dart';
import 'edit_amanejo.dart';
import 'graficos_manejo.dart';

class Manejos extends StatefulWidget {
  const Manejos({super.key});

  @override
  State<Manejos> createState() => _ManejosState();
}

class _ManejosState extends State<Manejos> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final ListManejosController _listController;
  late final DeleteManejoController _deleteController;

  int index = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _listController = Modular.get<ListManejosController>()..addListener(_sync);
    _deleteController = Modular.get<DeleteManejoController>()
      ..addListener(_sync);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadManejos());
  }

  @override
  void dispose() {
    _listController.removeListener(_sync);
    _deleteController.removeListener(_sync);
    _tabController.dispose();
    super.dispose();
  }

  void _sync() {
    if (mounted) setState(() {});
  }

  Future<void> _loadManejos() async {
    try {
      await _listController.load();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _listController.errorMessage ?? 'Erro ao listar manejos.',
          ),
        ),
      );
    }
  }

  Future<void> _openAddManejo() async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddManejo()),
    );
    if (changed == true) {
      await _listController.reload();
    }
  }

  Future<void> _openEditManejo(Manejo manejo) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => EditManejo(manejo: manejo)),
    );
    if (changed == true) {
      await _listController.reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: index == 0
          ? FloatingActionButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(64),
              ),
              onPressed: _openAddManejo,
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Icon(Icons.add, color: Colors.white),
              ),
            )
          : null,
      appBar: AppBar(
        backgroundColor: MyColors.colorPrimary,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: const Text(
          'Manejo de Pastagens',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Dados'),
              Tab(text: 'Graficos'),
            ],
            onTap: (int tabIndex) {
              setState(() => index = tabIndex);
            },
            automaticIndicatorColorAdjustment: false,
            indicatorSize: TabBarIndicatorSize.tab,
            unselectedLabelColor: Colors.grey,
            labelStyle: const TextStyle(
              fontSize: 12,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 12,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w700,
            ),
            dividerColor: Colors.grey,
            labelColor: Colors.black,
            indicatorColor: MyColors.colorPrimary2,
          ),
          const SizedBox(height: 16),
          if (index == 0) _MonthSelector(),
          if (index == 0) const SizedBox(height: 16),
          if (index == 0) Expanded(child: _buildManejosList()),
          if (index == 1) const GraficosManejo(),
        ],
      ),
    );
  }

  Widget _buildManejosList() {
    if (_listController.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_listController.manejos.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum manejo encontrado.',
          style: TextStyle(
            color: Color(0xFF8C8C8C),
            fontSize: 14,
            fontFamily: 'Montserrat',
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: _listController.manejos.length,
      itemBuilder: (context, index) {
        final manejo = _listController.manejos[index];
        return _ManejoCard(
          manejo: manejo,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DetailManejo()),
            );
          },
          onEdit: () => _openEditManejo(manejo),
          onDelete: () => _showModalBottomSheetExcluir(context, manejo),
        );
      },
    );
  }

  Future<void> _deleteManejo(Manejo manejo) async {
    if (_deleteController.isLoading) return;

    try {
      final result = await _deleteController.deleteManejo(manejo.id);
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.message)));
      await _listController.reload();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_deleteController.errorMessage ?? 'Erro ao excluir.'),
        ),
      );
    }
  }

  void _showModalBottomSheetExcluir(BuildContext context, Manejo manejo) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (BuildContext bc) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Container(
              width: 72,
              decoration: const ShapeDecoration(
                shape: RoundedRectangleBorder(
                  side: BorderSide(width: 2, color: Color(0xFFE2E2E2)),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SvgPicture.asset(
              'icon/danger-linear.svg',
              width: 80,
              height: 80,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Excluir manejo',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Color(0xff000000),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tem certeza que deseja excluir esse\nmanejo permanentemente?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: Color(0xFF8692A8),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              height: 50,
              child: ElevatedButton(
                onPressed: _deleteController.isLoading
                    ? null
                    : () => _deleteManejo(manejo),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  side: const BorderSide(color: Colors.red),
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                ),
                child: const Text(
                  'Excluir',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancelar',
                style: TextStyle(
                  fontSize: 16,
                  color: MyColors.colorOnPrimary,
                  decoration: TextDecoration.underline,
                  decorationColor: MyColors.colorOnPrimary,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}

class _ManejoCard extends StatelessWidget {
  const _ManejoCard({
    required this.manejo,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final Manejo manejo;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final unidade = manejo.unidade?.nome.trim() ?? '';
    final quantidade = _formatDecimal(manejo.quantidade);
    final quantidadeLabel = unidade.isEmpty
        ? quantidade
        : '$quantidade $unidade';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width - 40,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 8, left: 20, right: 20),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1, color: Color(0xFFEBEBEB)),
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: ShapeDecoration(
                      color: const Color(0x198C8C8C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(42.67),
                      ),
                    ),
                    child: SvgPicture.asset(
                      'icon/diamond.svg',
                      width: 16,
                      height: 16,
                      color: const Color(0xFF8C8C8C),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          manejo.potreiro?.nome ?? 'Potreiro',
                          style: const TextStyle(
                            color: Color(0xFF313131),
                            fontSize: 14,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          manejo.tipoManejo,
                          style: const TextStyle(
                            color: Color(0xFF313131),
                            fontSize: 12,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          manejo.dataManejo ?? '-',
                          style: const TextStyle(
                            color: Color(0xFF8C8C8C),
                            fontSize: 12,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          quantidadeLabel,
                          style: const TextStyle(
                            color: Color(0xFF8C8C8C),
                            fontSize: 12,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: onDelete,
                  child: SvgPicture.asset('icon/trash.svg'),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: onEdit,
                  child: SvgPicture.asset('icon/square-pen.svg'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width - 40,
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0xFFEBEBEB)),
          borderRadius: BorderRadius.circular(8),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 24,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(Icons.arrow_back_rounded),
          Text(
            'Junho 2025',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF8C8C8C),
              fontSize: 14,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w500,
            ),
          ),
          Icon(Icons.arrow_forward_rounded),
        ],
      ),
    );
  }
}

String _formatDecimal(double? value) {
  if (value == null) return '-';
  if (value % 1 == 0) return value.toInt().toString();
  return value.toStringAsFixed(2).replaceAll('.', ',');
}
