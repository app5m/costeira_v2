import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/core/components/sub_user_flag.dart';
import 'package:costeira/core/components/web_dialog_frame.dart';
import 'package:costeira/core/components/web_empty_state.dart';
import 'package:costeira/core/components/web_page_dialog.dart';
import 'package:costeira/features/movimentacoes/domain/entities/venda_charts_entity.dart';
import 'package:costeira/features/movimentacoes/presentation/widgets/monthly_bar_chart_card.dart';
import 'package:costeira/features/movimentacoes/presentation/widgets/movimentacao_date_filter_sheet.dart';
import 'package:costeira/features/movimentacoes/vendas/domain/entities/venda_animal_entity.dart';
import 'package:costeira/features/movimentacoes/vendas/domain/entities/venda_entity.dart';
import 'package:costeira/features/movimentacoes/vendas/presentation/controllers/get_venda_charts_controller.dart';
import 'package:costeira/features/movimentacoes/vendas/presentation/page_controllers/vendas_list_page_controller.dart';
import 'package:costeira/features/movimentacoes/vendas/presentation/pages/venda_form_page.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:lucide_icons/lucide_icons.dart';

class VendasWebPage extends StatefulWidget {
  const VendasWebPage({super.key});

  @override
  State<VendasWebPage> createState() => _VendasWebPageState();
}

