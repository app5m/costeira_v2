import 'dart:math' as math;

import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/features/climate_and_rain/domain/entities/climate_charts_entity.dart';
import 'package:costeira/features/climate_and_rain/presentation/controllers/get_climate_charts_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class GraficsClimatePage extends StatefulWidget {
  const GraficsClimatePage({super.key});

  @override
  State<GraficsClimatePage> createState() => _GraficsClimatePageState();
}

class _GraficsClimatePageState extends State<GraficsClimatePage> {
  final GetClimateChartsController _controller = Modular.get<GetClimateChartsController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCharts();
    });
  }

  Future<void> _loadCharts() async {
    try {
      await _controller.load();
    } catch (_) {
      if (!mounted) {
        return;
      }
      AppSnackBar.show(
        context: context,
        message: _controller.errorMessage ?? 'Nao foi possivel carregar os graficos de clima.',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        if (_controller.isLoading && _controller.charts == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_controller.errorMessage != null && _controller.charts == null) {
          return RefreshIndicator(
            onRefresh: _loadCharts,
            child: ListView(
              children: [
                const SizedBox(height: 120),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(_controller.errorMessage!, textAlign: TextAlign.center),
                  ),
                ),
              ],
            ),
          );
        }

        final charts =
            _controller.charts ??
            const ClimateChartsEntity(
              totalChuvaAcumulada: 0,
              totalChuvaUltimoMes: 0,
              chuvaMesAMes: [],
              comparativoUltimos2Anos: [],
            );

        return RefreshIndicator(
          onRefresh: _loadCharts,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _AccumulatedRainCard(charts: charts),
                  const SizedBox(height: 16),
                  _HistoricalAverageCard(charts: charts),
                  const SizedBox(height: 16),
                  _LineChartCard(title: 'Chuva acumulada por mês', points: charts.chuvaMesAMes),
                  const SizedBox(height: 16),
                  _BarChartCard(points: _recentBars(charts.chuvaMesAMes)),
                  const SizedBox(height: 16),
                  _ComparisonChartCard(series: charts.comparativoUltimos2Anos),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<ClimateMonthlyRainPointEntity> _recentBars(List<ClimateMonthlyRainPointEntity> source) {
    if (source.isEmpty) {
      return List.generate(
        6,
        (index) => ClimateMonthlyRainPointEntity(
          label: _monthShortName(index + 1),
          value: 0,
        ),
      );
    }

    final start = math.max(0, source.length - 6);
    final sliced = source.sublist(start);
    return List.generate(sliced.length, (index) {
      return ClimateMonthlyRainPointEntity(
        label: _normalizeChartLabel(sliced[index].label, fallbackIndex: start + index),
        value: sliced[index].value,
      );
    });
  }
}

class _AccumulatedRainCard extends StatelessWidget {
  const _AccumulatedRainCard({required this.charts});

  final ClimateChartsEntity charts;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return _BaseCard(
      child: _ResponsiveMetricCard(
        title: 'Chuva acumulada',
        leading: _MetricColumn(
          value: '${_formatMm(charts.totalChuvaUltimoMes)} mm',
          label: _monthName(now.month),
        ),
        trailing: _MetricColumn(
          value: '${_formatMm(charts.totalChuvaAcumulada)} mm',
          label: now.year.toString(),
        ),
      ),
    );
  }
}

class _HistoricalAverageCard extends StatelessWidget {
  const _HistoricalAverageCard({required this.charts});

  final ClimateChartsEntity charts;

  @override
  Widget build(BuildContext context) {
    final average = _buildHistoricalAverage(charts.comparativoUltimos2Anos);
    return _BaseCard(
      child: _ResponsiveMetricCard(
        title: 'Media historica',
        leading: _MetricColumn(
          value: '${_formatMm(average.monthlyAverage)} mm',
          label: average.monthLabel,
        ),
        trailing: _MetricColumn(
          value: '${_formatMm(average.annualAverage)} mm',
          label: average.periodLabel,
        ),
      ),
    );
  }
}

class _ResponsiveMetricCard extends StatelessWidget {
  const _ResponsiveMetricCard({required this.title, required this.leading, required this.trailing});

  final String title;
  final Widget leading;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 320;

