import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/core/components/web_dialog_frame.dart';
import 'package:costeira/core/components/web_empty_state.dart';
import 'package:costeira/core/components/web_page_dialog.dart';
import 'package:costeira/features/movimentacoes/domain/entities/nascimento_animal_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/nascimento_charts_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/nascimento_entity.dart';
import 'package:costeira/features/movimentacoes/nascimento/presentation/controllers/get_nascimento_charts_controller.dart';
import 'package:costeira/features/movimentacoes/nascimento/presentation/page_controllers/nascimentos_list_page_controller.dart';
import 'package:costeira/features/movimentacoes/nascimento/presentation/page_controllers/nascimentos_page_controller.dart';
import 'package:costeira/features/movimentacoes/nascimento/presentation/pages/nascimento_form_page.dart';
import 'package:costeira/features/movimentacoes/presentation/widgets/monthly_bar_chart_card.dart';
import 'package:costeira/features/movimentacoes/presentation/widgets/movimentacao_date_filter_sheet.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:lucide_icons/lucide_icons.dart';

class NascimentosWebPage extends StatefulWidget {
  const NascimentosWebPage({super.key});

  @override
  State<NascimentosWebPage> createState() => _NascimentosWebPageState();
}

class _NascimentosWebPageState extends State<NascimentosWebPage>
    with SingleTickerProviderStateMixin {
  late final NascimentosPageController _pageController;
  late final NascimentosListPageController _listController;
  late final GetNascimentoChartsController _chartsController;
  final ValueNotifier<int> _listRevision = ValueNotifier(0);
  final ValueNotifier<int> _chartsRevision = ValueNotifier(0);
  int? _deletingNascimentoId;
  bool _listInitialized = false;
  bool _chartsInitialized = false;

  @override
  void initState() {
    super.initState();
    _pageController = Modular.get<NascimentosPageController>();
    _listController = Modular.get<NascimentosListPageController>();
    _chartsController = Modular.get<GetNascimentoChartsController>();
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
    final message = await _listController.loadInitialData();
    if (mounted) {
      _listInitialized = true;
      _listRevision.value++;
    }
    if (!mounted || message == null) return;
    AppSnackBar.show(context: context, message: message, isError: true);
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

  Future<void> _previousMonth() async {
    try {
      await _chartsController.previousMonth();
    } catch (_) {
    } finally {
      if (mounted) {
        _chartsInitialized = true;
        _chartsRevision.value++;
      }
    }
  }

  Future<void> _nextMonth() async {
    try {
      await _chartsController.nextMonth();
    } catch (_) {
    } finally {
      if (mounted) {
        _chartsInitialized = true;
        _chartsRevision.value++;
      }
    }
  }

  Future<void> _openForm([NascimentoEntity? nascimento]) async {
    final result = await showDialog<Map<String, dynamic>?>(
      context: context,
      barrierDismissible: false,
      builder: (_) => WebPageDialog(
        title: nascimento == null
            ? 'Adicionar nascimento'
            : 'Editar nascimento',
        width: 760,
        maxHeight: 840,
        child: NascimentoFormPage(nascimento: nascimento),
      ),
    );
    if (!mounted || result?['success'] != true) return;
    await _loadList();
    if (!mounted) return;
    AppSnackBar.show(
      context: context,
      message:
          result?['message']?.toString() ?? 'Nascimento salvo com sucesso.',
      isError: false,
    );
  }

  Future<void> _openDetails(NascimentoEntity nascimento) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _NascimentoDetailsWebDialog(nascimento: nascimento),
    );
  }

  Future<void> _openFilter() async {
    final result = await showDialog<MovimentacaoDateFilterResult>(
      context: context,
      builder: (_) => _NascimentoDateFilterWebDialog(
        initialDataIn: _listController.currentDataInFilter,
        initialDataOut: _listController.currentDataOutFilter,
      ),
    );
    if (!mounted || result == null) return;
    final message = await _listController.applyDateFilters(
      dataIn: result.shouldClear ? null : result.dataIn,
      dataOut: result.shouldClear ? null : result.dataOut,
    );
    if (mounted) {
      _listInitialized = true;
      _listRevision.value++;
    }
    if (!mounted) return;
    AppSnackBar.show(
      context: context,
      message:
          message ??
          (result.shouldClear
              ? 'Filtros removidos com sucesso.'
              : 'Filtros aplicados com sucesso.'),
      isError: message != null,
    );
  }

  Future<void> _confirmDelete(NascimentoEntity nascimento) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Excluir nascimento',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          'Tem certeza que deseja excluir esse nascimento permanentemente?',
          style: TextStyle(
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
    _deletingNascimentoId = nascimento.id;
    _listRevision.value++;
    final message = await _listController.deleteNascimento(nascimento);
    if (mounted) {
      _deletingNascimentoId = null;
      _listRevision.value++;
    }
    if (!mounted) return;
    AppSnackBar.show(
      context: context,
      message: message ?? 'Nascimento excluido com sucesso.',
      isError: message != null,
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
        width: 320,
        child: TabBar(
          controller: _pageController.tabController,
          onTap: _pageController.setTabIndex,
          tabs: const [
            Tab(text: 'Lista'),
            Tab(text: 'Gráfico'),
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
    final isList = _pageController.shouldShowFab;
    return AnimatedBuilder(
      animation: isList ? _listController : _chartsController,
      builder: (context, _) => _toolbarContent(),
    );
  }

  Widget _toolbarContent() {
    final isList = _pageController.shouldShowFab;
    final loading =
        isList ? _listController.isLoading : _chartsController.isLoading;
    final count = _listController.nascimentos.length;
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
                              ? '1 nascimento cadastrado'
                              : '$count nascimentos cadastrados'
                        : 'Indicadores mensais de nascimentos',
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
                  onPressed: loading ? null : _openFilter,
                ),
                const SizedBox(width: 8),
              ],
              _ToolbarIconButton(
                tooltip: isList ? 'Atualizar lista' : 'Atualizar gráficos',
                icon: LucideIcons.refreshCw,
                isLoading: loading,
                onPressed: loading
                    ? null
                    : isList
                    ? _loadList
                    : _loadCharts,
              ),
              if (isList) ...[
                const SizedBox(width: 8),
                SizedBox(
                  height: 46,
                  child: ElevatedButton.icon(
                    onPressed: loading ? null : () => _openForm(),
                    icon: const Icon(Icons.add_rounded, size: 19),
                    label: Text(
                      compact ? 'Adicionar' : 'Adicionar nascimento',
                      softWrap: false,
                      maxLines: 1,
                    ),
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
    final isList = _pageController.tabIndex == 0;
    final revision = isList ? _listRevision : _chartsRevision;
    final Listenable loadingAnimation =
        isList ? _listController : _chartsController;
    bool isLoading() =>
        isList ? _listController.isLoading : _chartsController.isLoading;
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: ValueListenableBuilder<int>(
            valueListenable: revision,
            builder: (context, _, __) => isList ? _listTab() : _chartsTab(),
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
    if (_listController.isLoading && _listController.nascimentos.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_listController.errorMessage != null &&
        _listController.nascimentos.isEmpty) {
      return _WebStateMessage(
        message: _listController.errorMessage!,
        actionLabel: 'Tentar novamente',
        onAction: _loadList,
      );
    }
    if (_listController.nascimentos.isEmpty) {
      return WebEmptyState(
        icon: LucideIcons.baby,
        title: 'Nenhum nascimento cadastrado.',
        description:
            'Use o botão Adicionar nascimento para registrar a primeira ocorrência.',
        actionLabel: 'Adicionar nascimento',
        onAction: () => _openForm(),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;
        return Scrollbar(
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              constraints.maxWidth < 720 ? 16 : 28,
              18,
              constraints.maxWidth < 720 ? 16 : 28,
              32,
            ),
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
                  children: [
                    if (wide) const _NascimentoTableHeader(),
                    for (
                      var index = 0;
                      index < _listController.nascimentos.length;
                      index++
                    ) ...[
                      if (index > 0)
                        const Divider(height: 1, color: Color(0xFFE7E4DD)),
                      if (wide)
                        _NascimentoTableRow(
                          nascimento: _listController.nascimentos[index],
                          deleting:
                              _deletingNascimentoId ==
                              _listController.nascimentos[index].id,
                          onOpen: () => _openDetails(
                            _listController.nascimentos[index],
                          ),
                          onEdit: () =>
                              _openForm(_listController.nascimentos[index]),
                          onDelete: () => _confirmDelete(
                            _listController.nascimentos[index],
                          ),
                        )
                      else
                        _NascimentoStackedRow(
                          nascimento: _listController.nascimentos[index],
                          deleting:
                              _deletingNascimentoId ==
                              _listController.nascimentos[index].id,
                          onOpen: () => _openDetails(
                            _listController.nascimentos[index],
                          ),
                          onEdit: () =>
                              _openForm(_listController.nascimentos[index]),
                          onDelete: () => _confirmDelete(
                            _listController.nascimentos[index],
                          ),
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
    final data = charts ?? NascimentoChartsEntity.empty;
    final empty =
        data.quantidadeTerneiros == 0 && data.mesAMes.isEmpty;

    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontal = constraints.maxWidth < 720 ? 16.0 : 28.0;
        final cardWidth = constraints.maxWidth >= 720
            ? (constraints.maxWidth - (horizontal * 2) - 16) / 2
            : constraints.maxWidth - (horizontal * 2);
        return Scrollbar(
          child: ListView(
            padding: EdgeInsets.fromLTRB(horizontal, 18, horizontal, 32),
            children: [
              _MonthSelector(
                month: _chartsController.month,
                isLoading: _chartsController.isLoading,
                onPrevious: _previousMonth,
                onNext: _nextMonth,
              ),
              const SizedBox(height: 16),
              if (empty)
                const SizedBox(
                  height: 360,
                  child: WebEmptyState(
                    icon: LucideIcons.pieChart,
                    title: 'Sem dados para exibir neste período.',
                  ),
                )
              else ...[
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    SizedBox(
                      width: cardWidth,
                      child: _MetricCard(
                        title: 'Terneiros nascidos',
                        value: data.quantidadeTerneiros.toString(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                MonthlyBarChartCard(
                  title: 'Histograma de parição',
                  points: data.mesAMes
                      .map(
                        (point) => MonthlyBarChartPoint(
                          month: point.month,
                          value: point.quantity.toDouble(),
                        ),
                      )
                      .toList(),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
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

class _NascimentoTableHeader extends StatelessWidget {
  const _NascimentoTableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8F7F3),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
      child: const Row(
        children: [
          SizedBox(width: 38),
          SizedBox(width: 12),
          Expanded(flex: 3, child: _HeaderText('Registro')),
          SizedBox(width: 16),
          Expanded(flex: 4, child: _HeaderText('Matriz / Local')),
          SizedBox(width: 16),
          SizedBox(width: 100, child: _HeaderText('Data')),
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

class _NascimentoTableRow extends StatelessWidget {
  const _NascimentoTableRow({
    required this.nascimento,
    required this.deleting,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
  });

  final NascimentoEntity nascimento;
  final bool deleting;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: deleting ? null : onOpen,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              const _NascimentoIcon(),
              const SizedBox(width: 12),
              Expanded(flex: 3, child: _ValueText(_nascimentoTitle(nascimento))),
              const SizedBox(width: 16),
              Expanded(
                flex: 4,
                child: _ValueText(_nascimentoSubtitle(nascimento)),
              ),
              const SizedBox(width: 16),
              SizedBox(width: 100, child: _ValueText(nascimento.data)),
              const SizedBox(width: 16),
              SizedBox(
                width: 188,
                child: _NascimentoActions(
                  deleting: deleting,
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

class _NascimentoStackedRow extends StatelessWidget {
  const _NascimentoStackedRow({
    required this.nascimento,
    required this.deleting,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
  });

  final NascimentoEntity nascimento;
  final bool deleting;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: deleting ? null : onOpen,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _NascimentoIcon(),
                  const SizedBox(width: 12),
                  Expanded(child: _ValueText(_nascimentoTitle(nascimento))),
                ],
              ),
              const SizedBox(height: 13),
              _CompactValue(
                label: 'Local',
                value: _nascimentoSubtitle(nascimento),
              ),
              const SizedBox(height: 6),
              _CompactValue(label: 'Data', value: nascimento.data),
              const SizedBox(height: 14),
              _NascimentoActions(
                deleting: deleting,
                onEdit: onEdit,
                onDelete: onDelete,
                expanded: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NascimentoIcon extends StatelessWidget {
  const _NascimentoIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: const Color(0x14128977),
        borderRadius: BorderRadius.circular(9),
      ),
      child: const Icon(
        LucideIcons.baby,
        size: 18,
        color: MyColors.colorPrimary,
      ),
    );
  }
}

class _ValueText extends StatelessWidget {
  const _ValueText(this.value);

  final String value;

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      maxLines: 2,
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
          width: 56,
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
        Expanded(child: _ValueText(value)),
      ],
    );
  }
}

class _NascimentoActions extends StatelessWidget {
  const _NascimentoActions({
    required this.deleting,
    required this.onEdit,
    required this.onDelete,
    this.expanded = false,
  });

  final bool deleting;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    if (deleting) {
      return const SizedBox(
        height: 38,
        child: Center(
          child: SizedBox.square(
            dimension: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: MyColors.colorPrimary,
            ),
          ),
        ),
      );
    }

    final edit = SizedBox(
      width: expanded ? null : 88,
      height: 38,
      child: OutlinedButton.icon(
        onPressed: onEdit,
        icon: const Icon(LucideIcons.pencil, size: 15),
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
        onPressed: onDelete,
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

String _nascimentoTitle(NascimentoEntity nascimento) {
  final terneiros = nascimento.animais
      .where((item) => item.tipo.toLowerCase().contains('terneiro'))
      .toList();
  final count = terneiros.isNotEmpty ? terneiros.length : 1;
  final sexo = terneiros.isNotEmpty ? _sexoLabel(terneiros.first.sexo) : null;
  final sexoLabel = sexo == null ? '' : ' - $sexo';
  return '$count ${count == 1 ? 'nascimento' : 'nascimentos'}$sexoLabel';
}

String _nascimentoSubtitle(NascimentoEntity nascimento) {
  final matriz = nascimento.animais
      .where((item) => item.tipo.toLowerCase().contains('matriz'))
      .firstOrNull;
  final parts = [
    matriz?.brinco,
    matriz?.categoria?.nome,
    nascimento.potreiro?.nome,
    nascimento.lote?.nome,
  ].where((item) => item?.trim().isNotEmpty == true).map((item) => item!);

  if (parts.isEmpty) return 'Matriz não informada';
  return parts.join(' - ');
}

String? _sexoLabel(int sexo) {
  if (sexo == 1) return 'Macho';
  if (sexo == 2) return 'Fêmea';
  return null;
}

class _NascimentoDetailsWebDialog extends StatelessWidget {
  const _NascimentoDetailsWebDialog({required this.nascimento});

  final NascimentoEntity nascimento;

  Future<void> _openAnimals(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => WebPageDialog(
        title: nascimento.animais.length == 1
            ? '1 animal vinculado'
            : '${nascimento.animais.length} animais vinculados',
        width: 700,
        maxHeight: 760,
        child: _NascimentoAnimaisVinculadosWebBody(
          animais: nascimento.animais,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final terneiros = nascimento.animais
        .where((item) => item.tipo.toLowerCase().contains('terneiro'))
        .toList();
    final matriz = nascimento.animais
        .where((item) => item.tipo.toLowerCase().contains('matriz'))
        .firstOrNull;
    final terneiro = terneiros.firstOrNull;
    final hasAnimals = nascimento.animais.isNotEmpty;

    return WebDialogFrame(
      title: 'Detalhes do nascimento',
      width: 720,
      bodyPadding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DetailField(label: 'Data', value: nascimento.data),
          _DetailField(
            label: 'Brinco do terneiro',
            value: terneiro?.brinco,
          ),
          _DetailField(
            label: 'Sexo',
            value: terneiro == null ? null : _sexoLabel(terneiro.sexo),
          ),
          _DetailField(label: 'Brinco da matriz', value: matriz?.brinco),
          _DetailField(
            label: 'Categoria da matriz',
            value: matriz?.categoria?.nome,
          ),
          _DetailField(label: 'Potreiro', value: nascimento.potreiro?.nome),
          _DetailField(label: 'Lote', value: nascimento.lote?.nome),
          _DetailField(label: 'Observações', value: nascimento.obs),
          const Text(
            'Animais',
            style: TextStyle(
              color: Color(0xFF313131),
              fontSize: 14,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Material(
            color: const Color(0xFFF4F4F4),
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: hasAnimals ? () => _openAnimals(context) : null,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        !hasAnimals
                            ? 'Nenhum animal vinculado'
                            : nascimento.animais.length == 1
                            ? '1 animal vinculado'
                            : '${nascimento.animais.length} animais vinculados',
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (hasAnimals) const Icon(Icons.chevron_right_rounded),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NascimentoAnimaisVinculadosWebBody extends StatelessWidget {
  const _NascimentoAnimaisVinculadosWebBody({required this.animais});

  final List<NascimentoAnimalEntity> animais;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: MyColors.colorPrimary,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: const Text(
          'Animais vinculados',
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
        child: animais.isEmpty
            ? const WebEmptyState(
                icon: LucideIcons.tag,
                title: 'Nenhum animal vinculado.',
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                itemCount: animais.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final animal = animais[index];
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFE7E4DD)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          animal.brinco?.trim().isNotEmpty == true
                              ? animal.brinco!.trim()
                              : animal.tipo,
                          style: const TextStyle(
                            color: Color(0xFF313131),
                            fontSize: 15,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _AnimalInfoRow(label: 'Tipo', value: animal.tipo),
                        _AnimalInfoRow(
                          label: 'Categoria',
                          value: animal.categoria?.nome ?? '-',
                        ),
                        _AnimalInfoRow(
                          label: 'Sexo',
                          value: _sexoLabel(animal.sexo) ?? '-',
                        ),
                        _AnimalInfoRow(
                          label: 'Peso',
                          value: animal.pesoTotal == null
                              ? '-'
                              : '${animal.pesoTotal!.toStringAsFixed(2)} kg',
                        ),
                        _AnimalInfoRow(
                          label: 'Lote',
                          value: animal.lote?.nome ?? '-',
                        ),
                        _AnimalInfoRow(
                          label: 'Potreiro',
                          value: animal.potreiro?.nome ?? '-',
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _AnimalInfoRow extends StatelessWidget {
  const _AnimalInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        '$label  $value',
        style: const TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 12,
          color: Color(0xFF5C5C5C),
        ),
      ),
    );
  }
}

class _DetailField extends StatelessWidget {
  const _DetailField({required this.label, required this.value});

  final String label;
  final String? value;

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
              fontSize: 13,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F4F4),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE7E4DD)),
            ),
            child: Text(
              value?.trim().isNotEmpty == true ? value!.trim() : '-',
              style: const TextStyle(
                color: Color(0xFF313131),
                fontSize: 14,
                fontFamily: 'Montserrat',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NascimentoDateFilterWebDialog extends StatefulWidget {
  const _NascimentoDateFilterWebDialog({
    this.initialDataIn,
    this.initialDataOut,
  });

  final String? initialDataIn;
  final String? initialDataOut;

  @override
  State<_NascimentoDateFilterWebDialog> createState() =>
      _NascimentoDateFilterWebDialogState();
}

class _NascimentoDateFilterWebDialogState
    extends State<_NascimentoDateFilterWebDialog> {
  late final TextEditingController _startController;
  late final TextEditingController _endController;

  String? get _start => _normalized(_startController.text);
  String? get _end => _normalized(_endController.text);
  bool get _hasFilters => _start != null || _end != null;
  bool get _hadFilters =>
      _normalized(widget.initialDataIn) != null ||
      _normalized(widget.initialDataOut) != null;
  bool get _hasChanges =>
      _start != _normalized(widget.initialDataIn) ||
      _end != _normalized(widget.initialDataOut);
  bool get _canApply => _hasFilters && _hasChanges;
  bool get _canClear => _hasFilters && (_hasChanges || _hadFilters);

  @override
  void initState() {
    super.initState();
    _startController = TextEditingController(text: widget.initialDataIn ?? '');
    _endController = TextEditingController(text: widget.initialDataOut ?? '');
    _startController.addListener(_changed);
    _endController.addListener(_changed);
  }

  void _changed() => setState(() {});

  @override
  void dispose() {
    _startController.removeListener(_changed);
    _endController.removeListener(_changed);
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  Future<void> _pick(TextEditingController controller) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _parseDate(controller.text) ?? now,
      firstDate: DateTime(now.year - 20),
      lastDate: DateTime(now.year + 20),
    );
    if (picked != null) controller.text = _formatDate(picked);
  }

  @override
  Widget build(BuildContext context) {
    return WebDialogFrame(
      title: 'Filtrar período',
      width: 560,
      maxHeight: 520,
      footer: Padding(
        padding: const EdgeInsets.fromLTRB(28, 16, 28, 24),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _canClear
                    ? () => Navigator.pop(
                        context,
                        const MovimentacaoDateFilterResult(
                          dataIn: null,
                          dataOut: null,
                          shouldClear: true,
                        ),
                      )
                    : null,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  foregroundColor: MyColors.colorPrimary,
                ),
                child: const Text('Limpar'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _canApply
                    ? () => Navigator.pop(
                        context,
                        MovimentacaoDateFilterResult(
                          dataIn: _start,
                          dataOut: _end,
                          shouldClear: false,
                        ),
                      )
                    : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  elevation: 0,
                  backgroundColor: MyColors.colorPrimary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Aplicar'),
              ),
            ),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 24, 28, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DateDialogField(
              label: 'Data inicial',
              controller: _startController,
              onTap: () => _pick(_startController),
            ),
            const SizedBox(height: 20),
            _DateDialogField(
              label: 'Data final',
              controller: _endController,
              onTap: () => _pick(_endController),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateDialogField extends StatelessWidget {
  const _DateDialogField({
    required this.label,
    required this.controller,
    required this.onTap,
  });

  final String label;
  final TextEditingController controller;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          readOnly: true,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: '00/00/0000',
            filled: true,
            fillColor: const Color(0xFFF4F4F4),
            suffixIcon: const Icon(Icons.calendar_today_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE7E4DD)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE7E4DD)),
            ),
          ),
        ),
      ],
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
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF666666),
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BaseCard extends StatelessWidget {
  const _BaseCard({required this.child});

  final Widget child;

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
      child: child,
    );
  }
}

class _MonthSelector extends StatelessWidget {
  const _MonthSelector({
    required this.month,
    required this.isLoading,
    required this.onPrevious,
    required this.onNext,
  });

  final DateTime month;
  final bool isLoading;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return _BaseCard(
      child: Row(
        children: [
          IconButton(
            onPressed: isLoading ? null : onPrevious,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          Expanded(
            child: Text(
              _formatMonth(month),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            onPressed: isLoading ? null : onNext,
            icon: const Icon(Icons.arrow_forward_rounded),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 128,
      child: _BaseCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              maxLines: 2,
              style: const TextStyle(
                color: Color(0xFF8C8C8C),
                fontFamily: 'Montserrat',
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF313131),
                  fontFamily: 'Montserrat',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String? _normalized(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}

DateTime? _parseDate(String value) {
  final parts = value.split('/');
  if (parts.length != 3) return null;
  final day = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final year = int.tryParse(parts[2]);
  if (day == null || month == null || year == null) return null;
  return DateTime(year, month, day);
}

String _formatDate(DateTime value) {
  return '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
}

String _formatMonth(DateTime value) {
  return '${_monthNames[value.month - 1]} ${value.year}';
}

const _monthNames = [
  'Janeiro',
  'Fevereiro',
  'Marco',
  'Abril',
  'Maio',
  'Junho',
  'Julho',
  'Agosto',
  'Setembro',
  'Outubro',
  'Novembro',
  'Dezembro',
];
