import 'dart:math' as math;

import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/features/insumos/domain/entities/insumos.dart';
import 'package:costeira/features/insumos/domain/usecases/get_insumo_charts_usecase.dart';
import 'package:costeira/features/insumos/presentation/controllers/get_insumo_charts_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class GraficosInsumo extends StatefulWidget {
  const GraficosInsumo({super.key});

  @override
  State<GraficosInsumo> createState() => _GraficosInsumoState();
}

class _GraficosInsumoState extends State<GraficosInsumo> {
  late final GetInsumoChartsController _controller;

  static const _colors = [
    Color(0xFF008C42),
    Color(0xFFFF9442),
    Color(0xFF43D09A),
    Color(0xFFFFC443),
    Color(0xFF147AD6),
    Color(0xFF8E59FF),
  ];

  @override
  void initState() {
    super.initState();
    _controller = GetInsumoChartsController(
      Modular.get<GetInsumoChartsUsecase>(),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCharts());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadCharts() async {
    try {
      await _controller.load();
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.show(
        context: context,
        message:
            _controller.errorMessage ??
            'Nao foi possivel carregar os graficos.',
        isError: true,
      );
    }
  }

  Future<void> _previousMonth() async {
    try {
      await _controller.previousMonth();
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.show(
        context: context,
        message:
            _controller.errorMessage ??
            'Nao foi possivel carregar os graficos.',
        isError: true,
      );
    }
  }

  Future<void> _nextMonth() async {
    try {
      await _controller.nextMonth();
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.show(
        context: context,
        message:
            _controller.errorMessage ??
            'Nao foi possivel carregar os graficos.',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AnimatedBuilder(
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
                      child: Text(
                        _controller.errorMessage!,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          final charts = _controller.charts ?? InsumoChartsEntity.empty;
          return RefreshIndicator(
            onRefresh: _loadCharts,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  _MonthSelector(
                    label: _formatMonth(_controller.selectedMonth),
                    onPrevious: _controller.isLoading ? null : _previousMonth,
                    onNext: _controller.isLoading ? null : _nextMonth,
                  ),
                  const SizedBox(height: 16),
                  _DistributionCard(
                    title: 'Estoques',
                    items: charts.quantidadePorTipo,
                    colors: _colors,
                  ),
                  const SizedBox(height: 16),
                  _LineChartCard(
                    title: 'Consumo mensal',
                    points: charts.evolucaoMesAMes,
                  ),
                  const SizedBox(height: 16),
                  _BarChartCard(
                    title: 'Evolução do valor em estoque',
                    items: charts.quantidadePorTipo,
                    colors: _colors,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
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
      width: MediaQuery.of(context).size.width - 40,
      padding: const EdgeInsets.all(16),
      clipBehavior: Clip.antiAlias,
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
              height: 1.50,
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
              children: [
                SizedBox(
                  height: 280,
                  child: Center(
                    child: SizedBox(
                      width: 210,
                      height: 210,
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
                  runSpacing: 16,
                  children: List.generate(visibleItems.length, (index) {
                    final item = visibleItems[index];
                    final color = colors[index % colors.length];
                    return SizedBox(
                      width: (MediaQuery.of(context).size.width - 100) / 2,
                      child: Row(
                        children: [
                          Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '${_titleCase(item.tipoInsumo)} (${_formatDecimal(item.percentual)}%)',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF666666),
                                fontSize: 13,
                                fontFamily: 'Montserrat',
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
              height: 260,
              child: CustomPaint(
                painter: _LineChartPainter(points: points),
                child: const SizedBox.expand(),
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
              height: 260,
              child: CustomPaint(
                painter: _BarChartPainter(items: visibleItems, colors: colors),
                child: const SizedBox.expand(),
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
      width: MediaQuery.of(context).size.width - 40,
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

class _EmptyChartText extends StatelessWidget {
  const _EmptyChartText();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Text(
          'Sem dados para exibir neste período.',
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
      points.map((point) => point.value).fold(0, math.max),
    );

    final gridPaint = Paint()
      ..color = const Color(0xFFEDEDED)
      ..strokeWidth = 1;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (var i = 0; i <= 4; i++) {
      final y = chart.top + (chart.height / 4) * i;
      canvas.drawLine(Offset(chart.left, y), Offset(chart.right, y), gridPaint);
      final value = maxValue - (maxValue / 4) * i;
      _drawText(textPainter, canvas, _formatDecimal(value), Offset(0, y - 8));
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
      _drawText(
        textPainter,
        canvas,
        _shortLabel(points[i].label),
        Offset(x - 14, chart.bottom + 12),
      );
    }
  }

  void _drawPoint(Canvas canvas, Offset offset) {
    canvas.drawCircle(
      offset,
      8,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      offset,
      6,
      Paint()
        ..color = const Color(0xFF147AD6)
        ..style = PaintingStyle.fill,
    );
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
      items.map((item) => item.quantidade).fold(0, math.max),
    );
    final gridPaint = Paint()
      ..color = const Color(0xFFEDEDED)
      ..strokeWidth = 1;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (var i = 0; i <= 4; i++) {
      final y = chart.top + (chart.height / 4) * i;
      canvas.drawLine(Offset(chart.left, y), Offset(chart.right, y), gridPaint);
      final value = maxValue - (maxValue / 4) * i;
      _drawText(textPainter, canvas, _formatDecimal(value), Offset(0, y - 8));
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
      _drawText(
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
