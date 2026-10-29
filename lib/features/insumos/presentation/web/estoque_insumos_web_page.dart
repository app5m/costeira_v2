import 'dart:math' as math;

import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/core/components/custom_button.dart';
import 'package:costeira/core/components/sub_user_flag.dart';
import 'package:costeira/core/components/web_dialog_frame.dart';
import 'package:costeira/core/components/web_empty_state.dart';
import 'package:costeira/core/components/web_page_dialog.dart';
import 'package:costeira/features/insumos/domain/entities/insumos.dart';
import 'package:costeira/features/insumos/presentation/controllers/delete_insumo_controller.dart';
import 'package:costeira/features/insumos/presentation/controllers/get_insumo_charts_controller.dart';
import 'package:costeira/features/insumos/presentation/controllers/list_insumos_controller.dart';
import 'package:costeira/features/insumos/presentation/pages/add_compra.dart';
import 'package:costeira/features/insumos/presentation/pages/add_insumo.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:lucide_icons/lucide_icons.dart';

class EstoqueInsumosWebPage extends StatefulWidget {
  const EstoqueInsumosWebPage({super.key});

  @override
  State<EstoqueInsumosWebPage> createState() => _EstoqueInsumosWebPageState();
}

class _EstoqueInsumosWebPageState extends State<EstoqueInsumosWebPage>
    with SingleTickerProviderStateMixin {
  static const _chartColors = [
    Color(0xFF008C42),
    Color(0xFFFF9442),
    Color(0xFF43D09A),
    Color(0xFFFFC443),
    Color(0xFF147AD6),
    Color(0xFF8E59FF),
  ];

  late final TabController _tabController;
  late final ListInsumosController _listController;
  late final DeleteInsumoController _deleteController;
  late final GetInsumoChartsController _chartsController;

  final ValueNotifier<int> _listRevision = ValueNotifier(0);
  final ValueNotifier<int> _chartsRevision = ValueNotifier(0);

  int _tabIndex = 0;
  int? _busyInsumoId;
  int? _busyRegistroId;
  bool _listInitialized = false;
  bool _chartsInitialized = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _listController = Modular.get<ListInsumosController>();
    _deleteController = Modular.get<DeleteInsumoController>();
    _chartsController = Modular.get<GetInsumoChartsController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadList();
      _loadCharts();
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _listRevision.dispose();
    _chartsRevision.dispose();
    _listController.dispose();
    _deleteController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    if (_tabIndex == _tabController.index) return;
    setState(() => _tabIndex = _tabController.index);
  }

  Future<void> _loadList({String? tipoInsumo}) async {
    try {
      await _listController.load(tipoInsumo: tipoInsumo);
    } catch (_) {
      if (mounted) {
        AppSnackBar.show(
          context: context,
          message:
              _listController.errorMessage ??
              'Nao foi possivel carregar os insumos.',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        _listInitialized = true;
        _listRevision.value++;
      }
    }
  }

  Future<void> _reloadList() async {
    try {
      await _listController.reload();
    } catch (_) {
      if (mounted) {
        AppSnackBar.show(
          context: context,
          message:
              _listController.errorMessage ??
              'Nao foi possivel carregar os insumos.',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        _listInitialized = true;
        _listRevision.value++;
      }
    }
  }

  Future<void> _loadCharts() async {
    try {
      await _chartsController.load();
    } catch (_) {
      if (mounted) {
        AppSnackBar.show(
          context: context,
          message:
              _chartsController.errorMessage ??
              'Nao foi possivel carregar os graficos.',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        _chartsInitialized = true;
        _chartsRevision.value++;
      }
    }
  }

  Future<void> _previousChartsMonth() async {
    try {
      await _chartsController.previousMonth();
    } catch (_) {
    } finally {
      if (mounted) _chartsRevision.value++;
    }
  }

  Future<void> _nextChartsMonth() async {
    try {
      await _chartsController.nextMonth();
    } catch (_) {
    } finally {
      if (mounted) _chartsRevision.value++;
    }
  }

  Future<void> _openTipoFilter() async {
    if (_listController.isLoading) return;
    final result = await showDialog<_TipoFilterResult>(
      context: context,
      builder: (_) => _TipoFilterWebDialog(
        tipos: _listController.tipoInsumos,
        selectedTipoId: _listController.currentFilter?.tipoInsumo,
      ),
    );
    if (!mounted || result == null) return;
    await _loadList(tipoInsumo: result.tipoInsumo);
  }

  Future<void> _openMovimento({
    required int tipo,
    bool produtoNovo = false,
  }) async {
    final title = tipo == 2
        ? 'Saída de estoque'
        : produtoNovo
        ? 'Entrada (produto novo)'
        : 'Entrada (produto existente)';
    final result = await showDialog<Map<String, dynamic>?>(
      context: context,
      barrierDismissible: false,
      builder: (_) => WebPageDialog(
        title: title,
        width: 720,
        maxHeight: 840,
        child: AddCompraInsumo(tipo: tipo, produtoNovo: produtoNovo),
      ),
    );
    if (!mounted || result?['success'] != true) return;
    await _reloadList();
    if (!mounted) return;
    AppSnackBar.show(
      context: context,
      message: result?['message']?.toString() ?? 'Movimento salvo com sucesso.',
      isError: false,
    );
  }

  Future<void> _openEdit(InsumoEntity insumo) async {
    final result = await showDialog<Map<String, dynamic>?>(
      context: context,
      barrierDismissible: false,
      builder: (_) => WebPageDialog(
        title: 'Editar insumo',
        width: 720,
        maxHeight: 840,
        child: AddInsumo(insumo: insumo),
      ),
    );
    if (!mounted || result?['success'] != true) return;
    await _reloadList();
    if (!mounted) return;
    AppSnackBar.show(
      context: context,
      message: result?['message']?.toString() ?? 'Insumo atualizado com sucesso.',
      isError: false,
    );
  }

  Future<void> _openDetails(InsumoEntity insumo) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _InsumoDetailsWebDialog(
        insumo: insumo,
        tipoLabel: _listController.tipoLabel(insumo.tipoInsumo),
      ),
    );
  }

  Future<void> _confirmDeleteInsumo(InsumoEntity insumo) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Excluir estoque de insumos',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Tem certeza que deseja excluir ${insumo.nome} permanentemente?',
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
    setState(() => _busyInsumoId = insumo.id);
    try {
      final result = await _deleteController.deleteInsumo(insumo.id);
      if (!mounted) return;
      if (result != null) {
        _listController.removeInsumoById(insumo.id);
        _listRevision.value++;
        AppSnackBar.show(
          context: context,
          message: result.message,
          isError: !result.isSuccess,
        );
      }
    } catch (_) {
      if (mounted) {
        AppSnackBar.show(
          context: context,
          message:
              _deleteController.errorMessage ??
              'Nao foi possivel excluir o insumo.',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _busyInsumoId = null);
    }
  }

  Future<void> _confirmDeleteRegistro(InsumoRegistroEntity registro) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Excluir registro',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Tem certeza que deseja excluir este registro de ${registro.estoqueNome} permanentemente?',
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
    setState(() => _busyRegistroId = registro.id);
    try {
      final result = await _deleteController.deleteRegistro(registro.id);
      if (!mounted) return;
      if (result != null) {
        _listController.removeRegistroById(registro.id);
        _listRevision.value++;
        AppSnackBar.show(
          context: context,
          message: result.message,
          isError: !result.isSuccess,
        );
      }
    } catch (_) {
      if (mounted) {
        AppSnackBar.show(
          context: context,
          message:
              _deleteController.errorMessage ??
              'Nao foi possivel excluir o registro.',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _busyRegistroId = null);
    }
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
        width: 420,
        child: TabBar(
          controller: _tabController,
          onTap: (index) => setState(() => _tabIndex = index),
          tabs: const [
            Tab(text: 'Lista'),
            Tab(text: 'Registros'),
            Tab(text: 'Gráficos'),
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
    final Listenable animation = _tabIndex == 2
        ? _chartsController
        : _listController;
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) => _toolbarContent(),
    );
  }

  Widget _toolbarContent() {
    final isList = _tabIndex == 0;
    final isRegistros = _tabIndex == 1;
    final isLoading = _tabIndex == 2
        ? _chartsController.isLoading
        : _listController.isLoading;
    final listCount = _listController.insumos.length;
    final registrosCount = _listController.registros.length;

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
                        ? listCount == 1
                              ? '1 insumo cadastrado'
                              : '$listCount insumos cadastrados'
                        : isRegistros
                        ? registrosCount == 1
                              ? '1 registro'
                              : '$registrosCount registros'
                        : 'Indicadores mensais de estoque',
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
                  onPressed: isLoading ? null : _openTipoFilter,
                ),
                const SizedBox(width: 8),
              ],
              _ToolbarIconButton(
                tooltip: isList
                    ? 'Atualizar lista'
                    : isRegistros
                    ? 'Atualizar registros'
                    : 'Atualizar gráficos',
                icon: LucideIcons.refreshCw,
                isLoading: isLoading,
                onPressed: isLoading
                    ? null
                    : _tabIndex == 2
                    ? _loadCharts
                    : _reloadList,
              ),
              if (isList) ...[
                const SizedBox(width: 8),
                _AddMenuButton(
                  compact: compact,
                  enabled: !isLoading,
                  onEntradaNovo: () =>
                      _openMovimento(tipo: 1, produtoNovo: true),
                  onEntradaExistente: () => _openMovimento(tipo: 1),
                  onSaida: () => _openMovimento(tipo: 2),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _stableTabBody() {
    final revision = _tabIndex == 2 ? _chartsRevision : _listRevision;
    final Listenable loadingAnimation = _tabIndex == 2
        ? _chartsController
        : _listController;
    bool isLoading() => _tabIndex == 2
        ? _chartsController.isLoading
        : _listController.isLoading;

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: ValueListenableBuilder<int>(
            valueListenable: revision,
            builder: (context, _, __) => switch (_tabIndex) {
              0 => _listTab(),
              1 => _registrosTab(),
              _ => _chartsTab(),
            },
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
    if (_listController.isLoading && _listController.insumos.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_listController.errorMessage != null &&
        _listController.insumos.isEmpty) {
      return _WebStateMessage(
        message: _listController.errorMessage!,
        actionLabel: 'Tentar novamente',
        onAction: _reloadList,
      );
    }
    if (_listController.insumos.isEmpty) {
      return WebEmptyState(
        icon: LucideIcons.package,
        title: 'Nenhum insumo cadastrado.',
        description: 'Use Adicionar para registrar uma entrada de estoque.',
        actionLabel: 'Entrada (produto novo)',
        onAction: () => _openMovimento(tipo: 1, produtoNovo: true),
      );
    }

    final itens = _listController.insumos;
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
                    if (wide) const _InsumoTableHeader(),
                    for (var index = 0; index < itens.length; index++) ...[
                      if (index > 0)
                        const Divider(height: 1, color: Color(0xFFE7E4DD)),
                      if (wide)
                        _InsumoTableRow(
                          tipoLabel: _listController.tipoLabel(
                            itens[index].tipoInsumo,
                          ),
                          description: _listController.buildDescription(
                            itens[index],
                          ),
                          quantity: _listController.buildQuantity(itens[index]),
                          valorTotal: _dash(itens[index].valorTotal),
                          validade: _dash(itens[index].dataValidade),
                          subUsuarioNome: itens[index].subUsuarioNome,
                          busy: _busyInsumoId == itens[index].id,
                          onOpen: () => _openDetails(itens[index]),
                          onEdit: () => _openEdit(itens[index]),
                          onDelete: () => _confirmDeleteInsumo(itens[index]),
                        )
                      else
                        _InsumoStackedRow(
                          tipoLabel: _listController.tipoLabel(
                            itens[index].tipoInsumo,
                          ),
                          description: _listController.buildDescription(
                            itens[index],
                          ),
                          quantity: _listController.buildQuantity(itens[index]),
                          valorTotal: _dash(itens[index].valorTotal),
                          validade: _dash(itens[index].dataValidade),
                          subUsuarioNome: itens[index].subUsuarioNome,
                          busy: _busyInsumoId == itens[index].id,
                          onOpen: () => _openDetails(itens[index]),
                          onEdit: () => _openEdit(itens[index]),
                          onDelete: () => _confirmDeleteInsumo(itens[index]),
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

  Widget _registrosTab() {
    if (!_listInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_listController.isLoading && _listController.registros.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_listController.errorMessage != null &&
        _listController.registros.isEmpty) {
      return _WebStateMessage(
        message: _listController.errorMessage!,
        actionLabel: 'Tentar novamente',
        onAction: _reloadList,
      );
    }

    final entradas = _listController.registros
        .where((r) => r.tipo.id?.toString() == '1')
        .toList();
    final saidas = _listController.registros
        .where((r) => r.tipo.id?.toString() != '1')
        .toList();

    if (entradas.isEmpty && saidas.isEmpty) {
      return const WebEmptyState(
        icon: LucideIcons.clipboardList,
        title: 'Nenhum registro cadastrado.',
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;
        final horizontal = constraints.maxWidth < 720 ? 16.0 : 28.0;
        return Scrollbar(
          child: ListView(
            padding: EdgeInsets.fromLTRB(horizontal, 18, horizontal, 32),
            children: [
              _RegistroSection(
                title: 'Entradas',
                registros: entradas,
                wide: wide,
                tipoLabel: _listController.tipoLabel,
                quantity: _listController.buildRegistroQuantity,
                busyId: _busyRegistroId,
                onDelete: _confirmDeleteRegistro,
              ),
              const SizedBox(height: 16),
              _RegistroSection(
                title: 'Saídas',
                registros: saidas,
                wide: wide,
                tipoLabel: _listController.tipoLabel,
                quantity: _listController.buildRegistroQuantity,
                busyId: _busyRegistroId,
                onDelete: _confirmDeleteRegistro,
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

    final data = charts ?? InsumoChartsEntity.empty;
    final empty =
        data.quantidadePorTipo.isEmpty && data.evolucaoMesAMes.isEmpty;

    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontal = constraints.maxWidth < 720 ? 16.0 : 28.0;
        return Scrollbar(
          child: ListView(
            padding: EdgeInsets.fromLTRB(horizontal, 18, horizontal, 32),
            children: [
              _MonthSelector(
                month: _chartsController.selectedMonth,
                isLoading: _chartsController.isLoading,
                onPrevious: _previousChartsMonth,
                onNext: _nextChartsMonth,
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
                _DistributionCard(
                  title: 'Estoques',
                  items: data.quantidadePorTipo,
                  colors: _chartColors,
                ),
                const SizedBox(height: 16),
                _LineChartCard(
                  title: 'Consumo mensal',
                  points: data.evolucaoMesAMes,
                ),
                const SizedBox(height: 16),
                _BarChartCard(
                  title: 'Evolução do valor em estoque',
                  items: data.quantidadePorTipo,
                  colors: _chartColors,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

String _dash(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? '-' : trimmed;
}

class _TipoFilterResult {
  const _TipoFilterResult({this.tipoInsumo});
  final String? tipoInsumo;
}

class _AddMenuButton extends StatelessWidget {
  const _AddMenuButton({
    required this.compact,
    required this.enabled,
    required this.onEntradaNovo,
    required this.onEntradaExistente,
    required this.onSaida,
  });

  final bool compact;
  final bool enabled;
  final VoidCallback onEntradaNovo;
  final VoidCallback onEntradaExistente;
  final VoidCallback onSaida;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: compact ? 126 : 170,
      height: 46,
      child: PopupMenuButton<int>(
        enabled: enabled,
        tooltip: 'Adicionar',
        offset: const Offset(0, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        onSelected: (value) {
          switch (value) {
            case 0:
              onEntradaNovo();
            case 1:
              onEntradaExistente();
            case 2:
              onSaida();
          }
        },
        itemBuilder: (_) => const [
          PopupMenuItem(
            value: 0,
            child: Text('Entrada (produto novo)'),
          ),
          PopupMenuItem(
            value: 1,
            child: Text('Entrada (produto existente)'),
          ),
          PopupMenuItem(value: 2, child: Text('Saída')),
        ],
        child: Container(
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: enabled ? MyColors.colorPrimary : const Color(0xFFBFC9C5),
            borderRadius: BorderRadius.circular(9),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_rounded, size: 19, color: Colors.white),
              SizedBox(width: 6),
              Text(
                'Adicionar',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 2),
              Icon(
                Icons.arrow_drop_down_rounded,
                size: 20,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
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

class _InsumoTableHeader extends StatelessWidget {
  const _InsumoTableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8F7F3),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
      child: const Row(
        children: [
          Expanded(flex: 2, child: _HeaderText('Tipo')),
          SizedBox(width: 16),
          Expanded(flex: 3, child: _HeaderText('Descrição')),
          SizedBox(width: 16),
          Expanded(flex: 2, child: _HeaderText('Quantidade')),
          SizedBox(width: 16),
          Expanded(flex: 2, child: _HeaderText('Valor')),
          SizedBox(width: 16),
          Expanded(flex: 2, child: _HeaderText('Validade')),
          SizedBox(width: 16),
          SizedBox(width: 188),
        ],
      ),
    );
  }
}

class _InsumoTableRow extends StatelessWidget {
  const _InsumoTableRow({
    required this.tipoLabel,
    required this.description,
    required this.quantity,
    required this.valorTotal,
    required this.validade,
    required this.subUsuarioNome,
    required this.busy,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
  });

  final String tipoLabel;
  final String description;
  final String quantity;
  final String valorTotal;
  final String validade;
  final String? subUsuarioNome;
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
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CellText(tipoLabel),
                    SubUserFlag(nome: subUsuarioNome),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(flex: 3, child: _CellText(description)),
              const SizedBox(width: 16),
              Expanded(flex: 2, child: _CellText(quantity)),
              const SizedBox(width: 16),
              Expanded(flex: 2, child: _CellText(valorTotal)),
              const SizedBox(width: 16),
              Expanded(flex: 2, child: _CellText(validade)),
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

class _InsumoStackedRow extends StatelessWidget {
  const _InsumoStackedRow({
    required this.tipoLabel,
    required this.description,
    required this.quantity,
    required this.valorTotal,
    required this.validade,
    required this.subUsuarioNome,
    required this.busy,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
  });

  final String tipoLabel;
  final String description;
  final String quantity;
  final String valorTotal;
  final String validade;
  final String? subUsuarioNome;
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
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tipoLabel,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF313131),
                ),
              ),
              SubUserFlag(nome: subUsuarioNome),
              const SizedBox(height: 8),
              _MetaLine(label: 'Descrição', value: description),
              _MetaLine(label: 'Quantidade', value: quantity),
              _MetaLine(label: 'Valor', value: valorTotal),
              _MetaLine(label: 'Validade', value: validade),
              const SizedBox(height: 12),
              _RowActions(
                busy: busy,
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

class _RegistroSection extends StatelessWidget {
  const _RegistroSection({
    required this.title,
    required this.registros,
    required this.wide,
    required this.tipoLabel,
    required this.quantity,
    required this.busyId,
    required this.onDelete,
  });

  final String title;
  final List<InsumoRegistroEntity> registros;
  final bool wide;
  final String Function(String) tipoLabel;
  final String Function(InsumoRegistroEntity) quantity;
  final int? busyId;
  final void Function(InsumoRegistroEntity) onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF313131),
          ),
        ),
        const SizedBox(height: 10),
        if (registros.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Nenhum item nesta seção.',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 13,
                color: Color(0xFF8C8C8C),
              ),
            ),
          )
        else
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
                if (wide) const _RegistroTableHeader(),
                for (var i = 0; i < registros.length; i++) ...[
                  if (i > 0)
                    const Divider(height: 1, color: Color(0xFFE7E4DD)),
                  if (wide)
                    _RegistroTableRow(
                      registro: registros[i],
                      tipoLabel: tipoLabel(registros[i].tipoInsumo),
                      quantity: quantity(registros[i]),
                      busy: busyId == registros[i].id,
                      onDelete: () => onDelete(registros[i]),
                    )
                  else
                    _RegistroStackedRow(
                      registro: registros[i],
                      tipoLabel: tipoLabel(registros[i].tipoInsumo),
                      quantity: quantity(registros[i]),
                      busy: busyId == registros[i].id,
                      onDelete: () => onDelete(registros[i]),
                    ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _RegistroTableHeader extends StatelessWidget {
  const _RegistroTableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8F7F3),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
      child: const Row(
        children: [
          Expanded(flex: 2, child: _HeaderText('Tipo')),
          SizedBox(width: 16),
          Expanded(flex: 3, child: _HeaderText('Produto')),
          SizedBox(width: 16),
          Expanded(flex: 2, child: _HeaderText('Quantidade')),
          SizedBox(width: 16),
          Expanded(flex: 2, child: _HeaderText('Data')),
          SizedBox(width: 16),
          SizedBox(width: 100),
        ],
      ),
    );
  }
}

class _RegistroTableRow extends StatelessWidget {
  const _RegistroTableRow({
    required this.registro,
    required this.tipoLabel,
    required this.quantity,
    required this.busy,
    required this.onDelete,
  });

  final InsumoRegistroEntity registro;
  final String tipoLabel;
  final String quantity;
  final bool busy;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Expanded(flex: 2, child: _CellText(tipoLabel)),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CellText(registro.estoqueNome),
                if ((registro.obs ?? '').trim().isNotEmpty)
                  Text(
                    registro.obs!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 11,
                      color: Color(0xFF8C8C8C),
                    ),
                  ),
                SubUserFlag(nome: registro.subUsuarioNome),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: _CellText('${registro.tipo.nome} · $quantity'),
          ),
          const SizedBox(width: 16),
          Expanded(flex: 2, child: _CellText(_dash(registro.dataCadastro))),
          const SizedBox(width: 16),
          SizedBox(
            width: 100,
            child: _DeleteOnlyAction(busy: busy, onDelete: onDelete),
          ),
        ],
      ),
    );
  }
}

class _RegistroStackedRow extends StatelessWidget {
  const _RegistroStackedRow({
    required this.registro,
    required this.tipoLabel,
    required this.quantity,
    required this.busy,
    required this.onDelete,
  });

  final InsumoRegistroEntity registro;
  final String tipoLabel;
  final String quantity;
  final bool busy;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            registro.estoqueNome,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF313131),
            ),
          ),
          SubUserFlag(nome: registro.subUsuarioNome),
          const SizedBox(height: 8),
          _MetaLine(label: 'Tipo', value: tipoLabel),
          _MetaLine(label: 'Movimento', value: '${registro.tipo.nome} · $quantity'),
          _MetaLine(label: 'Data', value: _dash(registro.dataCadastro)),
          if ((registro.obs ?? '').trim().isNotEmpty)
            _MetaLine(label: 'Obs.', value: registro.obs!),
          const SizedBox(height: 12),
          _DeleteOnlyAction(busy: busy, onDelete: onDelete, expanded: true),
        ],
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
      height: 36,
      width: expanded ? null : 88,
      child: OutlinedButton(
        onPressed: busy ? null : onEdit,
        style: OutlinedButton.styleFrom(
          foregroundColor: MyColors.colorPrimary,
          side: const BorderSide(color: Color(0xFFC9D4CB)),
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        child: const Text('Editar'),
      ),
    );
    final remove = SizedBox(
      height: 36,
      width: expanded ? null : 88,
      child: OutlinedButton(
        onPressed: busy ? null : onDelete,
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFC4473A),
          side: const BorderSide(color: Color(0xFFC4473A)),
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        child: busy
            ? const SizedBox.square(
                dimension: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Excluir'),
      ),
    );
    return Row(
      children: [
        if (expanded) Expanded(child: edit) else edit,
        const SizedBox(width: 8),
        if (expanded) Expanded(child: remove) else remove,
      ],
    );
  }
}

class _DeleteOnlyAction extends StatelessWidget {
  const _DeleteOnlyAction({
    required this.busy,
    required this.onDelete,
    this.expanded = false,
  });

  final bool busy;
  final VoidCallback onDelete;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      width: expanded ? double.infinity : 100,
      child: OutlinedButton(
        onPressed: busy ? null : onDelete,
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFC4473A),
          side: const BorderSide(color: Color(0xFFC4473A)),
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        child: busy
            ? const SizedBox.square(
                dimension: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Excluir'),
      ),
    );
  }
}

class _MetaLine extends StatelessWidget {
  const _MetaLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 88,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 12,
                color: Color(0xFF8C8C8C),
              ),
            ),
          ),
          Expanded(child: _CellText(value)),
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
      text,
      style: const TextStyle(
        fontFamily: 'Montserrat',
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: Color(0xFF5C5C5C),
      ),
    );
  }
}

