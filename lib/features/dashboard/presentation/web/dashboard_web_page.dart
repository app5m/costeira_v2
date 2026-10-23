import 'package:costeira/core/common/get_list/domain/entities/app_menu_entity.dart';
import 'package:costeira/core/common/get_list/domain/entities/get_list_params_entity.dart';
import 'package:costeira/core/common/get_list/domain/usecases/get_list_usecase.dart';
import 'package:costeira/core/components/app_select_overlay.dart';
import 'package:costeira/core/menus/app_menus_controller.dart';
import 'package:costeira/core/menus/menu_action_resolver.dart';
import 'package:costeira/core/menus/menu_icon.dart';
import 'package:costeira/core/menus/menu_slug.dart';
import 'package:costeira/core/offline/cache/form_dependencies_cache_service.dart';
import 'package:costeira/core/storage/sub_user_payload.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/features/dashboard/domain/entities/dashboard_entity.dart';
import 'package:costeira/features/dashboard/domain/entities/dashboard_filter_entity.dart';
import 'package:costeira/features/dashboard/presentation/controllers/get_dashboard_controller.dart';
import 'package:costeira/core/components/web_dialog_frame.dart';
import 'package:costeira/features/dashboard/presentation/web/dashboard_action_web_dialog.dart';
import 'package:costeira/features/dashboard/presentation/widgets/dashboard_charts.dart';
import 'package:costeira/features/fazendas/domain/entities/fazenda_entity.dart';
import 'package:costeira/features/fazendas/domain/entities/fazenda_filter_entity.dart';
import 'package:costeira/features/fazendas/domain/usecases/get_fazendas_usecase.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:lucide_icons/lucide_icons.dart';

class DashboardWebToolbarData {
  const DashboardWebToolbarData({
    required this.farms,
    required this.selectedFarmId,
    required this.years,
    required this.selectedPeriod,
    required this.customPeriodLabel,
    required this.loadingFarms,
    required this.loadingDashboard,
    required this.farmLabel,
    required this.onFarmChanged,
    required this.onPeriodChanged,
    required this.onRefresh,
  });

  final List<FazendaEntity> farms;
  final int? selectedFarmId;
  final List<AgriculturalYearRange> years;
  final String selectedPeriod;
  final String customPeriodLabel;
  final bool loadingFarms;
  final bool loadingDashboard;
  final String Function(FazendaEntity farm) farmLabel;
  final Future<void> Function(int? farmId) onFarmChanged;
  final Future<void> Function(String? period) onPeriodChanged;
  final Future<void> Function() onRefresh;
}

class DashboardWebToolbar extends StatelessWidget {
  const DashboardWebToolbar({super.key, required this.data});

  static const _customPeriodValue = '__custom_period__';

  final DashboardWebToolbarData data;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final farm = _SelectField<int>(
          icon: LucideIcons.warehouse,
          label: 'Fazenda',
          value: data.selectedFarmId,
          isLoading: data.loadingFarms,
          emptyLabel: 'Nenhuma fazenda',
          items: [
            for (final item in data.farms)
              AppSelectOption(value: item.id, label: data.farmLabel(item)),
          ],
          onChanged: data.onFarmChanged,
        );
        final period = _SelectField<String>(
          icon: LucideIcons.calendar,
          label: 'Ano agrícola',
          value: data.selectedPeriod,
          items: [
            for (final item in data.years)
              AppSelectOption(value: item.label, label: item.label),
            AppSelectOption(
              value: _customPeriodValue,
              label: data.customPeriodLabel,
            ),
          ],
          onChanged: data.onPeriodChanged,
        );

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(flex: 5, child: farm),
            const SizedBox(width: 8),
            Expanded(flex: 4, child: period),
            const SizedBox(width: 8),
            _ToolbarIconButton(
              tooltip: 'Atualizar dashboard',
              icon: LucideIcons.refreshCw,
              isLoading: data.loadingDashboard,
              onPressed: data.loadingDashboard ? null : data.onRefresh,
            ),
          ],
        );
      },
    );
  }
}

