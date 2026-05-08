import 'package:costeira/features/sanitarios/domain/entities/sanitario.dart';
import 'package:costeira/features/sanitarios/presentation/controllers/list_sanitarios_controller.dart';
import 'package:costeira/features/sanitarios/presentation/pages/addplanejamento.dart';
import 'package:costeira/features/sanitarios/presentation/pages/detailexecucoes.dart';
import 'package:costeira/features/sanitarios/presentation/pages/graficosexecucoes.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Execucoes extends StatefulWidget {
  const Execucoes({super.key});

  @override
  State<Execucoes> createState() => _ExecucoesState();
}

class _ExecucoesState extends State<Execucoes>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final ListSanitariosController _controller;
  int index = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _controller = Modular.get<ListSanitariosController>();
    WidgetsBinding.instance.addPostFrameCallback((_) => _controller.load());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: MyColors.colorPrimary,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: const Text(
          'Execuções',
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
              Tab(text: 'Lista'),
              Tab(text: 'Gráficos'),
            ],
            onTap: (value) => setState(() => index = value),
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
            Expanded(child: _ExecucoesList(controller: _controller)),
          if (index == 1) GraficosExcucao(),
        ],
      ),
    );
  }
}

class _ExecucoesList extends StatelessWidget {
  const _ExecucoesList({required this.controller});

  final ListSanitariosController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage != null) {
          return _FeedbackState(
            message: controller.errorMessage!,
            actionLabel: 'Tentar novamente',
            onAction: () => controller.load(),
          );
        }

        final sanitarios = controller.executados;
        if (sanitarios.isEmpty) {
          return const _FeedbackState(message: 'Nenhuma execução encontrada.');
        }

        return RefreshIndicator(
          onRefresh: controller.reload,
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 16, bottom: 24),
            itemCount: sanitarios.length,
            itemBuilder: (context, index) {
              return _ExecucaoCard(sanitario: sanitarios[index]);
            },
          ),
        );
      },
    );
  }
}

class _ExecucaoCard extends StatelessWidget {
  const _ExecucaoCard({required this.sanitario});

  final SanitarioEntity sanitario;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DetailExecucao()),
        );
      },
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
          shadows: const [BoxShadow(color: Color(0x0A000000), blurRadius: 24)],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _IconBadge(),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(sanitario.tipoManejo, style: _primaryStyle),
                  const SizedBox(height: 8),
                  Text(_targets, style: _primaryStyle.copyWith(fontSize: 12)),
                  const SizedBox(height: 8),
                  Text(_insumos, style: _secondaryStyle),
                  const SizedBox(height: 8),
                  Text(
                    'Realizado em ${sanitario.dataExecucao ?? '-'}',
                    style: _secondaryStyle,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              children: [
                GestureDetector(
                  onTap: () {},
                  child: SvgPicture.asset('icon/trash.svg'),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddPlanejamento(sanitario: sanitario),
                      ),
                    );
                  },
                  child: SvgPicture.asset('icon/square-pen.svg'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String get _targets {
    final lotes = sanitario.lotes
        .map((item) => item.nome.trim())
        .where((item) => item.isNotEmpty);
    final categorias = sanitario.categorias
        .map((item) => item.nome.trim())
        .where((item) => item.isNotEmpty);
    final values = [...lotes, ...categorias].join(' • ');
    return values.isEmpty ? 'Sem lote ou categoria vinculada' : values;
  }

  String get _insumos {
    final values = sanitario.insumos
        .map((item) => item.nome.trim())
        .where((item) => item.isNotEmpty)
        .join(', ');
    return values.isEmpty ? 'Sem insumo vinculado' : values;
  }

  TextStyle get _primaryStyle => const TextStyle(
    color: Color(0xFF313131),
    fontSize: 14,
    fontFamily: 'Montserrat',
    fontWeight: FontWeight.w500,
  );

  TextStyle get _secondaryStyle => const TextStyle(
    color: Color(0xFF8C8C8C),
    fontSize: 12,
    fontFamily: 'Montserrat',
    fontWeight: FontWeight.w500,
  );
}

class _IconBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: ShapeDecoration(
        color: const Color(0x198C8C8C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(42)),
      ),
      child: SvgPicture.asset(
        'icon/square-chart-gantt.svg',
        width: 16,
        height: 16,
        colorFilter: const ColorFilter.mode(Color(0xFF8C8C8C), BlendMode.srcIn),
      ),
    );
  }
}

class _FeedbackState extends StatelessWidget {
  const _FeedbackState({
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF8C8C8C),
                fontSize: 14,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w500,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 12),
              TextButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
