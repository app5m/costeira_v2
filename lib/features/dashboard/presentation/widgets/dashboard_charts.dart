import 'dart:math' as math;

import 'package:costeira/features/dashboard/domain/entities/dashboard_entity.dart';
import 'package:costeira/theme/colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

const _sliceColors = <Color>[
  Color(0xFF0B5C38),
  Color(0xFF1E8A55),
  Color(0xFF3CB371),
  Color(0xFF7DCFB6),
  Color(0xFFB8E6C8),
  Color(0xFFD9762B),
  Color(0xFFC45C4A),
  Color(0xFF8B4A2B),
];

class DashboardCompositionChart extends StatefulWidget {
  const DashboardCompositionChart({super.key, required this.slices});

  final List<DashboardAnimalCategoryEntity> slices;

  @override
  State<DashboardCompositionChart> createState() =>
      _DashboardCompositionChartState();
}

class _DashboardCompositionChartState extends State<DashboardCompositionChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enter;
  int? _touched;

  int get _total =>
      widget.slices.fold<int>(0, (sum, item) => sum + item.quantidade);

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
  }

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  double get _rise => Curves.easeOutCubic.transform(_enter.value);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _enter,
      builder: (context, _) => Opacity(
        opacity: 0.25 + (0.75 * _rise),
        child: _ChartCard(
      title: 'Composição do rebanho',
      subtitle: 'Distribuição por categoria',
      child: _total == 0
          ? const _EmptyChart(label: 'Sem composição no período')
          : Column(
        children: [
          SizedBox(
            height: 220,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 3,
                    centerSpaceRadius: 58,
                    startDegreeOffset: -90,
                    pieTouchData: PieTouchData(
                      touchCallback: (event, response) {
                        if (!event.isInterestedForInteractions ||
                            response?.touchedSection == null) {
                          setState(() => _touched = null);
                          return;
                        }
                        final index =
                            response!.touchedSection!.touchedSectionIndex;
                        setState(() {
                          _touched = index < 0 ? null : index;
                        });
                      },
                    ),
                    sections: [
                      for (var i = 0; i < widget.slices.length; i++)
                        PieChartSectionData(
                          value: math.max(widget.slices[i].quantidade, 0) * _rise,
                          color: _sliceColors[i % _sliceColors.length],
                          radius: _touched == i ? 58 : 46,
                          title: '',
                        ),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${(_total * _rise).round()}',
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1F3D2A),
                      ),
                    ),
                    const Text(
                      'cabeças',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6B6B6B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var i = 0; i < widget.slices.length; i++)
                GestureDetector(
                  onTap: () =>
                      setState(() => _touched = _touched == i ? null : i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _touched == i
                          ? _sliceColors[i % _sliceColors.length].withValues(
                              alpha: 0.16,
                            )
                          : const Color(0xFFF3F1EA),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _touched == i
                            ? _sliceColors[i % _sliceColors.length]
                            : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _sliceColors[i % _sliceColors.length],
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${widget.slices[i].nome} · ${widget.slices[i].quantidade}',
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF313131),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      ),
      ),
    );
  }
}

class DashboardEvolutionChart extends StatelessWidget {
  const DashboardEvolutionChart({super.key, required this.months});

  final List<DashboardProductionMonthEntity> months;

  bool get _hasFlow => months.any((month) => month.hasFlow);

  double get _maxValue {
    var maxValue = 0.0;
    for (final month in months) {
      maxValue = math.max(maxValue, month.entradas ?? month.valor);
      maxValue = math.max(maxValue, month.saidas ?? 0);
    }
    if (maxValue <= 0) {
      return 4;
    }
    return maxValue * 1.25;
  }