class _ToolbarIconButton extends StatelessWidget {
  const _ToolbarIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.isLoading = false,
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

class DashboardWebPage extends StatefulWidget {
  const DashboardWebPage({
    super.key,
    this.onToolbarChanged,
    this.onWebContextChanged,
  });

  final ValueChanged<DashboardWebToolbarData?>? onToolbarChanged;
  final Future<void> Function()? onWebContextChanged;

  @override
  State<DashboardWebPage> createState() => _DashboardWebPageState();
}

class _DashboardWebPageState extends State<DashboardWebPage> {
  static const _customPeriodValue = '__custom_period__';

  late final GetDashboardController _dashboard;
  late List<AgriculturalYearRange> _years;
  late AgriculturalYearRange _year;
  DateTime? _customStart;
  DateTime? _customEnd;

  List<FazendaEntity> _farms = const [];
  int? _farmId;
  bool _loadingFarms = true;
  bool _wasLoading = false;
  int _chartPlay = 0;

  bool get _isRefreshing => _loadingFarms || _dashboard.isLoading;

  @override
  void initState() {
    super.initState();
    _year = AgriculturalYearRange.containing(DateTime.now());
    _years = AgriculturalYearRange.options(DateTime.now());
    _dashboard = Modular.get<GetDashboardController>();
    _dashboard.addListener(_onDashboardChanged);
    _loadFarms();
    _publishToolbar();
  }

  @override
  void dispose() {
    _dashboard.removeListener(_onDashboardChanged);
    _dashboard.dispose();
    super.dispose();
  }

  void _onDashboardChanged() {
    if (!mounted) return;
    final loading = _dashboard.isLoading;
    setState(() {
      if (_wasLoading && !loading) {
        _chartPlay++;
      }
      _wasLoading = loading;
    });
    _publishToolbar();
  }

  void _publishToolbar() {
    final callback = widget.onToolbarChanged;
    if (callback == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      callback(
        DashboardWebToolbarData(
          farms: List.unmodifiable(_farms),
          selectedFarmId: _farmId,
          years: List.unmodifiable(_years),
          selectedPeriod: _periodValue,
          customPeriodLabel: _customStart == null
              ? 'Selecionar datas'
              : _customPeriodLabel,
          loadingFarms: _loadingFarms,
          loadingDashboard: _isRefreshing,
          farmLabel: _farmLabel,
          onFarmChanged: _selectFarm,
          onPeriodChanged: _selectPeriod,
          onRefresh: _onRefresh,
        ),
      );
    });
  }

  Future<void> _loadFarms() async {
    try {
      final user = await SessionStorage.getUserSession();
      if (user == null) {
        if (mounted) setState(() => _loadingFarms = false);
        return;
      }

      final result = await Modular.get<GetFazendasUsecase>()(
        FazendaFilterEntity(appUsersId: sessionAccountUserId(user.id)),
      );
      final saved = await SessionStorage.getSelectedFarmId();
      final match = result.data.where((farm) => farm.id == saved);
      // A API devolve a fazenda principal da conta na primeira posição.
      final fallbackId = result.data.isEmpty ? null : result.data.first.id;
      final selectedId = match.isNotEmpty ? match.first.id : fallbackId;
      if (selectedId != null) {
        await SessionStorage.saveSelectedFarmId(selectedId);
      } else {
        await SessionStorage.clearSelectedFarmId();
      }
      await _loadAgriculturalYears();
      if (!mounted) return;
      setState(() {
        _farms = result.data;
        _farmId = selectedId;
        _loadingFarms = false;
      });
      _publishToolbar();
      await _loadDashboard();
    } catch (_) {
      if (mounted) {
        setState(() => _loadingFarms = false);
        _publishToolbar();
      }
    }
  }