class _CellText extends StatelessWidget {
  const _CellText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontFamily: 'Montserrat',
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: Color(0xFF313131),
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

class _TipoFilterWebDialog extends StatefulWidget {
  const _TipoFilterWebDialog({
    required this.tipos,
    this.selectedTipoId,
  });

  final List<InsumoReferenceEntity> tipos;
  final String? selectedTipoId;

  @override
  State<_TipoFilterWebDialog> createState() => _TipoFilterWebDialogState();
}

class _TipoFilterWebDialogState extends State<_TipoFilterWebDialog> {
  String? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.selectedTipoId;
  }

  @override
  Widget build(BuildContext context) {
    return WebDialogFrame(
      title: 'Filtrar por tipo',
      width: 480,
      maxHeight: 520,
      footer: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  _TipoFilterResult(tipoInsumo: _selected),
                );
              },
              text: 'Aplicar',
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  const _TipoFilterResult(tipoInsumo: null),
                );
              },
              child: const Text('Limpar filtros'),
            ),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String?>(
              value: null,
              groupValue: _selected,
              title: const Text(
                'Todos',
                style: TextStyle(fontFamily: 'Montserrat', fontSize: 14),
              ),
              onChanged: (value) => setState(() => _selected = value),
            ),
            for (final tipo in widget.tipos)
              RadioListTile<String?>(
                value: tipo.id?.toString(),
                groupValue: _selected,
                title: Text(
                  tipo.nome,
                  style: const TextStyle(fontFamily: 'Montserrat', fontSize: 14),
                ),
                onChanged: (value) => setState(() => _selected = value),
              ),
          ],
        ),
      ),
    );
  }
}

