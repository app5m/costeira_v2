import 'dart:math' as math;

import 'package:costeira/features/pastagem_nutricao_suplemento/domain/entities/manejo.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/presentation/controllers/get_manejo_charts_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class GraficosManejo extends StatefulWidget {
  const GraficosManejo({super.key});

  @override
  State<GraficosManejo> createState() => _GraficosManejoState();
}

class _GraficosManejoState extends State<GraficosManejo> {
  late final GetManejoChartsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Modular.get<GetManejoChartsController>()..addListener(_sync);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _controller.removeListener(_sync);
    super.dispose();
  }

  void _sync() {
    if (mounted) setState(() {});
  }

  Future<void> _load() async {
    try {
      await _controller.load();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _controller.errorMessage ??
                'Nao foi possivel carregar os graficos.',
          ),
        ),
      );
    }
  }

  Future<void> _previousMonth() async {
    try {
      await _controller.previousMonth();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _controller.errorMessage ??
                'Nao foi possivel carregar os graficos.',
          ),
        ),
      );
    }
  }

  Future<void> _nextMonth() async {
    try {
      await _controller.nextMonth();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _controller.errorMessage ??
                'Nao foi possivel carregar os graficos.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.isLoading && _controller.charts == null) {
      return const Expanded(child: Center(child: CircularProgressIndicator()));
    }

    final charts = _controller.charts ?? ManejoChartsEntity.empty;
    final porPotreiro = charts.manejosPorPotreiro
        .map(
          (item) => _ChartPoint(
            label: item.potreiroNome,
            value: item.quantidade,
            color: _colorFor(item.potreiroNome),
          ),
        )
        .toList(growable: false);
    final porTipo = charts.manejosTipoPotreiroMes
        .map(
          (item) => _ChartPoint(
            label: item.tipoManejo,
            subLabel: item.potreiroNome,
            value: item.quantidade,
            color: _colorFor(item.tipoManejo),
          ),
        )
        .toList(growable: false);

    return Expanded(
      child: RefreshIndicator(
        onRefresh: _load,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            children: [
              _MonthSelector(
                label: _formatMonth(_controller.selectedMonth),
                onPrevious: _controller.isLoading ? null : _previousMonth,
                onNext: _controller.isLoading ? null : _nextMonth,
              ),
              const SizedBox(height: 16),
              _SummaryCard(points: porTipo, fallbackPoints: porPotreiro),
              const SizedBox(height: 16),
              _HorizontalBarChartCard(
                title: 'Manejo por potreiro',
                points: porPotreiro,
              ),
              const SizedBox(height: 16),
              _VerticalBarChartCard(
                title: 'Tipos de manejo no mes',
                points: porTipo,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatMonth(DateTime date) {
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
    return '${months[date.month - 1]} ${date.year}';
  }
}

class _MonthSelector extends StatelessWidget {
  const _MonthSelector({
    required this.label,
    required this.onPrevious,
    required this.onNext,
  });

  final String label;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0xFFEBEBEB)),
          borderRadius: BorderRadius.circular(8),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 24,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: onPrevious,
            child: const Icon(Icons.arrow_back_rounded),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF8C8C8C),
              fontSize: 14,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w500,
            ),
          ),
          InkWell(
            onTap: onNext,
            child: const Icon(Icons.arrow_forward_rounded),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.points, required this.fallbackPoints});

  final List<_ChartPoint> points;
  final List<_ChartPoint> fallbackPoints;

  @override
  Widget build(BuildContext context) {
    final displayPoints = points.isEmpty ? fallbackPoints : points;
    final total = displayPoints.fold<double>(
      0,
      (sum, item) => sum + item.value,
    );

    return _ChartCard(
      title: 'Resumo de areas manejadas',
      child: displayPoints.isEmpty
          ? const _EmptyChartText()
          : Column(
              children: [
                SizedBox(
                  height: 150,
                  child: CustomPaint(
                    painter: _DonutPainter(points: displayPoints),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatDecimal(total),
                            style: const TextStyle(
                              color: Color(0xFF313131),
                              fontSize: 24,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Text(
                            'manejos',
                            style: TextStyle(
                              color: Color(0xFF8C8C8C),
                              fontSize: 12,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _Legend(points: displayPoints),
              ],
            ),
    );
  }
}

class _HorizontalBarChartCard extends StatelessWidget {
  const _HorizontalBarChartCard({required this.title, required this.points});

  final String title;
  final List<_ChartPoint> points;

  @override
  Widget build(BuildContext context) {
    final maxValue = points.fold<double>(
      0,
      (max, item) => math.max(max, item.value),
    );

    return _ChartCard(
      title: title,
      child: points.isEmpty
          ? const _EmptyChartText()
          : Column(
              children: points.map((point) {
                final factor = maxValue <= 0 ? 0.0 : point.value / maxValue;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 92,
                        child: Text(
                          _shortLabel(point.label, max: 14),
                          style: const TextStyle(
                            color: Color(0xFF8C8C8C),
                            fontSize: 12,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: factor,
                            minHeight: 18,
                            backgroundColor: const Color(0xFFEDEDED),
                            valueColor: AlwaysStoppedAnimation(point.color),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 32,
                        child: Text(
                          _formatDecimal(point.value),
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                            color: Color(0xFF313131),
                            fontSize: 12,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }
}

class _VerticalBarChartCard extends StatelessWidget {
  const _VerticalBarChartCard({required this.title, required this.points});

  final String title;
  final List<_ChartPoint> points;

  @override
  Widget build(BuildContext context) {
    return _ChartCard(
      title: title,
      child: points.isEmpty
          ? const _EmptyChartText()
          : Column(
              children: [
                SizedBox(
                  height: 240,
                  child: CustomPaint(
                    painter: _BarChartPainter(points: points),
                    child: const SizedBox.expand(),
                  ),
                ),
                const SizedBox(height: 12),
                _Legend(points: points),
              ],
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
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0xFFEBEBEB)),
          borderRadius: BorderRadius.circular(16),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 24,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF313131),
              fontSize: 14,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.points});

  final List<_ChartPoint> points;

  @override
  Widget build(BuildContext context) {
    final unique = <String, _ChartPoint>{};
    for (final point in points) {
      unique[point.label] = point;
    }

    return Wrap(
      spacing: 16,
      runSpacing: 10,
      children: unique.values.map((point) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: point.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _shortLabel(point.label, max: 18),
              style: const TextStyle(
                color: Color(0xFF8C8C8C),
                fontSize: 12,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

class _EmptyChartText extends StatelessWidget {
  const _EmptyChartText();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Text(
          'Sem dados para exibir neste periodo.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF8C8C8C),
            fontSize: 12,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({required this.points});

  final List<_ChartPoint> points;

  @override
  void paint(Canvas canvas, Size size) {
    final total = points.fold<double>(0, (sum, point) => sum + point.value);
    if (total <= 0) return;

    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: math.min(size.width, size.height) / 2 - 8,
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 24;
    var start = -math.pi / 2;

    for (final point in points) {
      final sweep = (point.value / total) * math.pi * 2;
      paint.color = point.color;
      canvas.drawArc(rect, start, sweep, false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.points != points;
  }
}

class _BarChartPainter extends CustomPainter {
  _BarChartPainter({required this.points});

  final List<_ChartPoint> points;

  @override
  void paint(Canvas canvas, Size size) {
    const left = 38.0;
    const bottom = 44.0;
    const top = 12.0;
    const right = 10.0;
    final chart = Rect.fromLTRB(
      left,
      top,
      size.width - right,
      size.height - bottom,
    );
    final maxValue = _niceMax(
      points.map((point) => point.value).fold(0, math.max),
    );
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    final gridPaint = Paint()
      ..color = const Color(0xFFEDEDED)
      ..strokeWidth = 1;

    for (var i = 0; i <= 4; i++) {
      final y = chart.top + (chart.height / 4) * i;
      canvas.drawLine(Offset(chart.left, y), Offset(chart.right, y), gridPaint);
      final value = maxValue - (maxValue / 4) * i;
      _drawText(textPainter, canvas, _formatDecimal(value), Offset(0, y - 8));
    }

    final slot = chart.width / points.length;
    final barWidth = math.min(46.0, slot * 0.45);
    for (var i = 0; i < points.length; i++) {
      final height = (points[i].value / maxValue) * chart.height;
      final x = chart.left + slot * i + (slot - barWidth) / 2;
      final rect = RRect.fromRectAndCorners(
        Rect.fromLTWH(x, chart.bottom - height, barWidth, height),
        topLeft: const Radius.circular(8),
        topRight: const Radius.circular(8),
      );
      canvas.drawRRect(rect, Paint()..color = points[i].color);
      _drawText(
        textPainter,
        canvas,
        _shortLabel(points[i].label, max: 8),
        Offset(x - 4, chart.bottom + 12),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) {
    return oldDelegate.points != points;
  }
}

class _ChartPoint {
  const _ChartPoint({
    required this.label,
    required this.value,
    required this.color,
    this.subLabel,
  });

  final String label;
  final String? subLabel;
  final double value;
  final Color color;
}

Color _colorFor(String value) {
  const colors = [
    Color(0xFF008C42),
    Color(0xFF0A4E86),
    Color(0xFFA21C16),
    Color(0xFF9A6B7F),
    Color(0xFFCC8A00),
    Color(0xFF4D7C0F),
  ];
  final index = value.codeUnits.fold<int>(0, (sum, code) => sum + code).abs();
  return colors[index % colors.length];
}

double _niceMax(double value) {
  if (value <= 0) return 10;
  final padded = value * 1.2;
  if (padded <= 2) return 2;
  if (padded <= 10) return 10;
  if (padded <= 50) return 50;
  if (padded <= 100) return 100;
  return (padded / 50).ceil() * 50;
}

void _drawText(TextPainter painter, Canvas canvas, String text, Offset offset) {
  painter.text = TextSpan(
    text: text,
    style: const TextStyle(
      color: Color(0xFFA1A1A1),
      fontSize: 12,
      fontFamily: 'Montserrat',
      fontWeight: FontWeight.w500,
    ),
  );
  painter.layout(maxWidth: 80);
  painter.paint(canvas, offset);
}

String _formatDecimal(double value) {
  if (value == value.truncateToDouble()) return value.toStringAsFixed(0);
  return value.toStringAsFixed(2).replaceAll('.', ',');
}

String _shortLabel(String value, {int max = 10}) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return '-';
  if (trimmed.length <= max) return trimmed;
  return '${trimmed.substring(0, max)}...';
}