class _VendasWebPageState extends State<VendasWebPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final VendasListPageController _listController;
  late final GetVendaChartsController _chartsController;
  final ValueNotifier<int> _listRevision = ValueNotifier(0);
  final ValueNotifier<int> _chartsRevision = ValueNotifier(0);
  int _tabIndex = 0;
  int? _deletingVendaId;
  bool _listInitialized = false;
  bool _chartsInitialized = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _listController = Modular.get<VendasListPageController>();
    _chartsController = Modular.get<GetVendaChartsController>();
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

  Future<void> _openForm([VendaEntity? venda]) async {
    var details = venda;
    if (venda != null) {
      details = await _listController.findVendaDetails(venda);
      if (!mounted) return;
    }
    final result = await showDialog<Map<String, dynamic>?>(
      context: context,
      barrierDismissible: false,
      builder: (_) => WebPageDialog(
        title: details == null ? 'Adicionar venda' : 'Editar venda',
        width: 760,
        maxHeight: 840,
        child: VendaFormPage(venda: details),
      ),
    );
    if (!mounted || result?['success'] != true) return;
    await _loadList();
    if (!mounted) return;
    AppSnackBar.show(
      context: context,
      message: result?['message']?.toString() ?? 'Venda salva com sucesso.',
      isError: false,
    );
  }

  Future<void> _openDetails(VendaEntity venda) async {
    final details = await _listController.findVendaDetails(venda);
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _VendaDetailsWebDialog(venda: details),
    );
  }

  Future<void> _openFilter() async {
    final result = await showDialog<MovimentacaoDateFilterResult>(
      context: context,
      builder: (_) => _VendaDateFilterWebDialog(
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

  Future<void> _confirmDelete(VendaEntity venda) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Excluir venda', style: _dialogTitleStyle),
        content: const Text(
          'Tem certeza que deseja excluir essa venda permanentemente?',
          style: _dialogBodyStyle,
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
    _deletingVendaId = venda.id;
    _listRevision.value++;
    final message = await _listController.deleteVenda(venda);
    if (mounted) {
      _deletingVendaId = null;
      _listRevision.value++;
    }
    if (!mounted) return;
    AppSnackBar.show(
      context: context,
      message: message ?? 'Venda excluida com sucesso.',
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
    final Listenable animation = _tabIndex == 0
        ? _listController
        : _chartsController;
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) => _toolbarContent(),
    );
  }

  Widget _toolbarContent() {
    final isList = _tabIndex == 0;
    final loading = isList
        ? _listController.isLoading
        : _chartsController.isLoading;
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
                        ? _listController.vendas.length == 1
                              ? '1 venda cadastrada'
                              : '${_listController.vendas.length} vendas cadastradas'
                        : 'Indicadores mensais de vendas',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _toolbarCaptionStyle,
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
                      compact ? 'Adicionar' : 'Adicionar venda',
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
                      textStyle: _buttonTextStyle,
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
    if (_listController.errorMessage != null &&
        _listController.vendas.isEmpty) {
      return _WebStateMessage(
        message: _listController.errorMessage!,
        actionLabel: 'Tentar novamente',
        onAction: _loadList,
      );
    }
    if (_listController.vendas.isEmpty) {
      return WebEmptyState(
        icon: LucideIcons.arrowLeftRight,
        title: 'Nenhuma venda cadastrada.',
        description:
            'Use o botão Adicionar venda para registrar a primeira saída.',
        actionLabel: 'Adicionar venda',
        onAction: _openForm,
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
                    if (wide) const _VendaTableHeader(),
                    for (
                      var index = 0;
                      index < _listController.vendas.length;
                      index++
                    ) ...[
                      if (index > 0)
                        const Divider(height: 1, color: Color(0xFFE7E4DD)),
                      if (wide)
                        _VendaTableRow(
                          venda: _listController.vendas[index],
                          deleting:
                              _deletingVendaId ==
                              _listController.vendas[index].id,
                          onOpen: () =>
                              _openDetails(_listController.vendas[index]),
                          onEdit: () =>
                              _openForm(_listController.vendas[index]),
                          onDelete: () =>
                              _confirmDelete(_listController.vendas[index]),
                        )
                      else
                        _VendaStackedRow(
                          venda: _listController.vendas[index],
                          deleting:
                              _deletingVendaId ==
                              _listController.vendas[index].id,
                          onOpen: () =>
                              _openDetails(_listController.vendas[index]),
                          onEdit: () =>
                              _openForm(_listController.vendas[index]),
                          onDelete: () =>
                              _confirmDelete(_listController.vendas[index]),
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
    if (_chartsController.errorMessage != null && charts == null) {
      return _WebStateMessage(
        message: _chartsController.errorMessage!,
        actionLabel: 'Tentar novamente',
        onAction: _loadCharts,
      );
    }
    final data = charts ?? VendaChartsEntity.empty;
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 980 ? 4 : 2;
        final horizontal = constraints.maxWidth < 720 ? 16.0 : 28.0;
        final cardWidth =
            (constraints.maxWidth - (horizontal * 2) - ((columns - 1) * 16)) /
            columns;
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
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: cardWidth,
                    child: _MetricCard(
                      title: 'Total vendido',
                      value: data.totalVendido,
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _MetricCard(
                      title: 'kg vendidos',
                      value: '${_formatNumber(data.kgTotais)} kg',
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _MetricCard(
                      title: 'Preço médio',
                      value: data.precoMedio,
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _MetricCard(
                      title: 'Total de cabeças',
                      value: '${data.totalCabecas} cabeças',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              MonthlyBarChartCard(
                title: 'Vendas',
                axisLabelBuilder: _formatAxisValue,
                points: data.valorTotalMesAMes
                    .map(
                      (point) => MonthlyBarChartPoint(
                        month: point.month,
                        value: point.valueRaw,
                      ),
                    )
                    .toList(),
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
    required this.isLoading,
    required this.onPressed,
  });

  final String tooltip;
  final bool isLoading;
  final VoidCallback? onPressed;

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
              : const Icon(LucideIcons.refreshCw, size: 17),
        ),
      ),
    );
  }
}

class _VendaTableHeader extends StatelessWidget {
  const _VendaTableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8F7F3),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
      child: const Row(
        children: [
          SizedBox(width: 38),
          SizedBox(width: 12),
          Expanded(flex: 3, child: _HeaderText('Venda')),
          SizedBox(width: 16),
          Expanded(flex: 2, child: _HeaderText('Valor')),
          SizedBox(width: 16),
          Expanded(flex: 4, child: _HeaderText('Destino')),
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

class _VendaTableRow extends StatelessWidget {
  const _VendaTableRow({
    required this.venda,
    required this.deleting,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
  });

  final VendaEntity venda;
  final bool deleting;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              const _VendaIcon(),
              const SizedBox(width: 12),
              Expanded(flex: 3, child: _VendaName(venda: venda)),
              const SizedBox(width: 16),
              Expanded(flex: 2, child: _ValueText(_vendaValue(venda))),
              const SizedBox(width: 16),
              Expanded(flex: 4, child: _ValueText(_vendaDestination(venda))),
              const SizedBox(width: 16),
              SizedBox(width: 100, child: _ValueText(venda.data)),
              const SizedBox(width: 16),
              SizedBox(
                width: 188,
                child: _VendaActions(
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

class _VendaStackedRow extends StatelessWidget {
  const _VendaStackedRow({
    required this.venda,
    required this.deleting,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
  });

  final VendaEntity venda;
  final bool deleting;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _VendaIcon(),
                  const SizedBox(width: 12),
                  Expanded(child: _VendaName(venda: venda)),
                ],
              ),
              const SizedBox(height: 13),
              _CompactValue(label: 'Valor', value: _vendaValue(venda)),
              const SizedBox(height: 6),
              _CompactValue(label: 'Destino', value: _vendaDestination(venda)),
              const SizedBox(height: 6),
              _CompactValue(label: 'Data', value: venda.data),
              const SizedBox(height: 14),
              _VendaActions(
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

class _VendaIcon extends StatelessWidget {
  const _VendaIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: const Color(0x1400823A),
        borderRadius: BorderRadius.circular(9),
      ),
      child: const Icon(
        LucideIcons.arrowLeftRight,
        size: 18,
        color: MyColors.colorPrimary,
      ),
    );
  }
}

class _VendaName extends StatelessWidget {
  const _VendaName({required this.venda});

  final VendaEntity venda;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _vendaTitle(venda),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: _rowPrimaryStyle,
        ),
        SubUserFlag(nome: venda.subUsuarioNome),
      ],
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
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: _rowValueStyle,
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
        SizedBox(width: 64, child: Text(label, style: _compactLabelStyle)),
        Expanded(child: _ValueText(value)),
      ],
    );
  }
}

class _VendaActions extends StatelessWidget {
  const _VendaActions({
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
    final edit = SizedBox(
      width: expanded ? null : 88,
      height: 38,
      child: OutlinedButton.icon(
        onPressed: deleting ? null : onEdit,
        icon: const Icon(LucideIcons.pencil, size: 15),
        label: const Text('Editar'),
        style: _editButtonStyle,
      ),
    );
    final remove = SizedBox(
      width: expanded ? null : 92,
      height: 38,
      child: OutlinedButton.icon(
        onPressed: deleting ? null : onDelete,
        icon: deleting
            ? const SizedBox.square(
                dimension: 15,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(LucideIcons.trash2, size: 15),
        label: const Text('Excluir'),
        style: _deleteButtonStyle,
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

class _VendaDetailsWebDialog extends StatelessWidget {
  const _VendaDetailsWebDialog({required this.venda});

  final VendaEntity venda;

  Future<void> _openAnimals(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => WebDialogFrame(
        title: venda.animais.length == 1
            ? '1 animal vinculado'
            : '${venda.animais.length} animais vinculados',
        width: 700,
        maxHeight: 760,
        scrollableBody: false,
        child: _LinkedAnimalsWebList(animals: venda.animais),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasAnimals = venda.animais.isNotEmpty;
    return WebDialogFrame(
      title: 'Detalhes da venda',
      width: 720,
      bodyPadding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DetailField(label: 'Data', value: venda.data),
          _DetailField(
            label: 'Quantidade',
            value: venda.qtdAnimais == 1
                ? '1 animal'
                : '${venda.qtdAnimais} animais',
          ),
          _DetailField(
            label: 'Peso medio',
            value: _weight(venda.pesoMedio),
          ),
          _DetailField(
            label: 'Peso total',
            value: _weight(venda.pesoTotal),
          ),
          _DetailField(label: 'Valor unitário', value: venda.valorUnitario),
          _DetailField(label: 'Valor total', value: venda.valorTotal),
          _DetailField(
            label: 'Comprador',
            value: _readableName(venda.comprador),
          ),
          _DetailField(
            label: 'Municipio',
            value: _readableName(venda.municipio),
          ),
          _DetailField(label: 'Destino', value: _destinationsLabel(venda)),
          _DetailField(label: 'Observações', value: venda.obs),
          const Text('Animais', style: _detailSectionStyle),
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
                        venda.animais.isEmpty
                            ? 'Nenhum animal vinculado'
                            : venda.animais.length == 1
                            ? '1 animal vinculado'
                            : '${venda.animais.length} animais vinculados',
                        style: _detailValueStyle,
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

class _LinkedAnimalsWebList extends StatelessWidget {
  const _LinkedAnimalsWebList({required this.animals});

  final List<VendaAnimalEntity> animals;

  @override
  Widget build(BuildContext context) {
    if (animals.isEmpty) {
      return const WebEmptyState(
        icon: LucideIcons.tag,
        title: 'Nenhum animal vinculado.',
        description: 'Esta venda não possui animais vinculados.',
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.all(24),
      itemCount: animals.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final animal = animals[index];
        return Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE7E4DD)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _nonEmpty(animal.brinco) ?? 'Brinco nao cadastrado',
                style: _rowPrimaryStyle,
              ),
              const SizedBox(height: 10),
              _AnimalInfo(label: 'Categoria', value: animal.categoria?.nome),
              _AnimalInfo(label: 'Peso', value: _weight(animal.pesoTotal)),
              _AnimalInfo(label: 'Lote', value: animal.lote?.nome),
              _AnimalInfo(label: 'Potreiro', value: animal.potreiro?.nome),
            ],
          ),
        );
      },
    );
  }
}

class _AnimalInfo extends StatelessWidget {
  const _AnimalInfo({required this.label, required this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(width: 90, child: Text(label, style: _compactLabelStyle)),
          Expanded(
            child: Text(
              _nonEmpty(value) ?? '-',
              textAlign: TextAlign.right,
              style: _rowValueStyle,
            ),
          ),
        ],
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
          Text(label, style: _detailLabelStyle),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F4F4),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE7E4DD)),
            ),
            child: Text(_nonEmpty(value) ?? '-', style: _detailValueStyle),
          ),
        ],
      ),
    );
  }
}

