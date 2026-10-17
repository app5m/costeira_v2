import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/core/components/sub_user_flag.dart';
import 'package:costeira/core/components/web_dialog_frame.dart';
import 'package:costeira/core/components/web_empty_state.dart';
import 'package:costeira/core/components/web_page_dialog.dart';
import 'package:costeira/features/movimentacoes/compras/presentation/controllers/get_compra_charts_controller.dart';
import 'package:costeira/features/movimentacoes/compras/presentation/page_controllers/compras_list_page_controller.dart';
import 'package:costeira/features/movimentacoes/compras/presentation/page_controllers/compras_page_controller.dart';
import 'package:costeira/features/movimentacoes/compras/presentation/pages/compra_animais_lista_page.dart';
import 'package:costeira/features/movimentacoes/compras/presentation/pages/compra_form_page.dart';
import 'package:costeira/features/movimentacoes/domain/entities/compra_charts_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/compra_entity.dart';
import 'package:costeira/features/movimentacoes/presentation/widgets/monthly_bar_chart_card.dart';
import 'package:costeira/features/movimentacoes/presentation/widgets/movimentacao_date_filter_sheet.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ComprasWebPage extends StatefulWidget {
  const ComprasWebPage({super.key});

  @override
  State<ComprasWebPage> createState() => _ComprasWebPageState();
}