  Future<void> _loadAgriculturalYears() async {
    try {
      final user = await SessionStorage.getUserSession();
      final result = await Modular.get<GetListUsecase>()(
        GetListParamsEntity(
          sexo: 1,
          userId: user == null ? null : sessionAccountUserId(user.id),
        ),
      );
      if (result.anosAgricolas.isEmpty) return;
      _years = result.anosAgricolas;
      final savedLabel = await SessionStorage.getWebAgriculturalYearLabel();
      final saved = _years.where((item) => item.label == savedLabel);
      _year = saved.isNotEmpty
          ? saved.first
          : AgriculturalYearRange.containingIn(_years, DateTime.now()) ??
                _years.first;
      await SessionStorage.saveWebAgriculturalYearLabel(_year.label);
    } catch (_) {}
  }

  Future<void> _loadDashboard() async {
    final farmId = _farmId;
    if (farmId == null || farmId <= 0) return;
    try {
      final custom = _customStart != null && _customEnd != null;
      await _dashboard.load(
        filter: DashboardFilterEntity(
          appFazendasId: farmId,
          idAnoAgricola: custom ? null : _year.id,
          dataIn: custom ? _customStart! : _year.dataIn,
          dataOut: custom ? _customEnd! : _year.dataOut,
        ),
      );
    } catch (_) {}
  }

  Future<void> _onRefresh() async {
    final onWebContextChanged = widget.onWebContextChanged;
    if (onWebContextChanged != null) {
      if (!_loadingFarms && mounted) {
        setState(() => _loadingFarms = true);
        _publishToolbar();
      }
      await onWebContextChanged();
      return;
    }
    setState(() => _loadingFarms = true);
    _publishToolbar();
    await Future.wait([
      Modular.get<AppMenusController>().refresh(),
      _loadFarms(),
      Modular.get<FormDependenciesCacheService>().preloadEssentialLists(
        force: true,
      ),
    ]);
  }

  Future<void> _selectFarm(int? farmId) async {
    if (farmId == null || farmId == _farmId) return;
    await SessionStorage.saveSelectedFarmId(farmId);
    if (!mounted) return;
    setState(() {
      _farmId = farmId;
      _loadingFarms = true;
    });
    _publishToolbar();
    final onWebContextChanged = widget.onWebContextChanged;
    if (onWebContextChanged != null) {
      await onWebContextChanged();
      return;
    }
    await _loadDashboard();
  }

  Future<void> _selectPeriod(String? value) async {
    if (value == null) return;
    if (value == _customPeriodValue) {
      await _pickCustomDates();
      return;
    }
    final selected = _years.where((item) => item.label == value);
    if (selected.isEmpty) return;
    setState(() {
      _customStart = null;
      _customEnd = null;
      _year = selected.first;
    });
    await SessionStorage.saveWebAgriculturalYearLabel(_year.label);
    _publishToolbar();
    final onWebContextChanged = widget.onWebContextChanged;
    if (onWebContextChanged != null) {
      await onWebContextChanged();
      return;
    }
    await _loadDashboard();
  }

  Future<void> _pickCustomDates() async {
    final range = await showDialog<_PeriodRange>(
      context: context,
      builder: (_) => _PeriodDialog(
        start: _customStart ?? _year.dataIn,
        end: _customEnd ?? _year.dataOut,
      ),
    );
    if (!mounted || range == null) return;
    setState(() {
      _customStart = range.start;
      _customEnd = range.end;
    });
    _publishToolbar();
    await _loadDashboard();
  }

  Future<void> _openQuickAction(AppMenuEntity item) async {
    if (item.children.isEmpty) {
      await _openDashboardItem(item);
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => _DashboardActionsDialog(
        title: item.name,
        description: item.description,
        items: item.children,
        onOpen: (child) async {
          Navigator.pop(dialogContext);
          await _openDashboardItem(child);
        },
      ),
    );
  }