class _VendaDateFilterWebDialog extends StatefulWidget {
  const _VendaDateFilterWebDialog({this.initialDataIn, this.initialDataOut});

  final String? initialDataIn;
  final String? initialDataOut;

  @override
  State<_VendaDateFilterWebDialog> createState() =>
      _VendaDateFilterWebDialogState();
}

class _VendaDateFilterWebDialogState extends State<_VendaDateFilterWebDialog> {
  late final TextEditingController _startController;
  late final TextEditingController _endController;

  String? get _start => _nonEmpty(_startController.text);
  String? get _end => _nonEmpty(_endController.text);
  bool get _hasFilters => _start != null || _end != null;
  bool get _hadFilters =>
      _nonEmpty(widget.initialDataIn) != null ||
      _nonEmpty(widget.initialDataOut) != null;
  bool get _hasChanges =>
      _start != _nonEmpty(widget.initialDataIn) ||
      _end != _nonEmpty(widget.initialDataOut);

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
                onPressed: _hasFilters && (_hasChanges || _hadFilters)
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
                onPressed: _hasFilters && _hasChanges
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
            _DateField(
              label: 'Data inicial',
              controller: _startController,
              onTap: () => _pick(_startController),
            ),
            const SizedBox(height: 20),
            _DateField(
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

class _DateField extends StatelessWidget {
  const _DateField({
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
        Text(label, style: _detailLabelStyle),
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
            Text(message, textAlign: TextAlign.center, style: _stateTextStyle),
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
            Text(title, maxLines: 2, style: _metricTitleStyle),
            const Spacer(),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(value, style: _metricValueStyle),
            ),
          ],
        ),
      ),
    );
  }
}

