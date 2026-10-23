import 'package:costeira/core/components/app_select_overlay.dart';
import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/core/components/custom_button.dart';
import 'package:costeira/core/components/sub_user_flag.dart';
import 'package:costeira/core/components/web_dialog_frame.dart';
import 'package:costeira/core/components/web_empty_state.dart';
import 'package:costeira/core/components/web_page_dialog.dart';
import 'package:costeira/features/potreiros/domain/entities/potreiro_charts_entity.dart';
import 'package:costeira/features/potreiros/domain/entities/potreiro_entity.dart';
import 'package:costeira/features/potreiros/presentation/controllers/get_potreiro_charts_controller.dart';
import 'package:costeira/features/potreiros/presentation/page_controllers/potreiro_list_page_controller.dart';
import 'package:costeira/features/potreiros/presentation/page_controllers/potreiros_page_controller.dart';
import 'package:costeira/features/potreiros/presentation/pages/potreiros/potreiro_edit.dart';
import 'package:costeira/features/potreiros/presentation/web/potreiro_add_web_dialog.dart';
import 'package:costeira/features/potreiros/presentation/widgets/potreiro_filter_sheet.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:lucide_icons/lucide_icons.dart';

class PotreirosWebPage extends StatefulWidget {
  const PotreirosWebPage({super.key});

  @override
  State<PotreirosWebPage> createState() => _PotreirosWebPageState();
}