  Future<void> _openDashboardItem(AppMenuEntity item) async {
    final slug = MenuActionResolver.slugOf(item);
    final page = MenuActionResolver.dashboardPage(slug);
    if (_usesWebDialog(slug) && page != null) {
      final result = await showDialog<Object?>(
        context: context,
        barrierDismissible: false,
        builder: (_) => DashboardActionWebDialog(
          title: _webDialogTitle(slug, item.name),
          bodyPadding: slug == MenuSlug.manejoAnimal
              ? const EdgeInsets.only(bottom: 20)
              : EdgeInsets.zero,
          child: page(),
        ),
      );
      if (!mounted || !_isSuccessfulMutation(result)) return;
      await _onRefresh();
      return;
    }
    await MenuActionResolver.open(
      context,
      item,
      surface: MenuSurface.dashboard,
    );
  }

  bool _isSuccessfulMutation(Object? result) {
    if (result == true) return true;
    return result is Map && result['success'] == true;
  }

  bool _usesWebDialog(String slug) {
    return switch (slug) {
      MenuSlug.compra ||
      MenuSlug.nascimento ||
      'parto' ||
      MenuSlug.transferenciaRecebida ||
      'transferencia_enviada' ||
      'movimentacao_de_piquete' ||
      MenuSlug.estoque ||
      'estoque_entrada' ||
      'baixa_estoque' ||
      MenuSlug.venda ||
      MenuSlug.morte ||
      'abigeato' ||
      'consumo' ||
      'consumo_carnear' ||
      MenuSlug.manejoAnimal ||
      'manejo_campo' ||
      'manejo_reprodutivo' ||
      'sanitario' ||
      'suplementacao' ||
      'troca_de_categoria' ||
      'aborto' => true,
      _ => false,
    };
  }

  String _webDialogTitle(String slug, String fallback) {
    return switch (slug) {
      MenuSlug.compra => 'Adicionar compra',
      MenuSlug.nascimento || 'parto' => 'Registrar nascimento',
      'transferencia_enviada' ||
      'movimentacao_de_piquete' => 'Adicionar transferência',
      'estoque_entrada' || MenuSlug.estoque => 'Entrada de insumo',
      'baixa_estoque' => 'Baixa de estoque',
      MenuSlug.venda => 'Registrar venda',
      MenuSlug.morte => 'Registrar morte',
      'abigeato' => 'Registrar abigeato',
      'consumo' || 'consumo_carnear' => 'Registrar consumo',
      MenuSlug.manejoAnimal => 'Manejo animal',
      'manejo_campo' => 'Manejo de campo',
      'manejo_reprodutivo' => 'Manejo reprodutivo',
      'sanitario' => 'Planejamento sanitário',
      'suplementacao' => 'Adicionar suplementação',
      'troca_de_categoria' => 'Troca de categoria',
      'aborto' => 'Registrar aborto',
      _ => fallback,
    };
  }

  String _farmLabel(FazendaEntity farm) {
    if (farm.nome.trim().isNotEmpty) return farm.nome.trim();
    if (farm.nomeFantasia.trim().isNotEmpty) return farm.nomeFantasia.trim();
    return 'Fazenda ${farm.id}';
  }

  String get _periodValue => _customStart != null && _customEnd != null
      ? _customPeriodValue
      : _year.label;

  String get _customPeriodLabel =>
      '${_shortDate(_customStart!)} – ${_shortDate(_customEnd!)}';