String _vendaTitle(VendaEntity venda) {
  final category = venda.animais.isNotEmpty
      ? venda.animais.first.categoria?.nome.trim()
      : null;
  return '${venda.qtdAnimais} animais${category?.isNotEmpty == true ? ' - $category' : ''}';
}

String _vendaValue(VendaEntity venda) {
  return _nonEmpty(venda.valorTotal) ?? 'Valor nao informado';
}

String _vendaDestination(VendaEntity venda) {
  final destinations = venda.destinos
      .map(
        (item) =>
            _nonEmpty(item.destinoReference?.nome) ?? _nonEmpty(item.tipo),
      )
      .whereType<String>()
      .join(' / ');
  final parts = [
    _readableName(venda.comprador),
    _readableName(venda.municipio),
    _nonEmpty(destinations),
  ].whereType<String>();
  return parts.isEmpty ? 'Destino nao informado' : parts.join(' - ');
}

String _destinationsLabel(VendaEntity venda) {
  final labels = venda.destinos
      .map((item) {
        final name = _nonEmpty(item.destinoReference?.nome);
        if (name == null) return null;
        final type = _nonEmpty(item.tipo);
        return type == null ? name : '$name - $type';
      })
      .whereType<String>()
      .toList();
  return labels.isEmpty ? '-' : labels.join('\n');
}

