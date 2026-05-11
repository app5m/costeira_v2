import 'dart:math' as math;

import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/features/dashboard/domain/entities/dashboard_entity.dart';
import 'package:costeira/features/dashboard/presentation/controllers/get_dashboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final GetDashboardController _controller =
      Modular.get<GetDashboardController>();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _load() async {
    try {
      await _controller.load();
    } catch (error) {
      if (!mounted || error is ApiException) {
        return;
      }
      AppSnackBar.show(
        context: context,
        message: 'Nao foi possivel carregar o dashboard.',
        isError: true,
      );
    }
  }

  Future<void> _previousYear() async {
    try {
      await _controller.previousYear();
    } catch (_) {}
  }

  Future<void> _nextYear() async {
    try {
      await _controller.nextYear();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = _controller.isLoading;
    final error = _controller.errorMessage;
    final dashboard = _controller.dashboard;

    if (isLoading && dashboard == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null && dashboard == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(error, textAlign: TextAlign.center),
        ),
      );
    }

    final data = dashboard ?? DashboardEntity.empty;

    return RefreshIndicator(
      onRefresh: _controller.reload,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _PeriodCard(
                year: _controller.filter.dataIn.year,
                isLoading: isLoading,
                onPrevious: _previousYear,
                onNext: _nextYear,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                children: _buildMetrics(data)
                    .map((metric) => _MetricCard(metric: metric))
                    .toList(growable: false),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _ProductionCard(items: data.graficos.producaoKgMes),
                  const SizedBox(height: 16),
                  _CategoryCard(items: data.graficos.animaisCategoria),
                  const SizedBox(height: 16),
                  _GmdCard(value: data.indicadores.ganhoMedioDiario.valor),
                  const SizedBox(height: 16),
                  _TasksProgressCard(progress: data.graficos.progressoTarefas),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_DashboardMetric> _buildMetrics(DashboardEntity data) {
    final indicators = data.indicadores;
    return [
      _DashboardMetric(
        'icon/weight.svg',
        'Quilos produzidos',
        _withSuffix(indicators.quantidadeKilosProduzidos.valor, 'kg'),
      ),
      _DashboardMetric(
        'icon/weight.svg',
        'Quilos por hectare',
        _withSuffix(indicators.kilosPorHectare.valor, 'kg/ha.'),
      ),
      _DashboardMetric(
        'icon/hand-coins.svg',
        'Estoque do rebanho',
        _money(indicators.estoqueRebanhoReais.valor),
      ),
      _DashboardMetric(
        'icon/cow-light.svg',
        'Total de animais',
        '${indicators.totalAnimais} cabecas',
      ),
      _DashboardMetric(
        'icon/workflow.svg',
        'Media da fazenda',
        _withSuffix(
          indicators.mediaFazenda.valor,
          indicators.mediaFazenda.descricao ?? 'kg/ha',
        ),
      ),
      _DashboardMetric(
        'icon/cow-light.svg',
        'Mortalidade',
        _withSuffix(indicators.mortalidadePercentual.valor, '%'),
      ),
      _DashboardMetric(
        'icon/chart-area.svg',
        'Ganho medio diario',
        _withSuffix(indicators.ganhoMedioDiario.valor, 'kg/dia'),
      ),
      _DashboardMetric(
        'icon/book-check.svg',
        'Tarefas do mes',
        '${indicators.tarefasMes.concluidas}/${indicators.tarefasMes.quantidade} concluidas',
      ),
    ];
  }
}

class _PeriodCard extends StatelessWidget {
  const _PeriodCard({
    required this.year,
    required this.isLoading,
    required this.onPrevious,
    required this.onNext,
  });

  final int year;
  final bool isLoading;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return _BaseCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: isLoading ? null : onPrevious,
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset('icon/calendar.svg', width: 18, height: 18),
                const SizedBox(width: 8),
                Text(
                  '01/01/$year - 31/12/$year',
                  style: const TextStyle(
                    color: Color(0xFF313131),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: isLoading ? null : onNext,
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.metric});

  final _DashboardMetric metric;

  @override
  Widget build(BuildContext context) {
    final width = (MediaQuery.of(context).size.width - 56) / 2;

    return _BaseCard(
      width: width,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00823A), Color(0xFF00B752)],
              ),
              borderRadius: BorderRadius.circular(42.67),
            ),
            child: SvgPicture.asset(
              metric.icon,
              width: 16,
              height: 16,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            metric.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF8C8C8C),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            metric.value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF00431F),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductionCard extends StatelessWidget {
  const _ProductionCard({required this.items});

  final List<DashboardProductionMonthEntity> items;

  @override
  Widget build(BuildContext context) {
    final maxValue = items.fold<double>(
      0,
      (current, item) => math.max(current, item.valor),
    );

    return _BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle('Producao kg/mes'),
          const SizedBox(height: 16),
          if (items.isEmpty)
            const _EmptyText('Nenhuma producao registrada no periodo.')
          else
            SizedBox(
              height: 160,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: items
                    .map((item) {
                      final percent = maxValue <= 0
                          ? 0.0
                          : item.valor / maxValue;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: FractionallySizedBox(
                                    heightFactor: percent.clamp(0.05, 1),
                                    child: Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF00823A),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF8C8C8C),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    })
                    .toList(growable: false),
              ),
            ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.items});

  final List<DashboardAnimalCategoryEntity> items;

  @override
  Widget build(BuildContext context) {
    final visibleItems = items.where((item) => item.quantidade > 0).toList();
    final data = visibleItems.isEmpty ? items.take(4).toList() : visibleItems;
    final total = data.fold<int>(0, (sum, item) => sum + item.quantidade);

    return _BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle('Categorias do rebanho'),
          const SizedBox(height: 18),
          if (data.isEmpty)
            const _EmptyText('Nenhuma categoria encontrada.')
          else ...[
            Center(
              child: SizedBox(
                width: 180,
                height: 180,
                child: CustomPaint(
                  painter: _DonutPainter(items: data),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Rebanho',
                          style: TextStyle(
                            color: Color(0xFF5C5C5C),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$total animais',
                          style: const TextStyle(
                            color: Color(0xFF8C8C8C),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 18,
              runSpacing: 12,
              children: List.generate(data.length, (index) {
                final item = data[index];
                return SizedBox(
                  width: (MediaQuery.of(context).size.width - 96) / 2,
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _chartColor(index),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${item.nome} (${item.percentual}%)',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF8C8C8C),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ],
      ),
    );
  }
}

class _GmdCard extends StatelessWidget {
  const _GmdCard({required this.value});

  final String? value;

  @override
  Widget build(BuildContext context) {
    return _BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle('GMD'),
          const SizedBox(height: 18),
          SizedBox(
            height: 190,
            width: double.infinity,
            child: CustomPaint(
              painter: _LineChartPainter(value: _parseDecimal(value)),
              child: const Padding(
                padding: EdgeInsets.only(left: 32, bottom: 18),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _AxisLabel('Jan'),
                      _AxisLabel('Fev'),
                      _AxisLabel('Mar'),
                      _AxisLabel('Abr'),
                      _AxisLabel('Mai'),
                      _AxisLabel('Jun'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TasksProgressCard extends StatelessWidget {
  const _TasksProgressCard({required this.progress});

  final DashboardTasksProgressEntity progress;

  @override
  Widget build(BuildContext context) {
    final percent = _parsePercent(progress.percentual);

    return _BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle('Progresso das tarefas'),
          const SizedBox(height: 18),
          SizedBox(
            height: 160,
            width: double.infinity,
            child: CustomPaint(
              painter: _GaugePainter(percent: percent),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 44),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${progress.percentual}%',
                        style: const TextStyle(
                          color: Color(0xFF5C5C5C),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${progress.concluidas} de ${progress.total} tarefas',
                        style: const TextStyle(
                          color: Color(0xFF8C8C8C),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '0%',
                style: TextStyle(
                  color: Color(0xFF8C8C8C),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Text(
                '100%',
                style: TextStyle(
                  color: Color(0xFF8C8C8C),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AxisLabel extends StatelessWidget {
  const _AxisLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFFB0B0B0),
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  const _DonutPainter({required this.items});

  final List<DashboardAnimalCategoryEntity> items;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = 22.0;
    final rect = Offset.zero & size;
    final insetRect = rect.deflate(stroke / 2);
    final total = items.fold<double>(
      0,
      (sum, item) => sum + math.max(item.quantidade, 0),
    );

    var start = -math.pi / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    if (total <= 0) {
      final sweep = (math.pi * 2) / math.max(items.length, 1);
      for (var i = 0; i < items.length; i++) {
        paint.color = _chartColor(i);
        canvas.drawArc(insetRect, start, sweep * 0.82, false, paint);
        start += sweep;
      }
      return;
    }

    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      if (item.quantidade <= 0) {
        continue;
      }
      final sweep = (item.quantidade / total) * math.pi * 2;
      paint.color = _chartColor(i);
      canvas.drawArc(insetRect, start, math.max(sweep - 0.04, 0), false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.items != items;
  }
}

class _LineChartPainter extends CustomPainter {
  const _LineChartPainter({required this.value});

  final double value;

  @override
  void paint(Canvas canvas, Size size) {
    const left = 32.0;
    const bottom = 24.0;
    final chart = Rect.fromLTWH(0, 0, size.width, size.height - bottom);
    final gridPaint = Paint()
      ..color = const Color(0xFFEDEDED)
      ..strokeWidth = 1;
    final labelPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
    );

    for (var i = 0; i <= 4; i++) {
      final y = chart.top + (chart.height / 4) * i;
      canvas.drawLine(Offset(left, y), Offset(size.width, y), gridPaint);
      final label = (2 - (i * 0.5)).toStringAsFixed(1).replaceAll('.', ',');
      labelPainter.text = TextSpan(
        text: label,
        style: const TextStyle(color: Color(0xFFB0B0B0), fontSize: 12),
      );
      labelPainter.layout(minWidth: 0, maxWidth: 28);
      labelPainter.paint(canvas, Offset(0, y - 8));
    }

    for (var i = 0; i < 6; i++) {
      final x = left + ((size.width - left) / 5) * i;
      canvas.drawLine(Offset(x, chart.top), Offset(x, chart.bottom), gridPaint);
    }

    final base = value <= 0 ? 1.0 : value.clamp(0.2, 2.0);
    final points = List.generate(6, (index) {
      final wave = math.sin(index * 1.5) * 0.12;
      final pointValue = (base + wave).clamp(0, 2).toDouble();
      final x = left + ((size.width - left) / 5) * index;
      final y = chart.bottom - (pointValue / 2) * chart.height;
      return Offset(x, y);
    });

    final fillPath = Path()..moveTo(points.first.dx, chart.bottom);
    for (final point in points) {
      fillPath.lineTo(point.dx, point.dy);
    }
    fillPath
      ..lineTo(points.last.dx, chart.bottom)
      ..close();

    final fillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0x6646D69A), Color(0x0046D69A)],
      ).createShader(chart);
    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = const Color(0xFF00823A)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final previous = points[i - 1];
      final current = points[i];
      final midX = (previous.dx + current.dx) / 2;
      path.cubicTo(midX, previous.dy, midX, current.dy, current.dx, current.dy);
    }
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.value != value;
  }
}

class _GaugePainter extends CustomPainter {
  const _GaugePainter({required this.percent});

  final double percent;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = 28.0;
    final rect = Rect.fromLTWH(
      stroke / 2,
      stroke / 2,
      size.width - stroke,
      (size.height * 2) - stroke,
    );
    final background = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = const Color(0xFFE4E5EC);
    final foreground = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = const Color(0xFF00823A);

    canvas.drawArc(rect, math.pi, math.pi, false, background);
    canvas.drawArc(
      rect,
      math.pi,
      math.pi * (percent / 100).clamp(0, 1),
      false,
      foreground,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return oldDelegate.percent != percent;
  }
}

class _BaseCard extends StatelessWidget {
  const _BaseCard({
    required this.child,
    this.width,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final double? width;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFEBEBEB)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 24,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _CardTitle extends StatelessWidget {
  const _CardTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF313131),
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _EmptyText extends StatelessWidget {
  const _EmptyText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF8C8C8C),
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _DashboardMetric {
  const _DashboardMetric(this.icon, this.title, this.value);

  final String icon;
  final String title;
  final String value;
}

String _withSuffix(String? value, String suffix) {
  final normalized = _displayValue(value);
  if (normalized == '-') {
    return normalized;
  }
  return '$normalized $suffix';
}

String _money(String? value) {
  final normalized = _displayValue(value);
  if (normalized == '-') {
    return normalized;
  }
  return 'R\$ $normalized';
}

String _displayValue(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return '-';
  }
  return trimmed;
}

double _parsePercent(String value) {
  return double.tryParse(value.replaceAll('.', '').replaceAll(',', '.')) ?? 0;
}

double _parseDecimal(String? value) {
  return double.tryParse(
        value?.replaceAll('.', '').replaceAll(',', '.') ?? '',
      ) ??
      0;
}

Color _chartColor(int index) {
  const colors = [
    Color(0xFF00823A),
    Color(0xFFFF944D),
    Color(0xFF46D69A),
    Color(0xFFFFC247),
    Color(0xFF00B752),
    Color(0xFF394762),
  ];
  return colors[index % colors.length];
}
