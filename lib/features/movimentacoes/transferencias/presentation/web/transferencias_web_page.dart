import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/core/components/web_dialog_frame.dart';
import 'package:costeira/core/components/web_empty_state.dart';
import 'package:costeira/core/components/web_page_dialog.dart';
import 'package:costeira/features/movimentacoes/domain/entities/transferencia_charts_entity.dart';
import 'package:costeira/features/movimentacoes/presentation/widgets/monthly_bar_chart_card.dart';
import 'package:costeira/features/movimentacoes/presentation/widgets/movimentacao_date_filter_sheet.dart';
import 'package:costeira/features/movimentacoes/transferencias/domain/entities/transferencia_fazenda_list_item.dart';
import 'package:costeira/features/movimentacoes/transferencias/presentation/controllers/get_transferencia_charts_controller.dart';
import 'package:costeira/features/movimentacoes/transferencias/presentation/page_controllers/transferencias_fazenda_list_page_controller.dart';
import 'package:costeira/features/movimentacoes/transferencias/presentation/page_controllers/transferencias_page_controller.dart';
import 'package:costeira/features/movimentacoes/transferencias/presentation/pages/transferencia_fazenda_form_page.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:lucide_icons/lucide_icons.dart';

class TransferenciasWebPage extends StatefulWidget {
  const TransferenciasWebPage({super.key});

  @override
  State<TransferenciasWebPage> createState() => _TransferenciasWebPageState();
}

