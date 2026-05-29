import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/entities/manejo.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/presentation/controllers/delete_manejo_controller.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/presentation/controllers/list_manejos_controller.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/presentation/pages/manejo/detail_manejo.dart';
import 'package:costeira/features/potreiros/presentation/controllers/list_potreiros_controller.dart';
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
  late final ListPotreirosController _potreirosController;

  int index = 0;
  int? _selectedPotreiroId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _listController = Modular.get<ListManejosController>()..addListener(_sync);
    _deleteController = Modular.get<DeleteManejoController>()
      ..addListener(_sync);
    _potreirosController = Modular.get<ListPotreirosController>()
      ..addListener(_sync);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPotreiros();
      _loadManejos();
    });
  }

  @override
  void dispose() {
    _listController.removeListener(_sync);
    _deleteController.removeListener(_sync);
    _potreirosController.removeListener(_sync);
    _tabController.dispose();
    super.dispose();
  }

  void _sync() {
    if (mounted) setState(() {});
  }

  Future<void> _loadManejos() async {
    try {
      await _listController.load(idPotreiro: _selectedPotreiroId);
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.show(
        context: context,
        message: _listController.errorMessage ?? 'Erro ao listar manejos.',
      );
    }
  }

  Future<void> _loadPotreiros() async {
    try {
      await _potreirosController.load();
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.show(
        context: context,
        message:
            _potreirosController.errorMessage ?? 'Erro ao listar potreiros.',
      );
    }
  }

  Future<void> _onPotreiroFilterChanged(int? value) async {
    setState(() => _selectedPotreiroId = value);
    await _loadManejos();
  }

  Future<void> _showPotreiroFilter() async {
    final selected = await showModalBottomSheet<int?>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 72,
                    height: 2,
                    color: const Color(0xFFE2E2E2),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Potreiro',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                _buildFilterOption(
                  label: 'Todos',
                  isSelected: _selectedPotreiroId == null,
                  onTap: () => Navigator.of(context).pop(null),
                ),
                ..._potreirosController.potreiros.map(
                  (potreiro) => _buildFilterOption(
                    label: potreiro.nome,
                    isSelected: _selectedPotreiroId == potreiro.id,
                    onTap: () => Navigator.of(context).pop(potreiro.id),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted) return;
    await _onPotreiroFilterChanged(selected);
  }

  Widget _buildFilterOption({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? MyColors.colorPrimary : const Color(0xFF313131),
          fontFamily: 'Montserrat',
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_rounded, color: MyColors.colorPrimary)
          : null,
      onTap: onTap,
    );
  }

  String _selectedPotreiroLabel() {
    final selectedId = _selectedPotreiroId;
    if (selectedId == null) return 'Filtrar por potreiro';

    final selected = _potreirosController.potreiros
        .where((potreiro) => potreiro.id == selectedId)
        .firstOrNull;
    return selected?.nome ?? 'Potreiro selecionado';
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
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Dados'),
                Tab(text: 'Gráficos'),
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
            if (index == 0)
              _FilterSelector(
                label: _selectedPotreiroLabel(),
                isActive: _selectedPotreiroId != null,
                isLoading: _potreirosController.isLoading,
                onTap: _showPotreiroFilter,
              ),
            if (index == 0) const SizedBox(height: 16),
            if (index == 0) Expanded(child: _buildManejosList()),
            if (index == 1) const GraficosManejo(),
          ],
        ),
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
              MaterialPageRoute(builder: (_) => DetailManejo(manejo: manejo)),
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
      AppSnackBar.show(
        context: context,
        message: result.message,
        isError: false,
      );
      await _listController.reload();
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.show(
        context: context,
        message: _deleteController.errorMessage ?? 'Erro ao excluir.',
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
        return SafeArea(
          top: false,
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                    width: double.infinity,
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
                ],
              ),
            ),
          ),
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

class _FilterSelector extends StatelessWidget {
  const _FilterSelector({
    required this.label,
    required this.isActive,
    required this.isLoading,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: isLoading ? null : onTap,
      child: Container(
        width: MediaQuery.of(context).size.width - 40,
        padding: const EdgeInsets.all(16),
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: isActive ? const Color(0x14128977) : Colors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: 1,
              color: isActive ? MyColors.colorPrimary : const Color(0xFFEBEBEB),
            ),
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isActive
                      ? MyColors.colorPrimary
                      : const Color(0xFF8C8C8C),
                  fontSize: 14,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w500,
                  height: 1.50,
                ),
              ),
            ),
            const SizedBox(width: 12),
            if (isLoading)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: MyColors.colorPrimary,
                ),
              )
            else
              Icon(
                Icons.tune_rounded,
                color: isActive
                    ? MyColors.colorPrimary
                    : const Color(0xFF8C8C8C),
              ),
          ],
        ),
      ),
    );
  }
}

String _formatDecimal(double? value) {
  if (value == null) return '-';
  if (value % 1 == 0) return value.toInt().toString();
  return value.toStringAsFixed(2).replaceAll('.', ',');
}
