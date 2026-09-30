import 'package:costeira/core/menus/app_menus_controller.dart';
import 'package:costeira/core/offline/cache/form_dependencies_cache_service.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/features/dashboard/domain/entities/dashboard_entity.dart';
import 'package:costeira/features/dashboard/domain/entities/dashboard_filter_entity.dart';
import 'package:costeira/features/dashboard/presentation/controllers/get_dashboard_controller.dart';
import 'package:costeira/features/dashboard/presentation/widgets/dashboard_charts.dart';
import 'package:costeira/features/fazendas/domain/entities/fazenda_entity.dart';
import 'package:costeira/features/fazendas/domain/entities/fazenda_filter_entity.dart';
import 'package:costeira/features/fazendas/domain/usecases/get_fazendas_usecase.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:lucide_icons/lucide_icons.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late final GetDashboardController _dashboard;
  late final List<AgriculturalYearRange> _years;
  late AgriculturalYearRange _year;

  List<FazendaEntity> _farms = const [];
  int? _farmId;
  bool _loadingFarms = true;

  @override
  void initState() {
    super.initState();
    _year = AgriculturalYearRange.containing(DateTime.now());
    _years = AgriculturalYearRange.options(DateTime.now());
    _dashboard = Modular.get<GetDashboardController>();
    _dashboard.addListener(_onDashboardChanged);
    _loadFarms();
  }

  @override
  void dispose() {
    _dashboard.removeListener(_onDashboardChanged);
    _dashboard.dispose();
    super.dispose();
  }

  void _onDashboardChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  String _farmLabel(FazendaEntity farm) {
    final name = farm.nome.trim();
    if (name.isNotEmpty) {
      return name;
    }
    final fantasy = farm.nomeFantasia.trim();
    if (fantasy.isNotEmpty) {
      return fantasy;
    }
    return 'Fazenda ${farm.id}';
  }

  String get _farmName {
    if (_loadingFarms) {
      return 'Carregando...';
    }
    if (_farms.isEmpty) {
      return 'Nenhuma fazenda';
    }
    final selected = _farms.where((farm) => farm.id == _farmId);
    return _farmLabel(selected.isNotEmpty ? selected.first : _farms.first);
  }

  Future<void> _loadFarms() async {
    try {
      final user = await SessionStorage.getUserSession();
      if (user == null) {
        if (mounted) {
          setState(() => _loadingFarms = false);
        }
        return;
      }

      final result = await Modular.get<GetFazendasUsecase>()(
        FazendaFilterEntity(appUsersId: user.id),
      );
      final saved = await SessionStorage.getSelectedFarmId();
      final match = result.data.where((farm) => farm.id == saved);
      final selectedId = match.isNotEmpty
          ? match.first.id
          : (result.data.isEmpty ? null : result.data.first.id);
      if (selectedId != null) {
        await SessionStorage.saveSelectedFarmId(selectedId);
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _farms = result.data;
        _farmId = selectedId;
        _loadingFarms = false;
      });
      await _loadDashboard();
    } catch (_) {
      if (mounted) {
        setState(() => _loadingFarms = false);
      }
    }
  }

  Future<void> _loadDashboard() async {
    final farmId = _farmId;
    if (farmId == null || farmId <= 0) {
      return;
    }
    try {
      await _dashboard.load(
        filter: DashboardFilterEntity(
          appFazendasId: farmId,
          dataIn: _year.dataIn,
          dataOut: _year.dataOut,
        ),
      );
    } catch (_) {}
  }

  Future<void> _onRefresh() async {
    setState(() => _loadingFarms = true);
    await Future.wait([
      Modular.get<AppMenusController>().refresh(),
      _loadFarms(),
      Modular.get<FormDependenciesCacheService>().preloadEssentialLists(
        force: true,
      ),
    ]);
  }

  Future<void> _pickFarm() async {
    if (_loadingFarms || _farms.isEmpty) {
      return;
    }
    final selected = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 72,
                    height: 3,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E2E2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Fazenda',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                for (final farm in _farms)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      _farmLabel(farm),
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: farm.id == _farmId
                        ? const Icon(
                            LucideIcons.check,
                            color: MyColors.colorPrimary,
                            size: 18,
                          )
                        : null,
                    onTap: () => Navigator.pop(sheetContext, farm.id),
                  ),
              ],
            ),
          ),
        );
      },
    );
    if (selected == null) {
      return;
    }
    await SessionStorage.saveSelectedFarmId(selected);
    if (!mounted) {
      return;
    }
    setState(() => _farmId = selected);
    await _loadDashboard();
  }

  Future<void> _pickYear() async {
    final selected = await _pickOption(
      title: 'Ano agrícola',
      options: _years.map((item) => item.label).toList(growable: false),
      current: _year.label,
    );
    if (selected == null) {
      return;
    }
    setState(() {
      _year = _years.firstWhere((item) => item.label == selected);
    });
    await _loadDashboard();
  }

  Future<String?> _pickOption({
    required String title,
    required List<String> options,
    required String current,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 72,
                    height: 3,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E2E2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                for (final option in options)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      option,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: option == current
                        ? const Icon(
                            LucideIcons.check,
                            color: MyColors.colorPrimary,
                            size: 18,
                          )
                        : null,
                    onTap: () => Navigator.pop(sheetContext, option),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  DashboardEntity get _data => _dashboard.dashboard ?? DashboardEntity.empty;

  DashboardTasksMonthEntity get _indicators => _data.indicadores.tarefasMes;

  DashboardChartsEntity get _charts => _data.graficos;

  List<_DashboardMetric> _metrics(DashboardEntity? dashboard) {
    final data = dashboard ?? DashboardEntity.empty;
    final indicators = data.indicadores;
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
        subtitle: indicators.quantidadeKilosProduzidos.descricao ?? 'no período',
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
    return ColoredBox(
      color: const Color(0xFFF6F4EE),
      child: RefreshIndicator(
        color: MyColors.colorPrimary,
        onRefresh: _onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          children: [
            Row(
              children: [
                Expanded(
                  child: _FilterChip(
                    icon: LucideIcons.warehouse,
                    label: _farmName,
                    onTap: _pickFarm,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _FilterChip(
                    icon: LucideIcons.calendar,
                    label: _year.label,
                    onTap: _pickYear,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_dashboard.isLoading)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: LinearProgressIndicator(minHeight: 2),
              ),
            if (_dashboard.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  _dashboard.errorMessage!,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFC45C4A),
                  ),
                ),
              ),
            _TasksSummary(
              pending: _indicators.pendentes,
              overdue: _indicators.emAtraso,
              urgent: _indicators.urgentes,
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                const gap = 12.0;
                final width = (constraints.maxWidth - gap) / 2;
                final metrics = _metrics(_dashboard.dashboard);
                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: [
                    for (final metric in metrics)
                      SizedBox(
                        width: width,
                        child: _MetricCard(metric: metric),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            DashboardCompositionChart(
              slices: _charts.animaisCategoria
                  .where((item) => item.quantidade > 0)
                  .toList(growable: false),
            ),
            const SizedBox(height: 16),
            DashboardEvolutionChart(months: _charts.producaoKgMes),
            const SizedBox(height: 16),
            DashboardTasksChart(
              slices: _taskSlices(_charts.progressoTarefas),
              total: _charts.progressoTarefas.total,
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Icon(icon, size: 16, color: MyColors.colorPrimary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF313131),
                  ),
                ),
              ),
              const Icon(
                LucideIcons.chevronDown,
                size: 16,
                color: Color(0xFF8A8A8A),
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
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E4D9)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0x1400823A),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  LucideIcons.clipboardList,
                  size: 16,
                  color: MyColors.colorPrimary,
                ),
              ),
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
          const SizedBox(height: 12),
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
          const SizedBox(height: 12),
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
              const SizedBox(width: 8),
              Expanded(
                child: _TaskStat(
                  value: overdue,
                  label: 'Vencidas',
                  color: const Color(0xFFC45C4A),
                  background: const Color(0x14C45C4A),
                  icon: LucideIcons.alertTriangle,
                ),
              ),
              const SizedBox(width: 8),
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
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(height: 6),
          Text(
            '$value',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
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
    return Container(
      constraints: const BoxConstraints(minHeight: 118),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E4D9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            metric.title.toUpperCase(),
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
              color: Color(0xFF6B6B6B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            metric.value,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1F3D2A),
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            metric.subtitle,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: MyColors.colorPrimary,
            ),
          ),
          if (metric.hint != null) ...[
            const SizedBox(height: 4),
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