  String _shortDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = (date.year % 100).toString().padLeft(2, '0');
    return '$day/$month/$year';
  }

  DashboardEntity get _data => _dashboard.dashboard ?? DashboardEntity.empty;

  List<_DashboardMetric> get _metrics {
    final indicators = _data.indicadores;
    return [
      _DashboardMetric(
        title: 'Total de animais',
        value: '${indicators.totalAnimais}',
        subtitle: indicators.totalAnimaisUnidade,
        hint: indicators.estoqueRebanhoReais.valor,
      ),
      _DashboardMetric(
        title: 'Lotação',
        value: indicators.mediaFazenda.valor ?? '0',
        subtitle: indicators.mediaFazenda.descricao ?? 'UA/ha',
        hint: indicators.mediaFazenda.observacao,
      ),
      _DashboardMetric(
        title: 'Mortalidade',
        value: indicators.mortalidadePercentual.valor ?? '0',
        subtitle: indicators.mortalidadePercentual.descricao ?? '%',
        hint: indicators.mortalidadePercentual.observacao,
      ),
      _DashboardMetric(
        title: 'GMD global',
        value: indicators.ganhoMedioDiario.valor ?? '0',
        subtitle: indicators.ganhoMedioDiario.descricao ?? 'kg/dia',
        hint: indicators.ganhoMedioDiario.observacao,
      ),
      _DashboardMetric(
        title: 'Produtividade',
        value: indicators.kilosPorHectare.valor ?? '0',
        subtitle: indicators.kilosPorHectare.descricao ?? 'kg/ha',
        hint: indicators.kilosPorHectare.hectares == null
            ? indicators.kilosPorHectare.observacao
            : '${indicators.kilosPorHectare.hectares} ha',
      ),
      _DashboardMetric(
        title: 'Kg produzidos',
        value: indicators.quantidadeKilosProduzidos.valor ?? '0',
        subtitle:
            indicators.quantidadeKilosProduzidos.descricao ?? 'no período',
        hint: indicators.quantidadeKilosProduzidos.observacao,
      ),
    ];
  }

  List<DashboardTaskSlice> _taskSlices(DashboardTasksProgressEntity progress) {
    return [
      if (progress.pendentes > 0)
        DashboardTaskSlice(
          label: 'Pendentes',
          value: progress.pendentes.toDouble(),
          color: const Color(0xFF8B4A2B),
        ),
      if (progress.emAndamento > 0)
        DashboardTaskSlice(
          label: 'Em andamento',
          value: progress.emAndamento.toDouble(),
          color: const Color(0xFFD9762B),
        ),
      if (progress.concluidas > 0)
        DashboardTaskSlice(
          label: 'Concluídas',
          value: progress.concluidas.toDouble(),
          color: const Color(0xFF2F7A4A),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final viewportWidth = MediaQuery.sizeOf(context).width;
    final indicators = _data.indicadores.tarefasMes;
    final charts = _data.graficos;
    final quickActions = Modular.get<AppMenusController>().dashboardMenu;

    return ColoredBox(
      color: const Color(0xFFF4F2EB),
      child: Stack(
        children: [
          Column(
            children: [
              if (_isRefreshing) const LinearProgressIndicator(minHeight: 2),
              Expanded(
                child: RefreshIndicator(
                  color: MyColors.colorPrimary,
                  onRefresh: _onRefresh,
                  child: Scrollbar(
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(
                        viewportWidth < 760 ? 16 : 28,
                        viewportWidth < 760 ? 16 : 18,
                        viewportWidth < 760 ? 16 : 28,
                        quickActions.isEmpty ? 32 : 112,
                      ),
                      children: [
                        Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1600),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (_dashboard.errorMessage != null) ...[
                                  _ErrorBanner(
                                    message: _dashboard.errorMessage!,
                                  ),
                                  const SizedBox(height: 14),
                                ],
                                _TasksSummary(
                                  pending: indicators.pendentes,
                                  overdue: indicators.emAtraso,
                                  urgent: indicators.urgentes,
                                ),
                                const SizedBox(height: 12),
                                _metricGrid(viewportWidth),
                                const SizedBox(height: 12),
                                _chartGrid(viewportWidth, charts),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (quickActions.isNotEmpty)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _QuickActionsStrip(
                items: quickActions,
                onTap: _openQuickAction,
              ),
            ),
        ],
      ),
    );
  }

  Widget _metricGrid(double viewportWidth) {
    final columns = viewportWidth >= 1120 ? 6 : (viewportWidth >= 760 ? 3 : 2);
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 10.0;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final metric in _metrics)
              SizedBox(
                width: width,
                child: _MetricCard(metric: metric),
              ),
          ],
        );
      },
    );
  }

  Widget _chartGrid(double viewportWidth, DashboardChartsEntity charts) {
    final widgets = <Widget>[
      DashboardCompositionChart(
        playToken: _chartPlay,
        slices: charts.animaisCategoria
            .where((item) => item.quantidade > 0)
            .toList(growable: false),
      ),
      DashboardEvolutionChart(
        playToken: _chartPlay,
        months: charts.producaoKgMes,
      ),
      DashboardTasksChart(
        playToken: _chartPlay,
        slices: _taskSlices(charts.progressoTarefas),
        total: charts.progressoTarefas.total,
      ),
    ];
    if (viewportWidth < 1120) {
      return Column(
        children: [
          for (var i = 0; i < widgets.length; i++) ...[
            widgets[i],
            if (i < widgets.length - 1) const SizedBox(height: 12),
          ],
        ],
      );
    }
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: 10, child: widgets[0]),
          const SizedBox(width: 12),
          Expanded(flex: 16, child: widgets[1]),
          const SizedBox(width: 12),
          Expanded(flex: 10, child: widgets[2]),
        ],
      ),
    );
  }
}