class _PotreirosWebPageState extends State<PotreirosWebPage>
    with SingleTickerProviderStateMixin {
  late final PotreirosPageController _pageController;
  late final PotreiroListPageController _listController;
  late final GetPotreiroChartsController _chartsController;

  final ValueNotifier<int> _listRevision = ValueNotifier(0);
  final ValueNotifier<int> _chartsRevision = ValueNotifier(0);

  int? _deletingId;
  bool _listInitialized = false;
  bool _chartsInitialized = false;

  @override
  void initState() {
    super.initState();
    _pageController = Modular.get<PotreirosPageController>();
    _listController = Modular.get<PotreiroListPageController>();
    _chartsController = Modular.get<GetPotreiroChartsController>();
    _pageController.init(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadList();
      _loadCharts();
    });
  }

  @override
  void dispose() {
    _listRevision.dispose();
    _chartsRevision.dispose();
    _pageController.dispose();
    _listController.dispose();
    super.dispose();
  }

  Future<void> _loadList() async {
    final result = await _listController.loadInitialData();
    if (mounted) {
      _listInitialized = true;
      _listRevision.value++;
    }
    if (!mounted || result == null) return;
    AppSnackBar.show(
      context: context,
      message: result.message,
      isError: !result.isSuccess,
    );
  }

  Future<void> _loadCharts() async {
    try {
      await _chartsController.load();
    } catch (_) {
    } finally {
      if (mounted) {
        _chartsInitialized = true;
        _chartsRevision.value++;
      }
    }
  }

  Future<void> _openFilter() async {
    if (_listController.isLoading) return;
    final result = await showDialog<PotreiroFilterSheetResult>(
      context: context,
      builder: (_) => _PotreiroFilterWebDialog(
        initialStatusAtual: _listController.currentStatusFilter,
      ),
    );
    if (!mounted || result == null) return;
    final action = await _listController.applyFilters(result);
    if (mounted) {
      _listInitialized = true;
      _listRevision.value++;
    }
    if (!mounted) return;
    AppSnackBar.show(
      context: context,
      message: action.message,
      isError: !action.isSuccess,
    );
  }

  Future<void> _openAdd() async {
    final result = await openPotreiroAdd(context);
    if (!mounted || result?['success'] != true) return;
    _pageController.handleCreatedOrUpdated();
    await _loadList();
    if (!mounted) return;
    AppSnackBar.show(
      context: context,
      message: result?['message']?.toString() ?? 'Potreiro salvo com sucesso.',
      isError: false,
    );
  }

  Future<void> _openEdit(PotreiroEntity potreiro) async {
    final result = await showDialog<Map<String, dynamic>?>(
      context: context,
      barrierDismissible: false,
      builder: (_) => WebPageDialog(
        title: 'Editar potreiro',
        width: 720,
        maxHeight: 840,
        child: PotreiroEdit(potreiro: potreiro),
      ),
    );
    if (!mounted) return;
    final action = await _listController.handleEditResult(result);
    if (!mounted || action == null) return;
    if (mounted) _listRevision.value++;
    AppSnackBar.show(
      context: context,
      message: action.message,
      isError: !action.isSuccess,
    );
  }

  Future<void> _openDetails(PotreiroEntity potreiro) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _PotreiroDetailsWebDialog(potreiro: potreiro),
    );
  }

  Future<void> _confirmDelete(PotreiroEntity potreiro) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Excluir potreiro',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Tem certeza que deseja excluir ${potreiro.nome} permanentemente?',
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14,
            height: 1.45,
            color: Color(0xFF666666),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          OutlinedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFC4473A),
              side: const BorderSide(color: Color(0xFFC4473A)),
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    setState(() => _deletingId = potreiro.id);
    final action = await _listController.deletePotreiro(potreiro);
    if (mounted) {
      _listRevision.value++;
      setState(() => _deletingId = null);
    }
    if (!mounted) return;
    AppSnackBar.show(
      context: context,
      message: action.message,
      isError: !action.isSuccess,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, _) {
        return ColoredBox(
          color: Colors.white,
          child: Column(
            children: [
              _tabs(),
              const Divider(height: 1, color: Color(0xFFE7E4DD)),
              _toolbar(),
              const Divider(height: 1, color: Color(0xFFE7E4DD)),
              Expanded(child: _stableTabBody()),
            ],
          ),
        );
      },
    );
  }

  Widget _tabs() {
    return Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(
        width: 280,
        child: TabBar(
          controller: _pageController.tabController,
          onTap: _pageController.setTabIndex,
          tabs: const [
            Tab(text: 'Dados'),
            Tab(text: 'Lista'),
          ],
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: const Color(0xFF313131),
          unselectedLabelColor: const Color(0xFF8C8C8C),
          indicatorColor: MyColors.colorPrimary2,
          dividerColor: Colors.transparent,
          labelStyle: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _toolbar() {
    return AnimatedBuilder(
      animation: _pageController.tabIndex == 1
          ? _listController
          : _chartsController,
      builder: (context, _) => _toolbarContent(),
    );
  }

  Widget _toolbarContent() {
    final isList = _pageController.shouldShowFab;
    final isLoading = isList
        ? _listController.isLoading
        : _chartsController.isLoading;
    final count = _listController.potreiros.length;
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 620;
        return Padding(
          padding: EdgeInsets.fromLTRB(
            compact ? 16 : 28,
            16,
            compact ? 16 : 28,
            16,
          ),
          child: Row(
            children: [
              if (!compact)
                Expanded(
                  child: Text(
                    isList
                        ? count == 1
                              ? '1 potreiro cadastrado'
                              : '$count potreiros cadastrados'
                        : 'Indicadores de potreiros',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF777777),
                    ),
                  ),
                )
              else
                const Spacer(),
              if (isList) ...[
                _FilterButton(
                  active: _listController.hasActiveFilters(),
                  onPressed: isLoading ? null : _openFilter,
                ),
                const SizedBox(width: 8),
              ],
              _ToolbarIconButton(
                tooltip: isList ? 'Atualizar lista' : 'Atualizar gráficos',
                icon: LucideIcons.refreshCw,
                isLoading: isLoading,
                onPressed: isLoading
                    ? null
                    : isList
                    ? _loadList
                    : _loadCharts,
              ),
              if (isList) ...[
                const SizedBox(width: 8),
                SizedBox(
                  width: compact ? 126 : 170,
                  height: 46,
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : _openAdd,
                    icon: const Icon(Icons.add_rounded, size: 19),
                    label: Text(compact ? 'Adicionar' : 'Adicionar potreiro'),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      backgroundColor: MyColors.colorPrimary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFFBFC9C5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                      textStyle: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _stableTabBody() {
    final isList = _pageController.tabIndex == 1;
    final revision = isList ? _listRevision : _chartsRevision;
    final Listenable loadingAnimation = isList
        ? _listController
        : _chartsController;
    bool isLoading() =>
        isList ? _listController.isLoading : _chartsController.isLoading;

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: ValueListenableBuilder<int>(
            valueListenable: revision,
            builder: (context, _, __) =>
                isList ? _listTab() : _chartsTab(),
          ),
        ),
        AnimatedBuilder(
          animation: loadingAnimation,
          builder: (context, _) => isLoading()
              ? const Align(
                  alignment: Alignment.topCenter,
                  child: LinearProgressIndicator(
                    minHeight: 2,
                    color: MyColors.colorPrimary,
                    backgroundColor: Color(0xFFE6EEE8),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _listTab() {
    if (!_listInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_listController.isLoading && _listController.potreiros.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_listController.errorMessage != null &&
        _listController.potreiros.isEmpty) {
      return _WebStateMessage(
        message: _listController.errorMessage!,
        actionLabel: 'Tentar novamente',
        onAction: _loadList,
      );
    }
    if (_listController.potreiros.isEmpty) {
      return WebEmptyState(
        icon: LucideIcons.mapPin,
        title: 'Nenhum potreiro cadastrado até agora.',
        description: 'Use o botão Adicionar potreiro para cadastrar o primeiro.',
        actionLabel: 'Adicionar potreiro',
        onAction: _openAdd,
      );
    }

    final itens = _listController.potreiros;
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;
        final horizontal = constraints.maxWidth < 720 ? 16.0 : 28.0;
        return Scrollbar(
          child: ListView(
            padding: EdgeInsets.fromLTRB(horizontal, 18, horizontal, 32),
            children: [
              Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                foregroundDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE7E4DD)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (wide) const _PotreiroTableHeader(),
                    for (var index = 0; index < itens.length; index++) ...[
                      if (index > 0)
                        const Divider(height: 1, color: Color(0xFFE7E4DD)),
                      if (wide)
                        _PotreiroTableRow(
                          potreiro: itens[index],
                          busy: _deletingId == itens[index].id,
                          onOpen: () => _openDetails(itens[index]),
                          onEdit: () => _openEdit(itens[index]),
                          onDelete: () => _confirmDelete(itens[index]),
                        )
                      else
                        _PotreiroStackedRow(
                          potreiro: itens[index],
                          busy: _deletingId == itens[index].id,
                          onOpen: () => _openDetails(itens[index]),
                          onEdit: () => _openEdit(itens[index]),
                          onDelete: () => _confirmDelete(itens[index]),
                        ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _chartsTab() {
    if (!_chartsInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    final charts = _chartsController.charts;
    if (_chartsController.isLoading && charts == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_chartsController.errorMessage != null && charts == null) {
      return _WebStateMessage(
        message: _chartsController.errorMessage!,
        actionLabel: 'Tentar novamente',
        onAction: _loadCharts,
      );
    }
    if (charts == null || charts.tabelaAreas.isEmpty) {
      return const WebEmptyState(
        icon: LucideIcons.pieChart,
        title: 'Sem dados para exibir neste período.',
      );
    }

    final dominantAgua = _findDominantLevel(charts.agua);
    final dominantSombra = _findDominantLevel(charts.sombra);

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 980;
        final horizontal = constraints.maxWidth < 720 ? 16.0 : 28.0;
        return Scrollbar(
          child: ListView(
            padding: EdgeInsets.fromLTRB(horizontal, 18, horizontal, 32),
            children: [
              if (wide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _MetricCard(
                        title: 'Área total',
                        value: '${_formatDecimal(charts.areaTotalSomada)} ha',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _MetricCard(
                        title: 'Área útil',
                        value: '${_formatDecimal(charts.areaUtilSomada)} ha',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _MetricCard(
                        title: 'Uso',
                        value: '${_formatDecimal(charts.percentualUso)}%',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _MetricCard(
                        title: 'Campo perdido',
                        value:
                            '${_formatDecimal(charts.percentualCampoPerdido)}%',
                        subtitle: '${_formatDecimal(charts.areaPerdida)} ha',
                      ),
                    ),
                  ],
                )
              else ...[
                _MetricCard(
                  title: 'Área total',
                  value: '${_formatDecimal(charts.areaTotalSomada)} ha',
                ),
                const SizedBox(height: 12),
                _MetricCard(
                  title: 'Área útil',
                  value: '${_formatDecimal(charts.areaUtilSomada)} ha',
                ),
                const SizedBox(height: 12),
                _MetricCard(
                  title: 'Uso',
                  value: '${_formatDecimal(charts.percentualUso)}%',
                ),
                const SizedBox(height: 12),
                _MetricCard(
                  title: 'Campo perdido',
                  value: '${_formatDecimal(charts.percentualCampoPerdido)}%',
                  subtitle: '${_formatDecimal(charts.areaPerdida)} ha',
                ),
              ],
              const SizedBox(height: 16),
              if (wide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _AvailabilityPanel(
                        title: 'Acesso a água',
                        percentual: dominantAgua.percentual,
                        nivel: dominantAgua.nivel,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _AvailabilityPanel(
                        title: 'Acesso a sombra',
                        percentual: dominantSombra.percentual,
                        nivel: dominantSombra.nivel,
                      ),
                    ),
                  ],
                )
              else ...[
                _AvailabilityPanel(
                  title: 'Acesso a água',
                  percentual: dominantAgua.percentual,
                  nivel: dominantAgua.nivel,
                ),
                const SizedBox(height: 12),
                _AvailabilityPanel(
                  title: 'Acesso a sombra',
                  percentual: dominantSombra.percentual,
                  nivel: dominantSombra.nivel,
                ),
              ],
              const SizedBox(height: 16),
              _AreasTable(items: charts.tabelaAreas),
            ],
          ),
        );
      },
    );
  }
}

PotreiroChartsLevelEntity _findDominantLevel(
  List<PotreiroChartsLevelEntity> items,
) {
  if (items.isEmpty) {
    return const PotreiroChartsLevelEntity(
      nivel: '',
      quantidade: 0,
      percentual: 0,
    );
  }
  var dominant = items.first;
  for (final item in items.skip(1)) {
    if (item.percentual > dominant.percentual) {
      dominant = item;
    }
  }
  return dominant;
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.active, required this.onPressed});

  final bool active;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 128,
      height: 46,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.tune_rounded, size: 17),
        label: Text(active ? 'Filtros ativos' : 'Filtrar'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          foregroundColor: MyColors.colorPrimary,
          backgroundColor: active ? const Color(0x14128977) : Colors.white,
          side: BorderSide(
            color: active ? MyColors.colorPrimary : const Color(0xFFC9D4CB),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
          textStyle: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _ToolbarIconButton extends StatelessWidget {
  const _ToolbarIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    required this.isLoading,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: SizedBox(
        width: 46,
        height: 46,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: MyColors.colorPrimary,
            backgroundColor: Colors.white,
            padding: EdgeInsets.zero,
            side: const BorderSide(color: Color(0xFFC9D4CB)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(9),
            ),
          ),
          child: isLoading
              ? const SizedBox.square(
                  dimension: 17,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: MyColors.colorPrimary,
                  ),
                )
              : Icon(icon, size: 17),
        ),
      ),
    );
  }
}

class _PotreiroTableHeader extends StatelessWidget {
  const _PotreiroTableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8F7F3),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
      child: const Row(
        children: [
          Expanded(flex: 3, child: _HeaderText('Potreiro')),
          SizedBox(width: 16),
          Expanded(flex: 2, child: _HeaderText('Área')),
          SizedBox(width: 16),
          Expanded(flex: 2, child: _HeaderText('Acesso água')),
          SizedBox(width: 16),
          Expanded(flex: 2, child: _HeaderText('Status')),
          SizedBox(width: 16),
          SizedBox(width: 188),
        ],
      ),
    );
  }
}

class _HeaderText extends StatelessWidget {
  const _HeaderText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontFamily: 'Montserrat',
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: .35,
        color: Color(0xFF777777),
      ),
    );
  }
}

class _PotreiroTableRow extends StatelessWidget {
  const _PotreiroTableRow({
    required this.potreiro,
    required this.busy,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
  });

  final PotreiroEntity potreiro;
  final bool busy;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: busy ? null : onOpen,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _potreiroTitle(potreiro),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF313131),
                        fontSize: 13,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SubUserFlag(nome: potreiro.subUsuarioNome),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: _CellText(
                  '${_decimal(potreiro.areaUtil)} ha / ${_decimal(potreiro.areaTotal)} ha',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: _CellText(_displayOrDash(potreiro.acessoAgua)),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: _CellText(_displayOrDash(potreiro.statusAtual)),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 188,
                child: _RowActions(
                  busy: busy,
                  onEdit: onEdit,
                  onDelete: onDelete,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PotreiroStackedRow extends StatelessWidget {
  const _PotreiroStackedRow({
    required this.potreiro,
    required this.busy,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
  });

  final PotreiroEntity potreiro;
  final bool busy;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: busy ? null : onOpen,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _potreiroTitle(potreiro),
                style: const TextStyle(
                  color: Color(0xFF313131),
                  fontSize: 14,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w700,
                ),
              ),
              SubUserFlag(nome: potreiro.subUsuarioNome),
              const SizedBox(height: 10),
              _CompactValue(
                label: 'Área',
                value:
                    '${_decimal(potreiro.areaUtil)} ha / ${_decimal(potreiro.areaTotal)} ha',
              ),
              const SizedBox(height: 6),
              _CompactValue(
                label: 'Água',
                value: _displayOrDash(potreiro.acessoAgua),
              ),
              const SizedBox(height: 6),
              _CompactValue(
                label: 'Status',
                value: _displayOrDash(potreiro.statusAtual),
              ),
              const SizedBox(height: 14),
              _RowActions(
                busy: busy,
                expanded: true,
                onEdit: onEdit,
                onDelete: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RowActions extends StatelessWidget {
  const _RowActions({
    required this.busy,
    required this.onEdit,
    required this.onDelete,
    this.expanded = false,
  });

  final bool busy;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final edit = SizedBox(
      width: expanded ? null : 88,
      height: 38,
      child: OutlinedButton.icon(
        onPressed: busy ? null : onEdit,
        icon: busy
            ? const SizedBox.square(
                dimension: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(LucideIcons.pencil, size: 15),
        label: const Text('Editar'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          foregroundColor: MyColors.colorPrimary,
          side: const BorderSide(color: Color(0xFFBFD4C7)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
    final remove = SizedBox(
      width: expanded ? null : 92,
      height: 38,
      child: OutlinedButton.icon(
        onPressed: busy ? null : onDelete,
        icon: const Icon(LucideIcons.trash2, size: 15),
        label: const Text('Excluir'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 9),
          foregroundColor: const Color(0xFFC4473A),
          side: const BorderSide(color: Color(0xFFE1B8B2)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
    return Row(
      mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
      children: [
        if (expanded) Expanded(child: edit) else edit,
        const SizedBox(width: 8),
        if (expanded) Expanded(child: remove) else remove,
      ],
    );
  }
}

class _CellText extends StatelessWidget {
  const _CellText(this.value);

  final String value;

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontFamily: 'Montserrat',
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Color(0xFF4F5652),
      ),
    );
  }
}

class _CompactValue extends StatelessWidget {
  const _CompactValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 64,
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF8A8A8A),
            ),
          ),
        ),
        Expanded(child: _CellText(value)),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    this.subtitle,
  });

  final String title;
  final String value;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE7E4DD)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF8C8C8C),
              fontSize: 12,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF313131),
              fontSize: 18,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w700,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: const TextStyle(
                color: Color(0xFF5C5C5C),
                fontSize: 12,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AvailabilityPanel extends StatelessWidget {
  const _AvailabilityPanel({
    required this.title,
    required this.percentual,
    required this.nivel,
  });

  final String title;
  final double percentual;
  final String nivel;

  @override
  Widget build(BuildContext context) {
    final clamped = percentual.clamp(0, 100).toDouble();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE7E4DD)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF313131),
              fontSize: 14,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            nivel.trim().isEmpty ? '-' : nivel,
            style: const TextStyle(
              color: Color(0xFF8C8C8C),
              fontSize: 12,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 10,
            width: double.infinity,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: clamped / 100,
                minHeight: 10,
                backgroundColor: const Color(0xFFEBEBEB),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  MyColors.colorPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${_formatDecimal(clamped)}%',
              style: const TextStyle(
                color: Color(0xFF5C5C5C),
                fontSize: 12,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AreasTable extends StatelessWidget {
  const _AreasTable({required this.items});

  final List<PotreiroAreaTableItemEntity> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE7E4DD)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: const Color(0xFFF8F7F3),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
            child: const Row(
              children: [
                Expanded(flex: 3, child: _HeaderText('Nome')),
                SizedBox(width: 12),
                Expanded(flex: 2, child: _HeaderText('Status')),
                SizedBox(width: 12),
                Expanded(flex: 2, child: _HeaderText('Área útil')),
                SizedBox(width: 12),
                Expanded(flex: 2, child: _HeaderText('Área total')),
                SizedBox(width: 12),
                Expanded(flex: 2, child: _HeaderText('Uso')),
              ],
            ),
          ),
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: Color(0xFFE7E4DD)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Expanded(flex: 3, child: _CellText(items[i].nome)),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: _CellText(_displayOrDash(items[i].statusAtual)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: _CellText('${_formatDecimal(items[i].areaUtil)} ha'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: _CellText(
                      '${_formatDecimal(items[i].areaTotal)} ha',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: _CellText(
                      '${_formatDecimal(items[i].percentualUso)}%',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _WebStateMessage extends StatelessWidget {
  const _WebStateMessage({
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
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14,
                color: Color(0xFF666666),
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              TextButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

class _PotreiroFilterWebDialog extends StatefulWidget {
  const _PotreiroFilterWebDialog({this.initialStatusAtual});

  final String? initialStatusAtual;

  @override
  State<_PotreiroFilterWebDialog> createState() =>
      _PotreiroFilterWebDialogState();
}

class _PotreiroFilterWebDialogState extends State<_PotreiroFilterWebDialog> {
  static const _statusOptions = ['PECUARIA', 'LAVOURA'];
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.initialStatusAtual;
  }

  @override
  Widget build(BuildContext context) {
    return WebDialogFrame(
      title: 'Filtros',
      width: 480,
      maxHeight: 420,
      footer: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  PotreiroFilterSheetResult.apply(
                    statusAtual: _selectedStatus,
                  ),
                );
              },
              text: 'Aplicar',
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  const PotreiroFilterSheetResult.clear(),
                );
              },
              child: const Text('Limpar filtros'),
            ),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
        child: AppSelectOverlay<String>(
          value: _selectedStatus,
          placeholder: 'Status atual',
          options: [
            for (final status in _statusOptions)
              AppSelectOption(value: status, label: status),
          ],
          onChanged: (value) => setState(() => _selectedStatus = value),
        ),
      ),
    );
  }
}

class _PotreiroDetailsWebDialog extends StatelessWidget {
  const _PotreiroDetailsWebDialog({required this.potreiro});

  final PotreiroEntity potreiro;

  @override
  Widget build(BuildContext context) {
    return WebDialogFrame(
      title: 'Detalhes do potreiro',
      width: 640,
      maxHeight: 760,
      bodyPadding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _DetailField(label: 'Nome', value: potreiro.nome),
          _DetailField(
            label: 'Área total',
            value: _formatMeasure(potreiro.areaTotal),
          ),
          _DetailField(
            label: 'Área utilizável',
            value: _formatMeasure(potreiro.areaUtil),
          ),
          _DetailField(
            label: 'Status atual',
            value: _displayOrDash(potreiro.statusAtual),
          ),
          _DetailField(
            label: 'Tipo forragem',
            value: _displayOrDash(potreiro.tipoForragem),
          ),
          _DetailField(
            label: 'Acesso a água',
            value: _displayOrDash(potreiro.acessoAgua),
          ),
          _DetailField(
            label: 'Acesso a sombra',
            value: _displayOrDash(potreiro.acessoSombra),
          ),
          _DetailField(
            label: 'Lotação média',
            value: _formatValue(potreiro.lotacaoMedia),
          ),
          _DetailField(
            label: 'Observações',
            value: _displayOrDash(potreiro.obs),
          ),
        ],
      ),
    );
  }
}

class _DetailField extends StatelessWidget {
  const _DetailField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF313131),
              fontSize: 14,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFEBEBEB),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF313131),
                fontSize: 14,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _potreiroTitle(PotreiroEntity potreiro) {
  final status = (potreiro.statusAtual ?? '').trim();
  if (status.isEmpty) return potreiro.nome;
  return '${potreiro.nome} - $status';
}

String _decimal(double? value) {
  if (value == null) return '-';
  if (value == value.truncateToDouble()) return value.toStringAsFixed(0);
  return value.toStringAsFixed(2);
}

String _formatDecimal(double value) {
  if (value == value.truncateToDouble()) return value.toStringAsFixed(0);
  return value.toStringAsFixed(2);
}

String _displayOrDash(String? value) {
  final text = value?.trim() ?? '';
  return text.isEmpty ? '-' : text;
}

String _formatMeasure(double? value) {
  if (value == null) return '-';
  return '${_decimal(value)} ha';
}

String _formatValue(double? value) {
  if (value == null) return '-';
  return _decimal(value);
}