        return Column(
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
            const SizedBox(height: 18),
            if (isCompact) ...[
              leading,
              const SizedBox(height: 16),
              const Divider(height: 1, color: Color(0xFFEBEBEB)),
              const SizedBox(height: 16),
              trailing,
            ] else
              Row(
                children: [
                  Expanded(child: leading),
                  const _VerticalDivider(),
                  Expanded(child: trailing),
                ],
              ),
          ],
        );
      },
    );
  }
}

class _LineChartCard extends StatelessWidget {
  const _LineChartCard({required this.title, required this.points});

  final String title;
  final List<ClimateMonthlyRainPointEntity> points;

  @override
  Widget build(BuildContext context) {
    return _BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF313131),
              fontSize: 14,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 260,
            child: points.isEmpty
                ? const Center(child: Text('Sem dados suficientes.'))
                : _SimpleLineChart(points: points, color: const Color(0xFF147AD6)),
          ),
        ],
      ),
    );
  }
}

class _BarChartCard extends StatelessWidget {
  const _BarChartCard({required this.points});

  final List<ClimateMonthlyRainPointEntity> points;

  @override
  Widget build(BuildContext context) {
    return _BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'mm/dd',
            style: TextStyle(
              color: Color(0xFF313131),
              fontSize: 14,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(height: 220, child: _SimpleBarChart(points: points)),
        ],
      ),
    );
  }
}

class _ComparisonChartCard extends StatelessWidget {
  const _ComparisonChartCard({required this.series});

  final List<ClimateYearComparisonEntity> series;

  @override
  Widget build(BuildContext context) {
    const colors = [Color(0xFF97E0E0), Color(0xFF36A9D6), Color(0xFF124F97)];
    return _BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Comparativo entre anos',
            style: TextStyle(
              color: Color(0xFF313131),
              fontSize: 14,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 260,
            child: series.isEmpty
                ? const Center(child: Text('Sem dados suficientes.'))
                : _MultiLineChart(series: series, colors: colors),
          ),
          if (series.isNotEmpty) ...[
            const SizedBox(height: 18),
            Wrap(
              spacing: 20,
              runSpacing: 8,
              children: List.generate(series.length, (index) {
                final color = colors[index % colors.length];
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      series[index].year,
                      style: const TextStyle(
                        color: Color(0xFF6F6F6F),
                        fontSize: 12,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ],
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
      width: MediaQuery.of(context).size.width - 40,
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0xFFEBEBEB)),
          borderRadius: BorderRadius.circular(12),
        ),
        shadows: const [BoxShadow(color: Color(0x0A000000), blurRadius: 24, offset: Offset(0, 0))],
      ),
      child: child,
    );
  }
}

class _MetricColumn extends StatelessWidget {
  const _MetricColumn({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF313131),
              fontSize: 14,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF8C8C8C),
            fontSize: 12,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 52,
      color: const Color(0xFFEBEBEB),
      margin: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}

class _SimpleLineChart extends StatelessWidget {
  const _SimpleLineChart({required this.points, required this.color});

  final List<ClimateMonthlyRainPointEntity> points;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LineChartPainter(
        points: points,
        lineColors: [color],
        labels: points
            .asMap()
            .entries
            .map(
              (entry) => _normalizeChartLabel(
                entry.value.label,
                fallbackIndex: entry.key,
              ),
            )
            .toList(growable: false),
      ),
      child: Container(),
    );
  }
}

class _SimpleBarChart extends StatelessWidget {
  const _SimpleBarChart({required this.points});

  final List<ClimateMonthlyRainPointEntity> points;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BarChartPainter(points: points),
      child: Container(),
    );
  }
}

class _MultiLineChart extends StatelessWidget {
  const _MultiLineChart({required this.series, required this.colors});

  final List<ClimateYearComparisonEntity> series;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    final first = series.firstOrNull;
    final labels = (first?.points ?? const <ClimateMonthlyRainPointEntity>[])
        .asMap()
        .entries
        .map(
          (entry) => _normalizeChartLabel(
            entry.value.label,
            fallbackIndex: entry.key,
          ),
        )
        .toList(growable: false);