class _SelectField<T> extends StatelessWidget {
  const _SelectField({
    required this.icon,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.isLoading = false,
    this.emptyLabel = 'Selecione',
  });

  final IconData icon;
  final String label;
  final T? value;
  final List<AppSelectOption<T>> items;
  final ValueChanged<T?> onChanged;
  final bool isLoading;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    final effectiveValue = items.any((item) => item.value == value)
        ? value
        : null;
    return AppSelectOverlay<T>(
      value: effectiveValue,
      options: items,
      enabled: !isLoading && items.isNotEmpty,
      placeholder: isLoading ? 'Carregando...' : emptyLabel,
      selectedPrefix: '$label: ',
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      fieldColor: Colors.white,
      menuColor: const Color(0xFFFFFEFB),
      border: Border.all(color: const Color(0xFFD4D9D1)),
      leading: Icon(icon, size: 17, color: MyColors.colorPrimary),
      onChanged: onChanged,
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0x14C45C4A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x33C45C4A)),
      ),
      child: Row(
        children: [
          const Icon(
            LucideIcons.alertTriangle,
            size: 18,
            color: Color(0xFFC45C4A),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFFC45C4A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsStrip extends StatelessWidget {
  const _QuickActionsStrip({required this.items, required this.onTap});

  final List<AppMenuEntity> items;
  final ValueChanged<AppMenuEntity> onTap;

  static const _colors = [
    MyColors.colorPrimary,
    Color(0xFFC45C4A),
    Color(0xFF087F72),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: const BoxDecoration(
        color: Color(0xFFFAF9F5),
        border: Border(top: BorderSide(color: Color(0xFFD9DDD3))),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const gap = 10.0;
          if (constraints.maxWidth >= 900 && items.length <= 3) {
            return Row(
              children: [
                for (var index = 0; index < items.length; index++) ...[
                  if (index > 0) const SizedBox(width: gap),
                  Expanded(
                    child: SizedBox(
                      height: 64,
                      child: _QuickActionCard(
                        item: items[index],
                        color: _colors[index % _colors.length],
                        onTap: () => onTap(items[index]),
                      ),
                    ),
                  ),
                ],
              ],
            );
          }
          final cardWidth = constraints.maxWidth < 420
              ? constraints.maxWidth * .78
              : 280.0;
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var index = 0; index < items.length; index++) ...[
                  if (index > 0) const SizedBox(width: gap),
                  SizedBox(
                    width: cardWidth,
                    height: 64,
                    child: _QuickActionCard(
                      item: items[index],
                      color: _colors[index % _colors.length],
                      onTap: () => onTap(items[index]),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.item,
    required this.color,
    required this.onTap,
  });

  final AppMenuEntity item;
  final Color color;
  final VoidCallback onTap;

  String get _description {
    final description = (item.description ?? '').trim();
    if (description.isNotEmpty) return description;
    return item.children.map((child) => child.name).take(3).join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(11),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              MenuIcon.maybe(item: item, size: 21, color: Colors.white) ??
                  const Icon(LucideIcons.plus, size: 21, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    if (_description.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        _description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: .82),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                LucideIcons.chevronRight,
                size: 18,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TasksSummary extends StatelessWidget {
  const _TasksSummary({
    required this.pending,
    required this.overdue,
    required this.urgent,
  });

  final int pending;
  final int overdue;
  final int urgent;

  int get _total => pending + overdue + urgent;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Column(
        children: [
          Row(
            children: [
              _IconBox(icon: LucideIcons.clipboardList),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Tarefas',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF313131),
                  ),
                ),
              ),
              Text(
                '$_total no total',
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8A8A8A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: SizedBox(
              height: 6,
              child: Row(
                children: [
                  if (pending > 0)
                    Expanded(
                      flex: pending,
                      child: const ColoredBox(color: MyColors.colorPrimary),
                    ),
                  if (overdue > 0)
                    Expanded(
                      flex: overdue,
                      child: const ColoredBox(color: Color(0xFFC45C4A)),
                    ),
                  if (urgent > 0)
                    Expanded(
                      flex: urgent,
                      child: const ColoredBox(color: Color(0xFFD9762B)),
                    ),
                  if (_total == 0)
                    const Expanded(child: ColoredBox(color: Color(0xFFE8E4D9))),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _TaskStat(
                  value: pending,
                  label: 'Pendentes',
                  color: MyColors.colorPrimary,
                  background: const Color(0x1400823A),
                  icon: LucideIcons.clock,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _TaskStat(
                  value: overdue,
                  label: 'Vencidas',
                  color: const Color(0xFFC45C4A),
                  background: const Color(0x14C45C4A),
                  icon: LucideIcons.alertTriangle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _TaskStat(
                  value: urgent,
                  label: 'Urgentes',
                  color: const Color(0xFFD9762B),
                  background: const Color(0x14D9762B),
                  icon: LucideIcons.flame,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TaskStat extends StatelessWidget {
  const _TaskStat({
    required this.value,
    required this.label,
    required this.color,
    required this.background,
    required this.icon,
  });

  final int value;
  final String label;
  final Color color;
  final Color background;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 13),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              '$value $label',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardMetric {
  const _DashboardMetric({
    required this.title,
    required this.value,
    required this.subtitle,
    this.hint,
  });

  final String title;
  final String value;
  final String subtitle;
  final String? hint;
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.metric});

  final _DashboardMetric metric;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      minHeight: 116,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            metric.title.toUpperCase(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: .3,
              color: Color(0xFF6B6B6B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            metric.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 23,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1F3D2A),
              height: 1,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            metric.subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: MyColors.colorPrimary,
            ),
          ),
          if ((metric.hint ?? '').isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(
              metric.hint!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Color(0xFF8A8A8A),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({required this.child, this.minHeight});

  final Widget child;
  final double? minHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: minHeight ?? 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF9F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD9DDD3)),
      ),
      child: child,
    );
  }
}

class _IconBox extends StatelessWidget {
  const _IconBox({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: const Color(0x1400823A),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 17, color: MyColors.colorPrimary),
    );
  }
}

class _DashboardActionsDialog extends StatelessWidget {
  const _DashboardActionsDialog({
    required this.title,
    required this.items,
    required this.onOpen,
    this.description,
  });

  final String title;
  final String? description;
  final List<AppMenuEntity> items;
  final ValueChanged<AppMenuEntity> onOpen;

  @override
  Widget build(BuildContext context) {
    return WebDialogFrame(
      title: title,
      width: 680,
      maxHeight: 680,
      scrollableBody: false,
      bodyPadding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if ((description ?? '').trim().isNotEmpty) ...[
            Text(
              description!.trim(),
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF7A7A7A),
              ),
            ),
            const SizedBox(height: 14),
          ],
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text(
                  'Nenhuma ação disponível.',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    color: Color(0xFF8A8A8A),
                  ),
                ),
              ),
            )
          else
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (var index = 0; index < items.length; index++) ...[
                    if (index > 0) const SizedBox(height: 8),
                    _DashboardActionTile(
                      item: items[index],
                      onOpen: onOpen,
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _DashboardActionTile extends StatelessWidget {
  const _DashboardActionTile({required this.item, required this.onOpen});

  final AppMenuEntity item;
  final ValueChanged<AppMenuEntity> onOpen;

  @override
  Widget build(BuildContext context) {
    final icon = MenuIcon.maybe(
      item: item,
      size: 19,
      color: MyColors.colorPrimary,
    );
    if (item.children.isNotEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFAF9F5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE1E2DC)),
        ),
        child: ExpansionTile(
          shape: const RoundedRectangleBorder(),
          collapsedShape: const RoundedRectangleBorder(),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          leading: icon,
          title: Text(
            item.name,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF313131),
            ),
          ),
          subtitle: (item.description ?? '').trim().isEmpty
              ? null
              : Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    item.description!.trim(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 11,
                      height: 1.35,
                      color: Color(0xFF858585),
                    ),
                  ),
                ),
          children: [
            for (var index = 0; index < item.children.length; index++) ...[
              if (index > 0) const SizedBox(height: 6),
              _DashboardActionTile(item: item.children[index], onOpen: onOpen),
            ],
          ],
        ),
      );
    }
    return Material(
      color: const Color(0xFFFAF9F5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE1E2DC)),
      ),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        minVerticalPadding: 12,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
        leading: icon,
        title: Text(
          item.name,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF313131),
          ),
        ),
        subtitle: (item.description ?? '').trim().isEmpty
            ? null
            : Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  item.description!.trim(),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 11,
                    height: 1.35,
                    color: Color(0xFF858585),
                  ),
                ),
              ),
        trailing: const Icon(Icons.chevron_right_rounded, size: 20),
        onTap: () => onOpen(item),
      ),
    );
  }
}

