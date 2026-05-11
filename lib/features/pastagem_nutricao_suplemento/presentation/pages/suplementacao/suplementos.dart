import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/entities/suplemento.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/presentation/controllers/delete_suplemento_controller.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/presentation/controllers/list_suplementos_controller.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/presentation/pages/suplementacao/add_suplemento.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/presentation/pages/suplementacao/add_suplemento_registro.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/presentation/pages/suplementacao/detail_suplemento.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'edit_suplemento.dart';
import 'graficos_suplemento.dart';

class Suplementos extends StatefulWidget {
  const Suplementos({super.key});

  @override
  State<Suplementos> createState() => _SuplementosState();
}

class _SuplementosState extends State<Suplementos>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final ListSuplementosController _controller;
  late final DeleteSuplementoController _deleteController;
  int index = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _controller = Modular.get<ListSuplementosController>()..addListener(_sync);
    _deleteController = Modular.get<DeleteSuplementoController>()
      ..addListener(_sync);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _controller.removeListener(_sync);
    _deleteController.removeListener(_sync);
    _tabController.dispose();
    super.dispose();
  }

  void _sync() {
    if (mounted) setState(() {});
  }

  Future<void> _load() async {
    try {
      await _controller.load();
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.show(
        context: context,
        message: _controller.errorMessage ?? 'Erro ao listar suplementos.',
      );
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
              onPressed: () async {
                final changed = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(builder: (_) => const AddSuplemento()),
                );
                if (changed == true) {
                  await _controller.reload();
                }
              },
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      appBar: AppBar(
        backgroundColor: MyColors.colorPrimary,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: const Text(
          'Suplementação e Consumo',
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
              Tab(text: 'Registros'),
              Tab(text: 'Gráficos'),
            ],
            onTap: (value) => setState(() => index = value),
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
          if (index == 0)
            Expanded(
              child: _DadosTab(
                controller: _controller,
                onChanged: _controller.reload,
                onDelete: _deleteSuplemento,
                onShowRegistros: () {
                  _tabController.animateTo(1);
                  setState(() => index = 1);
                },
              ),
            ),
          if (index == 1)
            Expanded(
              child: _RegistrosTab(
                registros: _controller.registros,
                onChanged: _controller.reload,
                onDelete: _deleteRegistro,
              ),
            ),
          if (index == 2) const Expanded(child: GraficosSuplemento()),
        ],
      ),
    );
  }

  Future<void> _deleteSuplemento(Suplemento suplemento) async {
    final confirmed = await _showDeleteSheet(
      context,
      title: 'Excluir suplementacao e consumo',
      description:
          'Tem certeza que deseja excluir essa suplementacao e consumo permanentemente?',
    );
    if (confirmed != true) return;

    try {
      final result = await _deleteController.deleteSuplemento(suplemento.id);
      if (!mounted) return;
      AppSnackBar.show(
        context: context,
        message: result.message,
        isError: false,
      );
      await _controller.reload();
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.show(
        context: context,
        message:
            _deleteController.errorMessage ?? 'Erro ao excluir suplementacao.',
      );
    }
  }

  Future<void> _deleteRegistro(SuplementoRegistro registro) async {
    final confirmed = await _showDeleteSheet(
      context,
      title: 'Excluir registro',
      description: 'Tem certeza que deseja excluir esse registro?',
    );
    if (confirmed != true) return;

    try {
      final result = await _deleteController.deleteRegistro(registro.id);
      if (!mounted) return;
      AppSnackBar.show(
        context: context,
        message: result.message,
        isError: false,
      );
      await _controller.reload();
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.show(
        context: context,
        message: _deleteController.errorMessage ?? 'Erro ao excluir registro.',
      );
    }
  }

  Future<bool?> _showDeleteSheet(
    BuildContext context, {
    required String title,
    required String description,
  }) {
    return showModalBottomSheet<bool>(
      backgroundColor: Colors.white,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 72, height: 2, color: const Color(0xFFE2E2E2)),
                const SizedBox(height: 24),
                SvgPicture.asset(
                  'icon/danger-linear.svg',
                  width: 80,
                  height: 80,
                  colorFilter: const ColorFilter.mode(
                    Colors.red,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
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
                    onPressed: () => Navigator.of(sheetContext).pop(true),
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
                  onPressed: () => Navigator.of(sheetContext).pop(false),
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
        );
      },
    );
  }
}

class _DadosTab extends StatelessWidget {
  const _DadosTab({
    required this.controller,
    required this.onChanged,
    required this.onDelete,
    required this.onShowRegistros,
  });