class _InsumoDetailsWebDialog extends StatelessWidget {
  const _InsumoDetailsWebDialog({
    required this.insumo,
    required this.tipoLabel,
  });

  final InsumoEntity insumo;
  final String tipoLabel;

  @override
  Widget build(BuildContext context) {
    return WebDialogFrame(
      title: 'Detalhes do insumo',
      width: 640,
      maxHeight: 760,
      bodyPadding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _DetailField(label: 'Tipo de insumo', value: tipoLabel),
          _DetailField(label: 'Nome comercial', value: insumo.nome),
          if (insumo.suplemento != null)
            _DetailField(
              label: 'Suplemento',
              value: insumo.suplemento!.nome,
            ),
          _DetailField(
            label: 'Quantidade',
            value: _quantity(insumo.qtdTotal, insumo.unidade?.nome),
          ),
          _DetailField(
            label: 'Preço por unidade',
            value: _money(insumo.valorUnidade, insumo.unidade?.nome),
          ),
          _DetailField(label: 'Valor total', value: _dash(insumo.valorTotal)),
          _DetailField(label: 'Validade', value: _dash(insumo.dataValidade)),
          _DetailField(label: 'Observações', value: _dash(insumo.obs)),
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

String _quantity(double? value, String? unidade) {
  if (value == null) return '-';
  final unit = unidade?.trim();
  final text = value % 1 == 0 ? value.toInt().toString() : value.toString();
  return unit == null || unit.isEmpty ? text : '$text $unit';
}

String _money(String? value, String? unidade) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return '-';
  final unit = unidade?.trim();
  return unit == null || unit.isEmpty ? trimmed : '$trimmed/$unit';
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE7E4DD)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: isLoading ? null : onPrevious,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          Text(
            _formatMonth(month),
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF5C5C5C),
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

String _formatMonth(DateTime date) {
  const months = [
    'Janeiro',
    'Fevereiro',
    'Março',
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
  return '${months[date.month - 1]} ${date.year}';
}

class _DistributionCard extends StatelessWidget {
  const _DistributionCard({
    required this.title,
    required this.items,
    required this.colors,
  });

  final String title;
  final List<InsumoQuantidadePorTipoEntity> items;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    final visibleItems = items
        .where((item) => item.quantidade > 0 || item.percentual > 0)
        .toList(growable: false);

    return _ChartCard(
      title: title,
      child: visibleItems.isEmpty
          ? const _EmptyChartText()
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 220,
                  child: Center(
                    child: SizedBox(
                      width: 180,
                      height: 180,
                      child: CustomPaint(
                        painter: _DonutChartPainter(
                          items: visibleItems,
                          colors: colors,
                        ),
                      ),
                    ),
                  ),
                ),
                Wrap(
                  spacing: 18,
                  runSpacing: 12,
                  children: [
                    for (var i = 0; i < visibleItems.length; i++)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: colors[i % colors.length],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${_titleCase(visibleItems[i].tipoInsumo)} (${_formatDecimal(visibleItems[i].percentual)}%)',
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 12,
                              color: Color(0xFF666666),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
    );
  }
}

class _LineChartCard extends StatelessWidget {
  const _LineChartCard({required this.title, required this.points});

  final String title;
  final List<InsumoChartPointEntity> points;

  @override
  Widget build(BuildContext context) {
    return _ChartCard(
      title: title,
      child: points.isEmpty
          ? const _EmptyChartText()
          : SizedBox(
              height: 240,
              width: double.infinity,
              child: CustomPaint(
                painter: _LineChartPainter(points: points),
              ),
            ),
    );
  }
}

class _BarChartCard extends StatelessWidget {
  const _BarChartCard({
    required this.title,
    required this.items,
    required this.colors,
  });

  final String title;
  final List<InsumoQuantidadePorTipoEntity> items;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    final visibleItems = items.take(6).toList(growable: false);
    return _ChartCard(
      title: title,
      child: visibleItems.isEmpty
          ? const _EmptyChartText()
          : SizedBox(
              height: 240,
              width: double.infinity,
              child: CustomPaint(
                painter: _BarChartPainter(
                  items: visibleItems,
                  colors: colors,
                ),
              ),
            ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.title, required this.child});

  final String title;
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF313131),
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _EmptyChartText extends StatelessWidget {
  const _EmptyChartText();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.pieChart, size: 28, color: Color(0xFFB7C4BA)),
          SizedBox(height: 12),
          Text(
            'Sem dados para exibir neste período.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF8C8C8C),
              fontSize: 12,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  _DonutChartPainter({required this.items, required this.colors});

  final List<InsumoQuantidadePorTipoEntity> items;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final total = items.fold<double>(0, (sum, item) => sum + item.quantidade);
    if (total <= 0) return;
    final rect = Offset.zero & size;
    final strokeWidth = size.width * 0.16;
    var startAngle = -math.pi / 2;
    for (var index = 0; index < items.length; index++) {
      final sweep = (items[index].quantidade / total) * math.pi * 2;
      final paint = Paint()
        ..color = colors[index % colors.length]
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        rect.deflate(strokeWidth / 2),
        startAngle,
        math.max(0.02, sweep),
        false,
        paint,
      );
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.items != items || oldDelegate.colors != colors;
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({required this.points});

  final List<InsumoChartPointEntity> points;

  @override
  void paint(Canvas canvas, Size size) {
    const left = 42.0;
    const bottom = 34.0;
    const top = 12.0;
    const right = 10.0;
    final chart = Rect.fromLTRB(
      left,
      top,
      size.width - right,
      size.height - bottom,
    );
    final maxValue = _niceMax(
      points.map((point) => point.value).fold(0.0, math.max),
    );
    final gridPaint = Paint()
      ..color = const Color(0xFFEDEDED)
      ..strokeWidth = 1;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (var i = 0; i <= 4; i++) {
      final y = chart.top + (chart.height / 4) * i;
      canvas.drawLine(Offset(chart.left, y), Offset(chart.right, y), gridPaint);
      final value = maxValue - (maxValue / 4) * i;
      _drawChartText(
        textPainter,
        canvas,
        _formatDecimal(value),
        Offset(0, y - 8),
      );
    }

    if (points.length == 1) {
      final p = Offset(
        chart.left,
        chart.bottom - (points.first.value / maxValue) * chart.height,
      );
      _drawPoint(canvas, p);
    } else {
      final path = Path();
      for (var i = 0; i < points.length; i++) {
        final x = chart.left + (chart.width / (points.length - 1)) * i;
        final y = chart.bottom - (points[i].value / maxValue) * chart.height;
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = const Color(0xFF147AD6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
      for (var i = 0; i < points.length; i++) {
        final x = chart.left + (chart.width / (points.length - 1)) * i;
        final y = chart.bottom - (points[i].value / maxValue) * chart.height;
        _drawPoint(canvas, Offset(x, y));
      }
    }

    for (var i = 0; i < points.length; i++) {
      final x = points.length == 1
          ? chart.left
          : chart.left + (chart.width / (points.length - 1)) * i;
      _drawChartText(
        textPainter,
        canvas,
        _shortLabel(points[i].label),
        Offset(x - 14, chart.bottom + 12),
      );
    }
  }

  void _drawPoint(Canvas canvas, Offset offset) {
    canvas.drawCircle(offset, 8, Paint()..color = Colors.white);
    canvas.drawCircle(offset, 6, Paint()..color = const Color(0xFF147AD6));
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.points != points;
  }
}

class _BarChartPainter extends CustomPainter {
  _BarChartPainter({required this.items, required this.colors});

  final List<InsumoQuantidadePorTipoEntity> items;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    const left = 42.0;
    const bottom = 34.0;
    const top = 12.0;
    const right = 10.0;
    final chart = Rect.fromLTRB(
      left,
      top,
      size.width - right,
      size.height - bottom,
    );
    final maxValue = _niceMax(
      items.map((item) => item.quantidade).fold(0.0, math.max),
    );
    final gridPaint = Paint()
      ..color = const Color(0xFFEDEDED)
      ..strokeWidth = 1;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (var i = 0; i <= 4; i++) {
      final y = chart.top + (chart.height / 4) * i;
      canvas.drawLine(Offset(chart.left, y), Offset(chart.right, y), gridPaint);
      final value = maxValue - (maxValue / 4) * i;
      _drawChartText(
        textPainter,
        canvas,
        _formatDecimal(value),
        Offset(0, y - 8),
      );
    }

    final slot = chart.width / items.length;
    final barWidth = math.min(42.0, slot * 0.42);
    for (var i = 0; i < items.length; i++) {
      final height = (items[i].quantidade / maxValue) * chart.height;
      final x = chart.left + slot * i + (slot - barWidth) / 2;
      final rect = RRect.fromRectAndCorners(
        Rect.fromLTWH(x, chart.bottom - height, barWidth, height),
        topLeft: const Radius.circular(8),
        topRight: const Radius.circular(8),
      );
      canvas.drawRRect(rect, Paint()..color = colors[i % colors.length]);
      _drawChartText(
        textPainter,
        canvas,
        String.fromCharCode(65 + i),
        Offset(x + barWidth / 2 - 5, chart.bottom + 12),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) {
    return oldDelegate.items != items || oldDelegate.colors != colors;
  }
}

double _niceMax(double value) {
  if (value <= 0) return 100;
  final padded = value * 1.2;
  if (padded <= 10) return 10;
  if (padded <= 50) return 50;
  if (padded <= 100) return 100;
  return (padded / 50).ceil() * 50;
}

void _drawChartText(
  TextPainter painter,
  Canvas canvas,
  String text,
  Offset offset,
) {
  painter.text = TextSpan(
    text: text,
    style: const TextStyle(
      color: Color(0xFFA1A1A1),
      fontSize: 12,
      fontFamily: 'Montserrat',
      fontWeight: FontWeight.w500,
    ),
  );
  painter.layout();
  painter.paint(canvas, offset);
}

String _formatDecimal(double value) {
  if (value == value.truncateToDouble()) return value.toStringAsFixed(0);
  return value.toStringAsFixed(2);
}

String _titleCase(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return 'Insumo';
  return trimmed[0].toUpperCase() + trimmed.substring(1);
}

String _shortLabel(String value) {
  final trimmed = value.trim();
  if (trimmed.length <= 3) return trimmed;
  if (trimmed.contains('/')) return trimmed.split('/').first;
  return trimmed.substring(0, 3);
}