class _PeriodRange {
  const _PeriodRange({required this.start, required this.end});

  final DateTime start;
  final DateTime end;
}

class _PeriodDialog extends StatefulWidget {
  const _PeriodDialog({required this.start, required this.end});

  final DateTime start;
  final DateTime end;

  @override
  State<_PeriodDialog> createState() => _PeriodDialogState();
}

class _PeriodDialogState extends State<_PeriodDialog> {
  late DateTime _start;
  late DateTime _end;

  @override
  void initState() {
    super.initState();
    _start = DateTime(widget.start.year, widget.start.month, widget.start.day);
    _end = DateTime(widget.end.year, widget.end.month, widget.end.day);
  }

  Future<void> _pick(bool isStart) async {
    final now = DateTime.now();
    final current = isStart ? _start : _end;
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 2, 12, 31),
      helpText: isStart ? 'Data inicial' : 'Data final',
      cancelText: 'Cancelar',
      confirmText: 'Ok',
    );
    if (picked == null || !mounted) return;
    setState(() {
      final day = DateTime(picked.year, picked.month, picked.day);
      if (isStart) {
        _start = day;
      } else {
        _end = day;
      }
    });
  }

  String _label(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Período'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PeriodDateTile(
              label: 'Data inicial',
              value: _label(_start),
              onTap: () => _pick(true),
            ),
            const SizedBox(height: 12),
            _PeriodDateTile(
              label: 'Data final',
              value: _label(_end),
              onTap: () => _pick(false),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            var start = _start;
            var end = _end;
            if (end.isBefore(start)) {
              final swap = start;
              start = end;
              end = swap;
            }
            Navigator.pop(context, _PeriodRange(start: start, end: end));
          },
          style: FilledButton.styleFrom(backgroundColor: MyColors.colorPrimary),
          child: const Text('Filtrar'),
        ),
      ],
    );
  }
}

class _PeriodDateTile extends StatelessWidget {
  const _PeriodDateTile({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF4F4F4),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              const Icon(
                LucideIcons.calendar,
                size: 18,
                color: MyColors.colorPrimary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 11,
                        color: Color(0xFF8A8A8A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