class _TransferenciasWebPageState extends State<TransferenciasWebPage>
    with SingleTickerProviderStateMixin {
  late final TransferenciasPageController _pageController;
  late final TransferenciasFazendaListPageController _listController;
  late final GetTransferenciaChartsController _chartsController;
  final ValueNotifier<int> _listRevision = ValueNotifier(0);
  final ValueNotifier<int> _chartsRevision = ValueNotifier(0);
  bool _listInitialized = false;
  bool _chartsInitialized = false;

  @override
  void initState() {
    super.initState();
    _pageController = Modular.get<TransferenciasPageController>();
    _listController = Modular.get<TransferenciasFazendaListPageController>();
    _chartsController = Modular.get<GetTransferenciaChartsController>();
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
    final message = await _listController.applyDateFilters(
      dataIn: _listController.dataIn,
      dataOut: _listController.dataOut,
    );
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

  Future<void> _openForm([TransferenciaFazendaListItem? item]) async {
    final result = await showDialog<Map<String, dynamic>?>(
      context: context,
      barrierDismissible: false,
      builder: (_) => WebPageDialog(
        title: item == null ? 'Transferência enviada' : 'Editar transferência',
        width: 760,
        maxHeight: 840,
        child: TransferenciaFazendaFormPage(item: item),
      ),
    );
    if (!mounted || result?['success'] != true) return;
    await _loadList();
    if (!mounted) return;
    AppSnackBar.show(
      context: context,
      message:
          result?['message']?.toString() ??
          'Transferência salva com sucesso.',
      isError: false,
    );
  }

  Future<void> _openDetails(
    TransferenciaFazendaListItem item, {
    required bool canEdit,
  }) async {
    final changed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _TransferenciaDetailsWebDialog(
        item: item,
        canEdit: canEdit,
        onEdit: canEdit
            ? () async {
                Navigator.pop(context);
                await _openForm(item);
              }
            : null,
        onDecidir: item.pendente && !canEdit
            ? (status) async {
                final error = await _listController.decidir(
                  id: item.id,
                  statusTransferencia: status,
                );
                if (!mounted) return;
                if (error != null) {
                  AppSnackBar.show(
                    context: context,
                    message: error,
                    isError: true,
                  );
                  return;
                }
                Navigator.pop(context, true);
              }
            : null,
      ),
    );
    if (changed == true) {
      await _loadList();
    }
  }

  Future<void> _openFilter() async {
    final result = await showDialog<MovimentacaoDateFilterResult>(
      context: context,
      builder: (_) => _TransferenciaDateFilterWebDialog(
        initialDataIn: _listController.dataIn,
        initialDataOut: _listController.dataOut,
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

  Future<void> _decidir(int id, int status) async {
    final error = await _listController.decidir(
      id: id,
      statusTransferencia: status,
    );
    if (mounted) _listRevision.value++;
    if (!mounted || error == null) return;
    AppSnackBar.show(context: context, message: error, isError: true);
  }

  List<TransferenciaFazendaListItem> get _currentItems {
    return _pageController.tabIndex == 0
        ? _listController.recebidas
        : _listController.enviadas;
  }

  bool get _isRecebidas => _pageController.tabIndex == 0;
  bool get _isListTab => _pageController.tabIndex < 2;

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
      animation: _isListTab ? _listController : _chartsController,
      builder: (context, _) => _toolbarContent(),
    );
  }

  Widget _toolbarContent() {
    final isList = _isListTab;
    final isLoading = isList
        ? _listController.isLoading
        : _chartsController.isLoading;
    final count = _currentItems.length;
    final countLabel = _isRecebidas
        ? (count == 1
              ? '1 transferência recebida'
              : '$count transferências recebidas')
        : (count == 1
              ? '1 transferência enviada'
              : '$count transferências enviadas');
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
                        ? countLabel
                        : 'Indicadores mensais de transferências',
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
                  active: _listController.hasActiveFilters,
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
                  height: 46,
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : () => _openForm(),
                    icon: const Icon(Icons.add_rounded, size: 19),
                    label: Text(
                      compact ? 'Adicionar' : 'Adicionar',
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

  Widget _tabs() {
    return Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(
        width: 420,
        child: TabBar(
          controller: _pageController.tabController,
          onTap: _pageController.setTabIndex,
          tabs: const [
            Tab(text: 'Recebidas'),
            Tab(text: 'Enviadas'),
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
    final isList = _isListTab;
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
    final items = _currentItems;
    final recebidas = _isRecebidas;

    if (!_listInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_listController.isLoading && items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_listController.errorMessage != null && items.isEmpty) {
      return _WebStateMessage(
        message: _listController.errorMessage!,
        actionLabel: 'Tentar novamente',
        onAction: _loadList,
      );
    }
    if (items.isEmpty) {
      return WebEmptyState(
        icon: LucideIcons.arrowLeftRight,
        title: recebidas
            ? 'Nenhuma transferência recebida.'
            : 'Nenhuma transferência enviada.',
        description: recebidas
            ? 'Quando outra fazenda enviar animais para cá, elas aparecerão aqui.'
            : 'Use o botão Adicionar para registrar a primeira transferência.',
        actionLabel: recebidas ? null : 'Adicionar',
        onAction: recebidas ? null : () => _openForm(),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 960;
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
                    if (wide) const _TransferenciaTableHeader(),
                    for (var index = 0; index < items.length; index++) ...[
                      if (index > 0)
                        const Divider(height: 1, color: Color(0xFFE7E4DD)),
                      if (wide)
                        _TransferenciaTableRow(
                          item: items[index],
                          recebidas: recebidas,
                          onOpen: () => _openDetails(
                            items[index],
                            canEdit: !recebidas,
                          ),
                          onEdit: !recebidas
                              ? () => _openForm(items[index])
                              : null,
                          onDecidir: recebidas && items[index].pendente
                              ? _decidir
                              : null,
                        )
                      else
                        _TransferenciaStackedRow(
                          item: items[index],
                          recebidas: recebidas,
                          onOpen: () => _openDetails(
                            items[index],
                            canEdit: !recebidas,
                          ),
                          onEdit: !recebidas
                              ? () => _openForm(items[index])
                              : null,
                          onDecidir: recebidas && items[index].pendente
                              ? _decidir
                              : null,
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
    final data = charts ?? TransferenciaChartsEntity.empty;
    final empty =
        data.quantidadeTransferencias == 0 && data.mesAMes.isEmpty;

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
                        title: 'Transferências',
                        value: data.quantidadeTransferencias.toString(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                MonthlyBarChartCard(
                  title: 'Transferências por mês',
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

class _TransferenciaTableHeader extends StatelessWidget {
  const _TransferenciaTableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8F7F3),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
      child: const Row(
        children: [
          SizedBox(width: 38),
          SizedBox(width: 12),
          Expanded(flex: 4, child: _HeaderText('Rota')),
          SizedBox(width: 16),
          Expanded(flex: 2, child: _HeaderText('Status')),
          SizedBox(width: 16),
          Expanded(flex: 2, child: _HeaderText('Cabeças')),
          SizedBox(width: 16),
          Expanded(flex: 2, child: _HeaderText('Total')),
          SizedBox(width: 16),
          SizedBox(width: 100, child: _HeaderText('Data')),
          SizedBox(width: 16),
          SizedBox(width: 200),
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

class _TransferenciaTableRow extends StatelessWidget {
  const _TransferenciaTableRow({
    required this.item,
    required this.recebidas,
    required this.onOpen,
    this.onEdit,
    this.onDecidir,
  });

  final TransferenciaFazendaListItem item;
  final bool recebidas;
  final VoidCallback onOpen;
  final VoidCallback? onEdit;
  final Future<void> Function(int id, int status)? onDecidir;

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
              const _TransferenciaIcon(),
              const SizedBox(width: 12),
              Expanded(flex: 4, child: _RouteText(item: item)),
              const SizedBox(width: 16),
              Expanded(flex: 2, child: _StatusBadge(item: item)),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: _ValueText(
                  '${item.qtdAnimais} ${item.qtdAnimais == 1 ? 'cabeça' : 'cabeças'}',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(flex: 2, child: _ValueText(item.valorTotal)),
              const SizedBox(width: 16),
              SizedBox(width: 100, child: _ValueText(item.data)),
              const SizedBox(width: 16),
              SizedBox(
                width: 200,
                child: _RowActions(
                  recebidas: recebidas,
                  item: item,
                  onEdit: onEdit,
                  onDecidir: onDecidir,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TransferenciaStackedRow extends StatelessWidget {
  const _TransferenciaStackedRow({
    required this.item,
    required this.recebidas,
    required this.onOpen,
    this.onEdit,
    this.onDecidir,
  });

  final TransferenciaFazendaListItem item;
  final bool recebidas;
  final VoidCallback onOpen;
  final VoidCallback? onEdit;
  final Future<void> Function(int id, int status)? onDecidir;

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
                  const _TransferenciaIcon(),
                  const SizedBox(width: 12),
                  Expanded(child: _RouteText(item: item)),
                  const SizedBox(width: 8),
                  _StatusBadge(item: item),
                ],
              ),
              const SizedBox(height: 13),
              _CompactValue(
                label: 'Cabeças',
                value:
                    '${item.qtdAnimais} ${item.qtdAnimais == 1 ? 'cabeça' : 'cabeças'}',
              ),
              const SizedBox(height: 6),
              _CompactValue(label: 'Total', value: item.valorTotal),
              const SizedBox(height: 6),
              _CompactValue(label: 'Data', value: item.data),
              if (item.gtaDocumento != null) ...[
                const SizedBox(height: 6),
                _CompactValue(label: 'GTA', value: item.gtaDocumento!),
              ],
              const SizedBox(height: 14),
              _RowActions(
                recebidas: recebidas,
                item: item,
                onEdit: onEdit,
                onDecidir: onDecidir,
                expanded: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TransferenciaIcon extends StatelessWidget {
  const _TransferenciaIcon();

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

class _RouteText extends StatelessWidget {
  const _RouteText({required this.item});

  final TransferenciaFazendaListItem item;

  @override
  Widget build(BuildContext context) {
    final origem = item.fazendaOrigem?.nome ?? 'Origem';
    final destino = item.fazendaDestino?.nome ?? 'Destino';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$origem → $destino',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF313131),
            fontSize: 13,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w700,
          ),
        ),
        if (item.gtaDocumento != null)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              'GTA ${item.gtaDocumento}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Color(0xFF8A8A8A),
              ),
            ),
          ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.item});

  final TransferenciaFazendaListItem item;

  @override
  Widget build(BuildContext context) {
    final colors = switch (item.statusTransferencia) {
      1 => (bg: const Color(0xFFE7F6EC), fg: MyColors.colorPrimary),
      3 => (bg: const Color(0xFFFDECEC), fg: const Color(0xFFC62828)),
      _ => (bg: const Color(0xFFFFF4E5), fg: const Color(0xFFB86E00)),
    };
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: colors.bg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          item.statusString,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: colors.fg,
          ),
        ),
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

class _RowActions extends StatelessWidget {
  const _RowActions({
    required this.recebidas,
    required this.item,
    this.onEdit,
    this.onDecidir,
    this.expanded = false,
  });

  final bool recebidas;
  final TransferenciaFazendaListItem item;
  final VoidCallback? onEdit;
  final Future<void> Function(int id, int status)? onDecidir;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    if (recebidas && item.pendente && onDecidir != null) {
      final refuse = SizedBox(
        width: expanded ? null : 92,
        height: 38,
        child: OutlinedButton(
          onPressed: () => onDecidir!(
            item.id,
            TransferenciasFazendaListPageController.recusado,
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            foregroundColor: const Color(0xFFC62828),
            side: const BorderSide(color: Color(0xFFC62828)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          child: const Text('Recusar'),
        ),
      );
      final accept = SizedBox(
        width: expanded ? null : 92,
        height: 38,
        child: FilledButton(
          onPressed: () => onDecidir!(
            item.id,
            TransferenciasFazendaListPageController.aprovado,
          ),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            backgroundColor: MyColors.colorPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          child: const Text('Aceitar'),
        ),
      );
      return Row(
        mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
        children: [
          if (expanded) Expanded(child: refuse) else refuse,
          const SizedBox(width: 8),
          if (expanded) Expanded(child: accept) else accept,
        ],
      );
    }

    if (onEdit != null) {
      return Align(
        alignment: expanded ? Alignment.centerLeft : Alignment.centerRight,
        child: SizedBox(
          width: expanded ? double.infinity : 88,
          height: 38,
          child: OutlinedButton.icon(
            onPressed: onEdit,
            icon: const Icon(LucideIcons.pencil, size: 15),
            label: const Text('Editar'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              foregroundColor: MyColors.colorPrimary,
              side: const BorderSide(color: Color(0xFFBFD4C7)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

class _TransferenciaDetailsWebDialog extends StatefulWidget {
  const _TransferenciaDetailsWebDialog({
    required this.item,
    required this.canEdit,
    this.onEdit,
    this.onDecidir,
  });

  final TransferenciaFazendaListItem item;
  final bool canEdit;
  final VoidCallback? onEdit;
  final Future<void> Function(int status)? onDecidir;

  @override
  State<_TransferenciaDetailsWebDialog> createState() =>
      _TransferenciaDetailsWebDialogState();
}

class _TransferenciaDetailsWebDialogState
    extends State<_TransferenciaDetailsWebDialog> {
  static const _pageSize = 10;
  int _visible = _pageSize;
  bool _deciding = false;

  Future<void> _decidir(int status) async {
    if (widget.onDecidir == null || _deciding) return;
    setState(() => _deciding = true);
    try {
      await widget.onDecidir!(status);
    } finally {
      if (mounted) setState(() => _deciding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final origem = item.fazendaOrigem?.nome ?? 'Origem';
    final destino = item.fazendaDestino?.nome ?? 'Destino';
    final shown = item.animais.take(_visible).toList(growable: false);
    final remaining = item.animais.length - shown.length;
    final statusColors = switch (item.statusTransferencia) {
      1 => (bg: const Color(0xFFE7F6EC), fg: MyColors.colorPrimary),
      3 => (bg: const Color(0xFFFDECEC), fg: const Color(0xFFC62828)),
      _ => (bg: const Color(0xFFFFF4E5), fg: const Color(0xFFB86E00)),
    };

    return WebDialogFrame(
      title: 'Detalhes da transferência',
      width: 720,
      maxHeight: 820,
      bodyPadding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
      footer: Padding(
        padding: const EdgeInsets.fromLTRB(28, 16, 28, 24),
        child: Row(
          children: [
            if (widget.canEdit && widget.onEdit != null)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: widget.onEdit,
                  icon: const Icon(LucideIcons.pencil, size: 16),
                  label: const Text('Editar'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    foregroundColor: MyColors.colorPrimary,
                  ),
                ),
              )
            else if (item.pendente && widget.onDecidir != null) ...[
              Expanded(
                child: OutlinedButton(
                  onPressed: _deciding
                      ? null
                      : () => _decidir(
                          TransferenciasFazendaListPageController.recusado,
                        ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    foregroundColor: const Color(0xFFC62828),
                    side: const BorderSide(color: Color(0xFFC62828)),
                  ),
                  child: const Text('Recusar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _deciding
                      ? null
                      : () => _decidir(
                          TransferenciasFazendaListPageController.aprovado,
                        ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    elevation: 0,
                    backgroundColor: MyColors.colorPrimary,
                    foregroundColor: Colors.white,
                  ),
                  child: _deciding
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Aceitar'),
                ),
              ),
            ] else
              const Spacer(),
            if (widget.canEdit || (item.pendente && widget.onDecidir != null))
              const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  elevation: 0,
                  backgroundColor: const Color(0xFF313131),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Fechar'),
              ),
            ),
          ],
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  item.data,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Color(0xFF313131),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColors.bg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    item.statusString,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: statusColors.fg,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _DetailField(label: 'Origem', value: origem),
            _DetailField(label: 'Destino', value: destino),
            _DetailField(label: 'GTA / documento', value: item.gtaDocumento),
            _DetailField(label: 'Valor por animal', value: item.valorUnitario),
            _DetailField(label: 'Valor total', value: item.valorTotal),
            Text(
              'Animais (${item.qtdAnimais})',
              style: const TextStyle(
                color: Color(0xFF313131),
                fontSize: 14,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            if (item.animais.isEmpty)
              const WebEmptyState(
                icon: LucideIcons.tag,
                title: 'Nenhum animal nesta transferência.',
              )
            else ...[
              for (final animal in shown) ...[
                _AnimalDetailCard(animal: animal),
                const SizedBox(height: 8),
              ],
              if (remaining > 0)
                OutlinedButton(
                  onPressed: () => setState(() => _visible += _pageSize),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: MyColors.colorPrimary,
                    side: const BorderSide(color: MyColors.colorPrimary),
                    minimumSize: const Size.fromHeight(44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text('Ver mais ($remaining)'),
                ),
            ],
          ],
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

class _AnimalDetailCard extends StatelessWidget {
  const _AnimalDetailCard({required this.animal});

  final TransferenciaFazendaAnimal animal;

  @override
  Widget build(BuildContext context) {
    final brinco = animal.brinco ?? 's/ brinco';
    final categoria = [
      animal.categoria,
      animal.fase,
    ].whereType<String>().where((item) => item.trim().isNotEmpty).join(' · ');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7F3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE7E4DD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE7F6EC),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  brinco,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: MyColors.colorPrimary,
                  ),
                ),
              ),
              if (categoria.isNotEmpty) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    categoria,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF313131),
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (animal.piquete != null ||
              animal.lote != null ||
              animal.peso != null) ...[
            const SizedBox(height: 8),
            if (animal.piquete != null)
              Text(
                'Piquete  ${animal.piquete}',
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 12,
                  color: Color(0xFF5C5C5C),
                ),
              ),
            if (animal.lote != null)
              Text(
                'Lote  ${animal.lote}',
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 12,
                  color: Color(0xFF5C5C5C),
                ),
              ),
            if (animal.peso != null)
              Text(
                'Peso  ${_peso(animal.peso!)} kg',
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 12,
                  color: Color(0xFF5C5C5C),
                ),
              ),
          ],
        ],
      ),
    );
  }

  static String _peso(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toStringAsFixed(1).replaceAll('.', ',');
  }
}

class _TransferenciaDateFilterWebDialog extends StatefulWidget {
  const _TransferenciaDateFilterWebDialog({
    this.initialDataIn,
    this.initialDataOut,
  });

  final String? initialDataIn;
  final String? initialDataOut;

  @override
  State<_TransferenciaDateFilterWebDialog> createState() =>
      _TransferenciaDateFilterWebDialogState();
}

class _TransferenciaDateFilterWebDialogState
    extends State<_TransferenciaDateFilterWebDialog> {
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
