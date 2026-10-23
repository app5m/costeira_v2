import 'dart:math' as math;

import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/core/components/web_dialog_frame.dart';
import 'package:costeira/core/components/web_empty_state.dart';
import 'package:costeira/core/components/web_page_dialog.dart';
import 'package:costeira/features/movimentacoes/domain/entities/morte_animal_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/morte_charts_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/morte_entity.dart';
import 'package:costeira/features/movimentacoes/mortes/presentation/controllers/get_morte_charts_controller.dart';
import 'package:costeira/features/movimentacoes/mortes/presentation/page_controllers/mortes_list_page_controller.dart';
import 'package:costeira/features/movimentacoes/mortes/presentation/pages/morte_form_page.dart';
import 'package:costeira/features/movimentacoes/presentation/widgets/monthly_bar_chart_card.dart';
import 'package:costeira/features/movimentacoes/presentation/widgets/movimentacao_date_filter_sheet.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:lucide_icons/lucide_icons.dart';

class MortesWebPage extends StatefulWidget {
  const MortesWebPage({super.key});

  @override
  State<MortesWebPage> createState() => _MortesWebPageState();
}

class _MortesWebPageState extends State<MortesWebPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final MortesListPageController _listController;
  late final GetMorteChartsController _chartsController;
  final ValueNotifier<int> _listRevision = ValueNotifier(0);
  final ValueNotifier<int> _chartsRevision = ValueNotifier(0);
  int _tabIndex = 0;
  int? _deletingMorteId;
  bool _listInitialized = false;
  bool _chartsInitialized = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _listController = Modular.get<MortesListPageController>();
    _chartsController = Modular.get<GetMorteChartsController>();
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
    _tabController.dispose();
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

  Future<void> _openForm([MorteEntity? morte]) async {
    final result = await showDialog<Map<String, dynamic>?>(
      context: context,
      barrierDismissible: false,
      builder: (_) => WebDialogFrame(
        title: morte == null ? 'Adicionar morte' : 'Editar morte',
        width: 720,
        maxHeight: 840,
        sizeMode: WebDialogSizeMode.fitContent,
        scrollableBody: true,
        bodyPadding: const EdgeInsets.fromLTRB(28, 12, 28, 24),
        child: MorteFormPage(morte: morte, embeddedInWebDialog: true),
      ),
    );
    if (!mounted || result?['success'] != true) return;
    await _loadList();
    if (!mounted) return;
    AppSnackBar.show(
      context: context,
      message: result?['message']?.toString() ?? 'Morte salva com sucesso.',
      isError: false,
    );
  }

  Future<void> _openDetails(MorteEntity morte) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _MorteDetailsWebDialog(morte: morte),
    );
  }

  Future<void> _openFilter() async {
    final result = await showDialog<MovimentacaoDateFilterResult>(
      context: context,
      builder: (_) => _MorteDateFilterWebDialog(
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

  Future<void> _confirmDelete(MorteEntity morte) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Excluir morte',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          'Tem certeza que deseja excluir essa morte permanentemente?',
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
    _deletingMorteId = morte.id;
    _listRevision.value++;
    final message = await _listController.deleteMorte(morte);
    if (mounted) {
      _deletingMorteId = null;
      _listRevision.value++;
    }
    if (!mounted) return;
    AppSnackBar.show(
      context: context,
      message: message ?? 'Morte excluida com sucesso.',
      isError: message != null,
    );
  }

  @override
  Widget build(BuildContext context) {
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
  }

  Widget _tabs() {
    return Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(
        width: 320,
        child: TabBar(
          controller: _tabController,
          onTap: (value) => setState(() => _tabIndex = value),
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
    final Listenable animation =
        _tabIndex == 0 ? _listController : _chartsController;
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) => _toolbarContent(),
    );
  }

  Widget _toolbarContent() {
    final isList = _tabIndex == 0;
    final loading =
        isList ? _listController.isLoading : _chartsController.isLoading;
    final count = _listController.mortes.length;
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
                              ? '1 morte cadastrada'
                              : '$count mortes cadastradas'
                        : 'Indicadores mensais de mortalidade',
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
                      compact ? 'Adicionar' : 'Adicionar morte',
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
    final isList = _tabIndex == 0;
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
    if (_listController.isLoading && _listController.mortes.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_listController.errorMessage != null &&
        _listController.mortes.isEmpty) {
      return _WebStateMessage(
        message: _listController.errorMessage!,
        actionLabel: 'Tentar novamente',
        onAction: _loadList,
      );
    }
    if (_listController.mortes.isEmpty) {
      return WebEmptyState(
        icon: LucideIcons.skull,
        title: 'Nenhuma morte cadastrada.',
        description:
            'Use o botão Adicionar morte para registrar a primeira ocorrência.',
        actionLabel: 'Adicionar morte',
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
                    if (wide) const _MorteTableHeader(),
                    for (
                      var index = 0;
                      index < _listController.mortes.length;
                      index++
                    ) ...[
                      if (index > 0)
                        const Divider(height: 1, color: Color(0xFFE7E4DD)),
                      if (wide)
                        _MorteTableRow(
                          morte: _listController.mortes[index],
                          deleting:
                              _deletingMorteId ==
                              _listController.mortes[index].id,
                          onOpen: () =>
                              _openDetails(_listController.mortes[index]),
                          onEdit: () =>
                              _openForm(_listController.mortes[index]),
                          onDelete: () =>
                              _confirmDelete(_listController.mortes[index]),
                        )
                      else
                        _MorteStackedRow(
                          morte: _listController.mortes[index],
                          deleting:
                              _deletingMorteId ==
                              _listController.mortes[index].id,
                          onOpen: () =>
                              _openDetails(_listController.mortes[index]),
                          onEdit: () =>
                              _openForm(_listController.mortes[index]),
                          onDelete: () =>
                              _confirmDelete(_listController.mortes[index]),
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
    final data = charts ?? MorteChartsEntity.empty;
    final empty = data.totalMesAMes.isEmpty && data.porCausa.isEmpty;

    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontal = constraints.maxWidth < 720 ? 16.0 : 28.0;
        final chartColumns = constraints.maxWidth >= 1100 ? 2 : 1;
        final chartWidth =
            (constraints.maxWidth -
                (horizontal * 2) -
                ((chartColumns - 1) * 16)) /
            chartColumns;
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
              else
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    SizedBox(
                      width: chartWidth,
                      child: MonthlyBarChartCard(
                        title: 'Linha de mortalidade',
                        points: data.totalMesAMes
                            .map(
                              (point) => MonthlyBarChartPoint(
                                month: point.month,
                                value: point.quantity.toDouble(),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    SizedBox(
                      width: chartWidth,
                      child: _CauseChartCard(causes: data.porCausa),
                    ),
                  ],
                ),
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

class _MorteTableHeader extends StatelessWidget {
  const _MorteTableHeader();

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
          Expanded(flex: 3, child: _HeaderText('Causa')),
          SizedBox(width: 16),
          Expanded(flex: 3, child: _HeaderText('Potreiro')),
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

class _MorteTableRow extends StatelessWidget {
  const _MorteTableRow({
    required this.morte,
    required this.deleting,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
  });

  final MorteEntity morte;
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
              const _MorteIcon(),
              const SizedBox(width: 12),
              Expanded(flex: 3, child: _ValueText(_morteTitle(morte))),
              const SizedBox(width: 16),
              Expanded(
                flex: 3,
                child: _ValueText(_morteCause(morte) ?? 'Causa não informada'),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 3,
                child: _ValueText(morte.potreiro?.nome ?? 'Potreiro não informado'),
              ),
              const SizedBox(width: 16),
              SizedBox(width: 100, child: _ValueText(morte.data)),
              const SizedBox(width: 16),
              SizedBox(
                width: 188,
                child: _MorteActions(
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

class _MorteStackedRow extends StatelessWidget {
  const _MorteStackedRow({
    required this.morte,
    required this.deleting,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
  });

  final MorteEntity morte;
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
                  const _MorteIcon(),
                  const SizedBox(width: 12),
                  Expanded(child: _ValueText(_morteTitle(morte))),
                ],
              ),
              const SizedBox(height: 13),
              _CompactValue(
                label: 'Causa',
                value: _morteCause(morte) ?? 'Causa não informada',
              ),
              const SizedBox(height: 6),
              _CompactValue(
                label: 'Potreiro',
                value: morte.potreiro?.nome ?? 'Potreiro não informado',
              ),
              const SizedBox(height: 6),
              _CompactValue(label: 'Data', value: morte.data),
              const SizedBox(height: 14),
              _MorteActions(
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

class _MorteIcon extends StatelessWidget {
  const _MorteIcon();

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
        LucideIcons.skull,
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
          width: 72,
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

class _MorteActions extends StatelessWidget {
  const _MorteActions({
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

String _morteTitle(MorteEntity morte) {
  final categoria = morte.animais.isNotEmpty
      ? morte.animais.first.categoria?.nome.trim()
      : null;
  final label = categoria?.isNotEmpty == true ? ' - $categoria' : '';
  final count = morte.qtdAnimais == 1
      ? '1 animal'
      : '${morte.qtdAnimais} animais';
  return '$count$label';
}

String? _morteCause(MorteEntity morte) {
  final causes = morte.animais
      .map((animal) => animal.causa?.trim())
      .where((cause) => cause != null && cause.isNotEmpty)
      .cast<String>()
      .toSet()
      .toList(growable: false);
  if (causes.isEmpty) return null;
  if (causes.length == 1) return causes.first;
  return causes.join(' / ');
}

class _MorteDetailsWebDialog extends StatelessWidget {
  const _MorteDetailsWebDialog({required this.morte});

  final MorteEntity morte;

  Future<void> _openAnimals(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => WebPageDialog(
        title: morte.animais.length == 1
            ? '1 animal vinculado'
            : '${morte.animais.length} animais vinculados',
        width: 700,
        maxHeight: 760,
        child: _MorteAnimaisVinculadosWebBody(animais: morte.animais),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final causeLabel = _morteCause(morte);
    final hasAnimals = morte.animais.isNotEmpty;
    return WebDialogFrame(
      title: 'Detalhes da morte',
      width: 720,
      bodyPadding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DetailField(label: 'Data', value: morte.data),
          _DetailField(label: 'Potreiro', value: morte.potreiro?.nome),
          if (causeLabel != null)
            _DetailField(label: 'Causa da morte', value: causeLabel),
          _DetailField(
            label: 'Quantidade',
            value: morte.qtdAnimais == 1
                ? '1 animal'
                : '${morte.qtdAnimais} animais',
          ),
          _DetailField(label: 'Observações', value: morte.obs),
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
                            : morte.animais.length == 1
                            ? '1 animal vinculado'
                            : '${morte.animais.length} animais vinculados',
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

class _MorteAnimaisVinculadosWebBody extends StatelessWidget {
  const _MorteAnimaisVinculadosWebBody({required this.animais});

  final List<MorteAnimalEntity> animais;

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
        title: Text(
          animais.length == 1
              ? '1 animal vinculado'
              : '${animais.length} animais vinculados',
          style: const TextStyle(
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
                              : 'Animal vinculado',
                          style: const TextStyle(
                            color: Color(0xFF313131),
                            fontSize: 15,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _AnimalInfoRow(
                          label: 'Categoria',
                          value: animal.categoria?.nome ?? '-',
                        ),
                        _AnimalInfoRow(
                          label: 'Peso',
                          value: animal.pesoTotal == null
                              ? '-'
                              : '${animal.pesoTotal!.toStringAsFixed(2)} kg',
                        ),
                        _AnimalInfoRow(
                          label: 'Causa',
                          value: animal.causa?.trim().isNotEmpty == true
                              ? animal.causa!.trim()
                              : '-',
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

class _MorteDateFilterWebDialog extends StatefulWidget {
  const _MorteDateFilterWebDialog({this.initialDataIn, this.initialDataOut});

  final String? initialDataIn;
  final String? initialDataOut;

  @override
  State<_MorteDateFilterWebDialog> createState() =>
      _MorteDateFilterWebDialogState();
}

class _MorteDateFilterWebDialogState extends State<_MorteDateFilterWebDialog> {
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
  const _BaseCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
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

class _CauseChartCard extends StatelessWidget {
  const _CauseChartCard({required this.causes});

  final List<MorteCauseEntity> causes;

  @override
  Widget build(BuildContext context) {
    return _BaseCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Causas de morte',
            style: TextStyle(
              color: Color(0xFF313131),
              fontSize: 14,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 250,
            child: causes.isEmpty
                ? const WebEmptyState(
                    icon: LucideIcons.pieChart,
                    title: 'Sem dados para o período.',
                  )
                : CustomPaint(
                    painter: _DonutPainter(causes: causes),
                    child: const SizedBox.expand(),
                  ),
          ),
          if (causes.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 18,
              runSpacing: 14,
              children: [
                for (var i = 0; i < causes.length; i++)
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 280),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: _causeColors[i % _causeColors.length],
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            '${causes[i].cause} (${_formatPercent(causes[i].percent)})',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF6F6F6F),
                              fontSize: 13,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({required this.causes});

  final List<MorteCauseEntity> causes;

  @override
  void paint(Canvas canvas, Size size) {
    final total = causes
        .map((item) => item.percent > 0 ? item.percent : item.quantity)
        .fold<double>(0, (sum, value) => sum + value);
    if (total <= 0) return;

    final diameter = math.min(size.width, size.height) * 0.82;
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: diameter,
      height: diameter,
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24
      ..strokeCap = StrokeCap.round;

    var start = -math.pi / 2;
    for (var i = 0; i < causes.length; i++) {
      final value = causes[i].percent > 0
          ? causes[i].percent
          : causes[i].quantity;
      final sweep = (value / total) * math.pi * 2;
      paint.color = _causeColors[i % _causeColors.length];
      canvas.drawArc(rect, start, sweep, false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.causes != causes;
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

String _formatPercent(double value) {
  if (value == value.roundToDouble()) {
    return '${value.toStringAsFixed(0)}%';
  }
  return '${value.toStringAsFixed(1).replaceAll('.', ',')}%';
}

const _causeColors = [
  Color(0xFF071996),
  Color(0xFFD13CCD),
  Color(0xFF2FB15C),
  Color(0xFFFF9F3A),
  Color(0xFF008B42),
  Color(0xFF7E57C2),
];

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