  @override
  Widget build(BuildContext context) {
    final maxY = _maxValue;
    final interval = maxY / 3;
    final hasFlow = _hasFlow;
    return _ChartCard(
      title: 'Evolução do rebanho',
      subtitle: hasFlow
          ? 'Entradas e saídas no ano agrícola'
          : 'Produção no ano agrícola',
      child: months.isEmpty
          ? const _EmptyChart(label: 'Sem dados no período')
          : _Rise(
              builder: (rise) => Column(
        children: [
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                minY: 0,
                alignment: BarChartAlignment.spaceAround,
                groupsSpace: 8,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: interval,
                  getDrawingHorizontalLine: (_) =>
                      FlLine(color: const Color(0xFFE8E4D9), strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      interval: interval,
                      getTitlesWidget: (value, _) => Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontFamily: 'Montserrat',
                          color: Color(0xFF8A8A8A),
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (value, _) {
                        final index = value.toInt();
                        if (index < 0 || index >= months.length) {
                          return const SizedBox.shrink();
                        }
                        return Text(
                          months[index].label,
                          style: const TextStyle(
                            fontSize: 10,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6B6B6B),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => const Color(0xFF1F3D2A),
                    getTooltipItem: (group, _, rod, rodIndex) {
                      final month = months[group.x];
                      final label = !hasFlow
                          ? 'Produção'
                          : (rodIndex == 0 ? 'Entradas' : 'Saídas');
                      return BarTooltipItem(
                        '${month.label}\n$label ${rod.toY.toInt()}',
                        const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Montserrat',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                  ),
                ),
                barGroups: [
                  for (var i = 0; i < months.length; i++)
                    BarChartGroupData(
                      x: i,
                      barsSpace: 2,
                      barRods: [
                        BarChartRodData(
                          toY:
                              (hasFlow
                                  ? (months[i].entradas ?? 0)
                                  : months[i].valor) *
                              rise,
                          width: 7,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                          color: MyColors.colorPrimary,
                        ),
                        if (hasFlow)
                          BarChartRodData(
                            toY: (months[i].saidas ?? 0) * rise,
                            width: 7,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(6),
                            ),
                            color: const Color(0xFFC45C4A),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendDot(
                color: MyColors.colorPrimary,
                label: hasFlow ? 'Entradas' : 'Produção',
              ),
              if (hasFlow) ...[
                const SizedBox(width: 16),
                const _LegendDot(
                  color: Color(0xFFC45C4A),
                  label: 'Saídas',
                ),
              ],
            ],
          ),
        ],
      ),
            ),
    );
  }
}

class DashboardTaskSlice {
  const DashboardTaskSlice({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;
}

class DashboardTasksChart extends StatefulWidget {
  const DashboardTasksChart({
    super.key,
    required this.slices,
    required this.total,
  });

  final List<DashboardTaskSlice> slices;
  final int total;

  @override
  State<DashboardTasksChart> createState() => _DashboardTasksChartState();
}

class _DashboardTasksChartState extends State<DashboardTasksChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enter;
  int? _touched;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
  }

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  double get _rise => Curves.easeOutCubic.transform(_enter.value);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _enter,
      builder: (context, _) {
        final rise = _rise;
        return Opacity(
          opacity: 0.25 + (0.75 * rise),
          child: _ChartCard(
      title: 'Tarefas',
      subtitle: 'Pendentes · Em andamento · Concluídas',
      child: widget.slices.every((slice) => slice.value <= 0)
          ? const _EmptyChart(label: 'Sem tarefas no período')
          : Column(
        children: [
          SizedBox(
            height: 220,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 4,
                    centerSpaceRadius: 62,
                    startDegreeOffset: -90,
                    pieTouchData: PieTouchData(
                      touchCallback: (event, response) {
                        if (!event.isInterestedForInteractions ||
                            response?.touchedSection == null) {
                          setState(() => _touched = null);
                          return;
                        }
                        final index =
                            response!.touchedSection!.touchedSectionIndex;
                        setState(() {
                          _touched = index < 0 ? null : index;
                        });
                      },
                    ),
                    sections: [
                      for (var i = 0; i < widget.slices.length; i++)
                        PieChartSectionData(
                          value: widget.slices[i].value * rise,
                          color: widget.slices[i].color,
                          radius: _touched == i ? 28 : 22,
                          title: '',
                        ),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${(widget.total * rise).round()}',
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1F3D2A),
                      ),
                    ),
                    const Text(
                      'tarefas',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6B6B6B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              for (final slice in widget.slices)
                _LegendDot(
                  color: slice.color,
                  label: '${slice.label} ${slice.value.round()}',
                ),
            ],
          ),
        ],
      ),
          ),
        );
      },
    );
  }
}

class _Rise extends StatefulWidget {
  const _Rise({required this.builder});

  final Widget Function(double rise) builder;

  @override
  State<_Rise> createState() => _RiseState();
}

class _RiseState extends State<_Rise> with SingleTickerProviderStateMixin {
  late final AnimationController _enter;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
  }

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _enter,
      builder: (context, _) {
        final rise = Curves.easeOutCubic.transform(_enter.value);
        return Opacity(
          opacity: 0.25 + (0.75 * rise),
          child: widget.builder(rise),
        );
      },
    );
  }
}

class _EmptyChart extends StatelessWidget {
  const _EmptyChart({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF8A8A8A),
          ),
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E4D9)),
      ),
      child: Column(
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
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Color(0xFF8A8A8A),
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF313131),
          ),
        ),
      ],
    );
  }
}