String? _readableName(String? rawValue) {
  final value = _nonEmpty(rawValue);
  if (value == null) return null;
  if (!value.startsWith('{') && !value.startsWith('[')) return value;
  final match = RegExp(
    r'''["']?(?:nome|name)["']?\s*:\s*["']?([^,"'}]+)''',
    caseSensitive: false,
  ).firstMatch(value);
  final name = match?.group(1)?.trim();
  if (name == null || name.isEmpty) return null;
  return name.replaceAll(RegExp(r'''["']+$'''), '').trim();
}

String? _nonEmpty(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}

String? _weight(double? value) {
  return value == null ? null : '${value.toStringAsFixed(2)} kg';
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

String _formatAxisValue(double value) {
  if (value >= 1000000) return 'R\$ ${(value / 1000000).toStringAsFixed(0)}M';
  if (value >= 1000) return 'R\$ ${(value / 1000).toStringAsFixed(0)}k';
  return 'R\$ ${value.toStringAsFixed(0)}';
}

String _formatNumber(double value) {
  if (value == value.roundToDouble()) return value.toStringAsFixed(0);
  return value.toStringAsFixed(2).replaceAll('.', ',');
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

final ButtonStyle _editButtonStyle = OutlinedButton.styleFrom(
  padding: const EdgeInsets.symmetric(horizontal: 10),
  foregroundColor: MyColors.colorPrimary,
  side: const BorderSide(color: Color(0xFFBFD4C7)),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  textStyle: const TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 11,
    fontWeight: FontWeight.w700,
  ),
);

final ButtonStyle _deleteButtonStyle = OutlinedButton.styleFrom(
  padding: const EdgeInsets.symmetric(horizontal: 9),
  foregroundColor: const Color(0xFFC4473A),
  side: const BorderSide(color: Color(0xFFE1B8B2)),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  textStyle: const TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 11,
    fontWeight: FontWeight.w700,
  ),
);

const TextStyle _toolbarCaptionStyle = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 13,
  fontWeight: FontWeight.w600,
  color: Color(0xFF777777),
);

const TextStyle _buttonTextStyle = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 12,
  fontWeight: FontWeight.w700,
);

const TextStyle _rowPrimaryStyle = TextStyle(
  color: Color(0xFF313131),
  fontSize: 13,
  fontFamily: 'Montserrat',
  fontWeight: FontWeight.w700,
);

const TextStyle _rowValueStyle = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 12,
  fontWeight: FontWeight.w600,
  color: Color(0xFF4F5652),
);

const TextStyle _compactLabelStyle = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 11,
  fontWeight: FontWeight.w600,
  color: Color(0xFF8A8A8A),
);

const TextStyle _detailLabelStyle = TextStyle(
  color: Color(0xFF313131),
  fontSize: 13,
  fontFamily: 'Montserrat',
  fontWeight: FontWeight.w500,
);

const TextStyle _detailValueStyle = TextStyle(
  color: Color(0xFF313131),
  fontSize: 14,
  fontFamily: 'Montserrat',
  fontWeight: FontWeight.w500,
);

const TextStyle _detailSectionStyle = TextStyle(
  color: Color(0xFF313131),
  fontSize: 14,
  fontFamily: 'Montserrat',
  fontWeight: FontWeight.w600,
);

const TextStyle _stateTextStyle = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 14,
  color: Color(0xFF666666),
);

const TextStyle _metricTitleStyle = TextStyle(
  color: Color(0xFF8C8C8C),
  fontFamily: 'Montserrat',
  fontSize: 13,
  fontWeight: FontWeight.w500,
);

const TextStyle _metricValueStyle = TextStyle(
  color: Color(0xFF313131),
  fontFamily: 'Montserrat',
  fontSize: 20,
  fontWeight: FontWeight.w600,
);

const TextStyle _dialogTitleStyle = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 18,
  fontWeight: FontWeight.w700,
);

const TextStyle _dialogBodyStyle = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 14,
  height: 1.45,
  color: Color(0xFF666666),
);