class _ComprasWebPageState extends State<ComprasWebPage>
    with SingleTickerProviderStateMixin {
  late final ComprasPageController _pageController;
  late final ComprasListPageController _listController;
  late final GetCompraChartsController _chartsController;
  final ValueNotifier<int> _listRevision = ValueNotifier(0);
  final ValueNotifier<int> _chartsRevision = ValueNotifier(0);
  bool _listInitialized = false;
  bool _chartsInitialized = false;

  @override
  void initState() {
    super.initState();
    _pageController = Modular.get<ComprasPageController>();
    _listController = Modular.get<ComprasListPageController>();
    _chartsController = Modular.get<GetCompraChartsController>();
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

  Future<void> _openForm([CompraEntity? compra]) async {
    var details = compra;
    if (compra != null) {
      details = await _listController.findCompraDetails(compra);
      if (!mounted) return;
    }
    final result = await showDialog<Map<String, dynamic>?>(
      context: context,
      barrierDismissible: false,
      builder: (_) => WebPageDialog(
        title: details == null ? 'Adicionar compra' : 'Editar compra',
        width: 760,
        maxHeight: 840,
        child: CompraFormPage(compra: details),
      ),
    );
    if (!mounted || result?['success'] != true) return;
    await _loadList();
    if (!mounted) return;
    AppSnackBar.show(
      context: context,
      message: result?['message']?.toString() ?? 'Compra salva com sucesso.',
      isError: false,
    );
  }

  Future<void> _openDetails(CompraEntity compra) async {
    final details = await _listController.findCompraDetails(compra);
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _CompraDetailsWebDialog(compra: details),
    );
  }

  Future<void> _openFilter() async {
    final result = await showDialog<MovimentacaoDateFilterResult>(
      context: context,
      builder: (_) => _CompraDateFilterWebDialog(
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

  Future<void> _confirmDelete(CompraEntity compra) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Excluir compra',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          'Tem certeza que deseja excluir essa compra permanentemente?',
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
    final message = await _listController.deleteCompra(compra);
    if (mounted) _listRevision.value++;
    if (!mounted) return;
    AppSnackBar.show(
      context: context,
      message: message ?? 'Compra excluida com sucesso.',
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

  Widget _toolbar() {
    return AnimatedBuilder(
      animation: _pageController.tabIndex == 0
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
    final count = _listController.compras.length;
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
                              ? '1 compra cadastrada'
                              : '$count compras cadastradas'
                        : 'Indicadores mensais de compras',
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
                    onPressed: isLoading ? null : () => _openForm(),
                    icon: const Icon(Icons.add_rounded, size: 19),
                    label: Text(compact ? 'Adicionar' : 'Adicionar compra'),
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

  Widget _stableTabBody() {
    final isList = _pageController.tabIndex == 0;
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
    if (_listController.isLoading && _listController.compras.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_listController.errorMessage != null &&
        _listController.compras.isEmpty) {
      return _WebStateMessage(
        message: _listController.errorMessage!,
        actionLabel: 'Tentar novamente',
        onAction: _loadList,
      );
    }
    if (_listController.compras.isEmpty) {
      return WebEmptyState(
        icon: LucideIcons.shoppingBag,
        title: 'Nenhuma compra cadastrada.',
        description:
            'Use o botão Adicionar compra para registrar a primeira entrada.',
        actionLabel: 'Adicionar compra',
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
                    if (wide) const _CompraTableHeader(),
                    for (
                      var index = 0;
                      index < _listController.compras.length;
                      index++
                    ) ...[
                      if (index > 0)
                        const Divider(height: 1, color: Color(0xFFE7E4DD)),
                      if (wide)
                        _CompraTableRow(
                          compra: _listController.compras[index],
                          onOpen: () =>
                              _openDetails(_listController.compras[index]),
                          onEdit: () =>
                              _openForm(_listController.compras[index]),
                          onDelete: () =>
                              _confirmDelete(_listController.compras[index]),
                        )
                      else
                        _CompraStackedRow(
                          compra: _listController.compras[index],
                          onOpen: () =>
                              _openDetails(_listController.compras[index]),
                          onEdit: () =>
                              _openForm(_listController.compras[index]),
                          onDelete: () =>
                              _confirmDelete(_listController.compras[index]),
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
    final data = charts ?? CompraChartsEntity.empty;
    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 980 ? 4 : 2;
              final horizontal = constraints.maxWidth < 720 ? 16.0 : 28.0;
              final cardWidth =
                  (constraints.maxWidth -
                      (horizontal * 2) -
                      ((columns - 1) * 16)) /
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
                            title: 'Total comprado',
                            value: data.totalComprado,
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: _MetricCard(
                            title: 'kg totais',
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
                      title: 'Compras',
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
          ),
        ),
      ],
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

class _CompraTableHeader extends StatelessWidget {
  const _CompraTableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8F7F3),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
      child: const Row(
        children: [
          SizedBox(width: 38),
          SizedBox(width: 12),
          Expanded(flex: 3, child: _CompraHeaderText('Compra')),
          SizedBox(width: 16),
          Expanded(flex: 2, child: _CompraHeaderText('Valor')),
          SizedBox(width: 16),
          Expanded(flex: 4, child: _CompraHeaderText('Origem')),
          SizedBox(width: 16),
          SizedBox(width: 100, child: _CompraHeaderText('Data')),
          SizedBox(width: 16),
          SizedBox(width: 188),
        ],
      ),
    );
  }
}

class _CompraHeaderText extends StatelessWidget {
  const _CompraHeaderText(this.text);

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

class _CompraTableRow extends StatelessWidget {
  const _CompraTableRow({
    required this.compra,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
  });

  final CompraEntity compra;
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
              const _CompraIcon(),
              const SizedBox(width: 12),
              Expanded(flex: 3, child: _CompraName(compra: compra)),
              const SizedBox(width: 16),
              Expanded(flex: 2, child: _CompraValueText(_compraValue(compra))),
              const SizedBox(width: 16),
              Expanded(
                flex: 4,
                child: _CompraValueText(_compraLocation(compra)),
              ),
              const SizedBox(width: 16),
              SizedBox(width: 100, child: _CompraValueText(compra.data)),
              const SizedBox(width: 16),
              SizedBox(
                width: 188,
                child: _CompraActions(onEdit: onEdit, onDelete: onDelete),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompraStackedRow extends StatelessWidget {
  const _CompraStackedRow({
    required this.compra,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
  });

  final CompraEntity compra;
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
                  const _CompraIcon(),
                  const SizedBox(width: 12),
                  Expanded(child: _CompraName(compra: compra)),
                ],
              ),
              const SizedBox(height: 13),
              _CompraCompactValue(label: 'Valor', value: _compraValue(compra)),
              const SizedBox(height: 6),
              _CompraCompactValue(
                label: 'Origem',
                value: _compraLocation(compra),
              ),
              const SizedBox(height: 6),
              _CompraCompactValue(label: 'Data', value: compra.data),
              const SizedBox(height: 14),
              _CompraActions(
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

class _CompraIcon extends StatelessWidget {
  const _CompraIcon();

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

class _CompraName extends StatelessWidget {
  const _CompraName({required this.compra});

  final CompraEntity compra;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _compraTitle(compra),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF313131),
            fontSize: 13,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w700,
          ),
        ),
        SubUserFlag(nome: compra.subUsuarioNome),
      ],
    );
  }
}

class _CompraValueText extends StatelessWidget {
  const _CompraValueText(this.value);

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

class _CompraCompactValue extends StatelessWidget {
  const _CompraCompactValue({required this.label, required this.value});

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
        Expanded(child: _CompraValueText(value)),
      ],
    );
  }
}

class _CompraActions extends StatelessWidget {
  const _CompraActions({
    required this.onEdit,
    required this.onDelete,
    this.expanded = false,
  });

  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
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

String _compraTitle(CompraEntity compra) {
  final category = compra.animais.isNotEmpty
      ? compra.animais.first.categoria?.nome.trim()
      : null;
  return '${compra.qtdAnimais} animais${category?.isNotEmpty == true ? ' - $category' : ''}';
}

String _compraValue(CompraEntity compra) {
  return compra.valorTotal?.trim().isNotEmpty == true
      ? compra.valorTotal!.trim()
      : 'Valor nao informado';
}

String _compraLocation(CompraEntity compra) {
  final parts =
      [
            _readableName(compra.fornecedor),
            _readableName(compra.municipio),
            compra.potreiro?.nome,
            compra.lote?.nome,
          ]
          .where((value) => value?.trim().isNotEmpty == true)
          .map((value) => value!.trim());
  return parts.isEmpty ? 'Origem nao informada' : parts.join(' - ');
}

String? _readableName(String? rawValue) {
  final value = rawValue?.trim();
  if (value == null || value.isEmpty) return null;
  if (!value.startsWith('{') && !value.startsWith('[')) return value;

  final nameMatch = RegExp(
    r'''["']?(?:nome|name)["']?\s*:\s*["']?([^,"'}]+)''',
    caseSensitive: false,
  ).firstMatch(value);
  final name = nameMatch?.group(1)?.trim();
  if (name == null || name.isEmpty) return null;
  return name.replaceAll(RegExp(r'''["']+$'''), '').trim();
}

class _CompraDetailsWebDialog extends StatelessWidget {
  const _CompraDetailsWebDialog({required this.compra});

  final CompraEntity compra;

  Future<void> _openAnimals(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => WebPageDialog(
        title: compra.animais.length == 1
            ? '1 animal vinculado'
            : '${compra.animais.length} animais vinculados',
        width: 700,
        maxHeight: 760,
        child: CompraAnimaisListaPage.saved(animais: compra.animais),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final count = compra.qtdAnimais;
    final hasAnimals = compra.animais.isNotEmpty;
    return WebDialogFrame(
      title: 'Detalhes da compra',
      width: 720,
      bodyPadding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DetailField(label: 'Potreiro', value: compra.potreiro?.nome),
          _DetailField(label: 'Lote', value: compra.lote?.nome),
          _DetailField(label: 'Data da compra', value: compra.data),
          _DetailField(
            label: 'Tipo de compra',
            value: compra.tipoCompra == 'kg' ? 'KG' : 'Por cabeça',
          ),
          _DetailField(
            label: 'Valor unitário',
            value: compra.valorUnitario,
          ),
          _DetailField(
            label: 'Fornecedor',
            value: _readableName(compra.fornecedor),
          ),
          _DetailField(
            label: 'Município',
            value: _readableName(compra.municipio),
          ),
          _DetailField(label: 'Observações', value: compra.obs),
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
                        count == 0
                            ? 'Nenhum animal vinculado'
                            : count == 1
                            ? '1 animal vinculado'
                            : '$count animais vinculados',
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

class _CompraDateFilterWebDialog extends StatefulWidget {
  const _CompraDateFilterWebDialog({this.initialDataIn, this.initialDataOut});

  final String? initialDataIn;
  final String? initialDataOut;

  @override
  State<_CompraDateFilterWebDialog> createState() =>
      _CompraDateFilterWebDialogState();
}

class _CompraDateFilterWebDialogState
    extends State<_CompraDateFilterWebDialog> {
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
                color: Color(0xFF666666),
              ),
            ),
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