  final ListSuplementosController controller;
  final Future<void> Function() onChanged;
  final Future<void> Function(Suplemento suplemento) onDelete;
  final VoidCallback onShowRegistros;

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.suplementos.isEmpty) {
      return const Center(child: Text('Nenhum suplemento encontrado.'));
    }

    return RefreshIndicator(
      onRefresh: controller.reload,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 88),
        children: [
          _ResumoCard(suplementos: controller.suplementos),
          const SizedBox(height: 16),
          ...controller.suplementos.map(
            (suplemento) => _SuplementoCard(
              suplemento: suplemento,
              onChanged: onChanged,
              onDelete: onDelete,
              onShowRegistros: onShowRegistros,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResumoCard extends StatelessWidget {
  const _ResumoCard({required this.suplementos});

  final List<Suplemento> suplementos;

  @override
  Widget build(BuildContext context) {
    final consumos = suplementos
        .map((item) => _parseBrDouble(item.consumoReal?.consumoRealAnimalDia))
        .whereType<double>()
        .toList();
    final media = consumos.isEmpty
        ? null
        : consumos.reduce((a, b) => a + b) / consumos.length;

    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Consumo real',
            style: TextStyle(
              color: Color(0xFF8C8C8C),
              fontSize: 12,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            media == null ? '-' : '${media.toStringAsFixed(2)} kg/animal/dia',
            style: const TextStyle(
              color: Color(0xFF313131),
              fontSize: 14,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SuplementoCard extends StatelessWidget {
  const _SuplementoCard({
    required this.suplemento,
    required this.onChanged,
    required this.onDelete,
    required this.onShowRegistros,
  });

  final Suplemento suplemento;
  final Future<void> Function() onChanged;
  final Future<void> Function(Suplemento suplemento) onDelete;
  final VoidCallback onShowRegistros;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DetailSuplemento()),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: _SurfaceCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _IconBadge(asset: 'icon/diamond.svg'),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      suplemento.potreiro?.nome ?? 'Potreiro nao informado',
                      style: const TextStyle(
                        color: Color(0xFF313131),
                        fontSize: 14,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${suplemento.lote?.nome ?? 'Lote nao informado'} - ${suplemento.produto?.nome ?? 'Produto nao informado'}',
                      style: const TextStyle(
                        color: Color(0xFF313131),
                        fontSize: 12,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _MetricChip(
                          label: 'Peso medio',
                          value: _kg(suplemento.pesoMedio),
                        ),
                        _MetricChip(
                          label: 'Qtd animais',
                          value:
                              suplemento.quantidadeAnimais?.toString() ?? '-',
                        ),
                        _MetricChip(
                          label: 'Qtd atual',
                          value: _kg(suplemento.quantidadeAtual),
                        ),
                        _MetricChip(
                          label: 'Consumo animal',
                          value: _consumoAnimal(suplemento),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Data: ${suplemento.dataPostagem ?? '-'}',
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
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) async {
                  if (value == 'edit') {
                    final changed = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditSuplemento(suplemento: suplemento),
                      ),
                    );
                    if (changed == true) await onChanged();
                    return;
                  }
                  if (value == 'delete') {
                    await onDelete(suplemento);
                    return;
                  }
                  if (value == 'registros') {
                    onShowRegistros();
                    return;
                  }
                  if (value == 'add_registro') {
                    final changed = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AddSuplementoRegistro(suplemento: suplemento),
                      ),
                    );
                    if (changed == true) await onChanged();
                    return;
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'edit', child: Text('Editar')),
                  PopupMenuItem(value: 'delete', child: Text('Excluir')),
                  PopupMenuItem(
                    value: 'add_registro',
                    child: Text('Adicionar registro'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RegistrosTab extends StatelessWidget {
  const _RegistrosTab({
    required this.registros,
    required this.onChanged,
    required this.onDelete,
  });

  final List<SuplementoRegistro> registros;
  final Future<void> Function() onChanged;
  final Future<void> Function(SuplementoRegistro registro) onDelete;

  @override
  Widget build(BuildContext context) {
    if (registros.isEmpty) {
      return const Center(child: Text('Nenhum registro encontrado.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      itemCount: registros.length,
      itemBuilder: (context, index) {
        final registro = registros[index];
        final suplemento = registro.suplemento;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _SurfaceCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _IconBadge(
                  icon: registro.tipo.id == 1 ? Icons.add : Icons.remove,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        registro.tipo.nome.isEmpty
                            ? 'Registro'
                            : registro.tipo.nome,
                        style: const TextStyle(
                          color: Color(0xFF313131),
                          fontSize: 14,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${suplemento?.potreiro?.nome ?? 'Potreiro nao informado'} - ${suplemento?.produto?.nome ?? 'Produto nao informado'}',
                        style: const TextStyle(
                          color: Color(0xFF313131),
                          fontSize: 12,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_kg(registro.quantidade)} em ${registro.dataRestabastecimento ?? '-'}',
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
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) async {
                    if (value == 'edit' && suplemento != null) {
                      final changed = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddSuplementoRegistro(
                            suplemento: suplemento,
                            registro: registro,
                          ),
                        ),
                      );
                      if (changed == true) await onChanged();
                      return;
                    }
                    if (value == 'delete') {
                      await onDelete(registro);
                      return;
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'edit', child: Text('Editar')),
                    PopupMenuItem(value: 'delete', child: Text('Excluir')),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
      child: child,
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({this.asset, this.icon});

  final String? asset;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: ShapeDecoration(
        color: const Color(0x198C8C8C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(42)),
      ),
      child: asset != null
          ? SvgPicture.asset(
              asset!,
              width: 16,
              height: 16,
              colorFilter: const ColorFilter.mode(
                Color(0xFF8C8C8C),
                BlendMode.srcIn,
              ),
            )
          : Icon(icon, size: 16, color: const Color(0xFF8C8C8C)),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF8C8C8C),
              fontSize: 10,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF313131),
              fontSize: 12,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

String _kg(double? value) =>
    value == null ? '-' : '${value.toStringAsFixed(2)} kg';

String _consumoAnimal(Suplemento suplemento) {
  final value = suplemento.consumoReal?.consumoRealAnimalDia;
  if (value == null || value.isEmpty) return '-';
  return '$value kg/dia';
}

double? _parseBrDouble(String? value) {
  if (value == null || value.isEmpty) return null;
  return double.tryParse(value.replaceAll(',', '.'));
}