    return CustomPaint(
      painter: _LineChartPainter(
        points: first?.points ?? const [],
        series: series,
        lineColors: colors,
        labels: labels,
      ),
      child: Container(),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({
    required this.points,
    required this.lineColors,
    required this.labels,
    this.series,
  });

  final List<ClimateMonthlyRainPointEntity> points;
  final List<ClimateYearComparisonEntity>? series;
  final List<Color> lineColors;
  final List<String> labels;

  @override
  void paint(Canvas canvas, Size size) {
    const left = 44.0;
    const top = 12.0;
    const right = 12.0;
    const bottom = 32.0;
    final chartWidth = size.width - left - right;
    final chartHeight = size.height - top - bottom;
    if (chartWidth <= 0 || chartHeight <= 0) {
      return;
    }

    final allSeries = series ?? [ClimateYearComparisonEntity(year: '', points: points)];
    final allPoints = allSeries.expand((e) => e.points).toList(growable: false);
    final maxValue = _maxValue(allPoints);

    final axisPaint = Paint()
      ..color = const Color(0xFFEAEAEA)
      ..strokeWidth = 1;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (var i = 0; i <= 4; i++) {
      final y = top + chartHeight - (chartHeight / 4) * i;
      canvas.drawLine(Offset(left, y), Offset(size.width - right, y), axisPaint);

      final label = (maxValue / 4 * i).round().toString();
      textPainter.text = TextSpan(
        text: label,
        style: const TextStyle(color: Color(0xFFA1A1A1), fontSize: 12, fontFamily: 'Montserrat'),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(0, y - textPainter.height / 2));
    }

    for (var index = 0; index < labels.length; index++) {
      final x = labels.length == 1
          ? left + chartWidth / 2
          : left + (chartWidth / (labels.length - 1)) * index;
      textPainter.text = TextSpan(
        text: labels[index],
        style: const TextStyle(color: Color(0xFFA1A1A1), fontSize: 12, fontFamily: 'Montserrat'),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, size.height - textPainter.height),
      );
    }

    for (var seriesIndex = 0; seriesIndex < allSeries.length; seriesIndex++) {
      final data = allSeries[seriesIndex].points;
      if (data.isEmpty) {
        continue;
      }

      final color = lineColors[seriesIndex % lineColors.length];
      final linePaint = Paint()
        ..color = color
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final dotPaint = Paint()..color = color;
      final path = Path();

      for (var index = 0; index < data.length; index++) {
        final x = data.length == 1
            ? left + chartWidth / 2
            : left + (chartWidth / (data.length - 1)) * index;
        final y = top + chartHeight - ((data[index].value / maxValue) * chartHeight);
        if (index == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }

        if (allSeries.length == 1) {
          canvas.drawCircle(Offset(x, y), 6, dotPaint..style = PaintingStyle.fill);
          canvas.drawCircle(
            Offset(x, y),
            9,
            Paint()
              ..color = Colors.white
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3,
          );
        }
      }

      canvas.drawPath(path, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _BarChartPainter extends CustomPainter {
  _BarChartPainter({required this.points});

  final List<ClimateMonthlyRainPointEntity> points;

  @override
  void paint(Canvas canvas, Size size) {
    const left = 44.0;
    const top = 12.0;
    const right = 12.0;
    const bottom = 32.0;
    final chartWidth = size.width - left - right;
    final chartHeight = size.height - top - bottom;
    if (chartWidth <= 0 || chartHeight <= 0) {
      return;
    }

    final maxValue = _maxValue(points);
    final gridPaint = Paint()
      ..color = const Color(0xFFEAEAEA)
      ..strokeWidth = 1;
    final barPaint = Paint()..color = const Color(0xFF0B8F3C);
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (var i = 0; i <= 2; i++) {
      final y = top + chartHeight - (chartHeight / 2) * i;
      canvas.drawLine(Offset(left, y), Offset(size.width - right, y), gridPaint);
      final label = i == 0
          ? '1'
          : i == 1
          ? (maxValue / 2).round().toString()
          : maxValue.round().toString();
      textPainter.text = TextSpan(
        text: label,
        style: const TextStyle(color: Color(0xFFA1A1A1), fontSize: 12, fontFamily: 'Montserrat'),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(0, y - textPainter.height / 2));
    }

    final step = chartWidth / math.max(points.length, 1);
    for (var index = 0; index < points.length; index++) {
      final barHeight = (points[index].value / maxValue) * chartHeight;
      final barLeft = left + (step * index) + step * 0.3;
      final barRight = left + (step * index) + step * 0.7;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTRB(barLeft, top + chartHeight - barHeight, barRight, top + chartHeight),
        const Radius.circular(4),
      );
      canvas.drawRRect(rect, barPaint);

      textPainter.text = TextSpan(
        text: points[index].label,
        style: const TextStyle(color: Color(0xFFA1A1A1), fontSize: 12, fontFamily: 'Montserrat'),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          barLeft + ((barRight - barLeft) / 2) - textPainter.width / 2,
          size.height - textPainter.height,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _HistoricalAverageData {
  const _HistoricalAverageData({
    required this.monthlyAverage,
    required this.annualAverage,
    required this.monthLabel,
    required this.periodLabel,
  });

  final double monthlyAverage;
  final double annualAverage;
  final String monthLabel;
  final String periodLabel;
}

_HistoricalAverageData _buildHistoricalAverage(List<ClimateYearComparisonEntity> series) {
  if (series.isEmpty) {
    final now = DateTime.now();
    return _HistoricalAverageData(
      monthlyAverage: 0,
      annualAverage: 0,
      monthLabel: _monthName(now.month),
      periodLabel: 'Anual',
    );
  }

  final now = DateTime.now();
  final monthIndex = math.max(0, now.month - 1);
  final monthlyValues = <double>[];
  final annualTotals = <double>[];
  final years = <int>[];

  for (final yearSeries in series) {
    years.add(int.tryParse(yearSeries.year) ?? now.year);
    if (yearSeries.points.length > monthIndex) {
      monthlyValues.add(yearSeries.points[monthIndex].value);
    }
    annualTotals.add(yearSeries.points.fold<double>(0, (sum, item) => sum + item.value));
  }

  final monthAvg = monthlyValues.isEmpty
      ? 0
      : monthlyValues.reduce((a, b) => a + b) / monthlyValues.length;
  final annualAvg = annualTotals.isEmpty
      ? 0
      : annualTotals.reduce((a, b) => a + b) / annualTotals.length;

  years.sort();
  final periodLabel = years.isEmpty || years.first == years.last
      ? 'Anual'
      : 'Anual | ${years.first}-${years.last}';

  return _HistoricalAverageData(
    monthlyAverage: monthAvg.toDouble(),
    annualAverage: annualAvg.toDouble(),
    monthLabel: '${_monthName(now.month)} | ${years.first}-${years.last}',
    periodLabel: periodLabel,
  );
}

double _maxValue(List<ClimateMonthlyRainPointEntity> points) {
  if (points.isEmpty) {
    return 1;
  }
  final maxValue = points
      .map((e) => e.value)
      .reduce((current, next) => current > next ? current : next);
  return maxValue <= 0 ? 1 : maxValue;
}

String _formatMm(double value) {
  if (value == value.truncateToDouble()) {
    return value.toStringAsFixed(0);
  }
  return value.toStringAsFixed(1);
}

String _monthName(int month) {
  const months = [
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

  return months[month - 1];
}

String _monthShortName(int month) {
  const months = [
    'Jan',
    'Fev',
    'Mar',
    'Abr',
    'Mai',
    'Jun',
    'Jul',
    'Ago',
    'Set',
    'Out',
    'Nov',
    'Dez',
  ];

  return months[month - 1];
}

String _normalizeChartLabel(String raw, {int? fallbackIndex}) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) {
    if (fallbackIndex == null) {
      return '';
    }
    return _monthShortName((fallbackIndex % 12) + 1);
  }

  final parsedMonth = int.tryParse(trimmed);
  if (parsedMonth != null && parsedMonth >= 1 && parsedMonth <= 12) {
    return _monthShortName(parsedMonth);
  }

  final normalized = trimmed.toLowerCase();
  const aliasMap = {
    'janeiro': 'Jan',
    'jan': 'Jan',
    'fevereiro': 'Fev',
    'fev': 'Fev',
    'marco': 'Mar',
    'março': 'Mar',
    'mar': 'Mar',
    'abril': 'Abr',
    'abr': 'Abr',
    'maio': 'Mai',
    'mai': 'Mai',
    'junho': 'Jun',
    'jun': 'Jun',
    'julho': 'Jul',
    'jul': 'Jul',
    'agosto': 'Ago',
    'ago': 'Ago',
    'setembro': 'Set',
    'set': 'Set',
    'outubro': 'Out',
    'out': 'Out',
    'novembro': 'Nov',
    'nov': 'Nov',
    'dezembro': 'Dez',
    'dez': 'Dez',
  };

  return aliasMap[normalized] ?? trimmed;
}
