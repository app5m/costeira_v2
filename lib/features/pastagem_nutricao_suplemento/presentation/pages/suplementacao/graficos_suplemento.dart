import 'dart:math' as math;

import 'package:costeira/features/pastagem_nutricao_suplemento/domain/entities/suplemento.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/presentation/controllers/get_suplemento_charts_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class GraficosSuplemento extends StatefulWidget {
  const GraficosSuplemento({super.key});

  @override
  State<GraficosSuplemento> createState() => _GraficosSuplementoState();
}

class _GraficosSuplementoState extends State<GraficosSuplemento> {
  late final GetSuplementoChartsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Modular.get<GetSuplementoChartsController>()..addListener(_sync);
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
          content: Text(_controller.errorMessage ?? 'Nao foi possivel carregar os gráficos.'),
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
          content: Text(_controller.errorMessage ?? 'Nao foi possivel carregar os gráficos.'),
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
          content: Text(_controller.errorMessage ?? 'Nao foi possivel carregar os gráficos.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.isLoading && _controller.charts == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final charts = _controller.charts ?? SuplementoChartsEntity.empty;
    final comparativo = charts.comparativoPotreiroLote;
    final consumoAnimal = comparativo
        .map(
          (item) => _ChartPoint(
            label: item.loteNome.isEmpty ? item.potreiroNome : item.loteNome,
            value: _asDouble(item.consumoReal?.consumoRealAnimalDia) ?? 0,
          ),
        )
        .toList(growable: false);
    final consumoLote = comparativo
        .map((item) => _ChartPoint(label: item.potreiroNome, value: item.consumoTotal))
        .toList(growable: false);
    final mesAMes = charts.mesAMes
        .map((item) => _ChartPoint(label: item.label, value: item.value))
        .toList(growable: false);

    return RefreshIndicator(
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          children: [
            _MonthSelector(
              label: _formatMonth(_controller.selectedMonth),
              onPrevious: _controller.isLoading ? null : _previousMonth,
              onNext: _controller.isLoading ? null : _nextMonth,
            ),
            const SizedBox(height: 16),
            _LineChartCard(
              title: 'Consumo diario (kg/animal)',
              points: consumoAnimal,
              suffix: ' kg',
            ),
            const SizedBox(height: 16),
            _BarChartCard(title: 'Comparativo entre potreiros e lotes', points: consumoLote),
            const SizedBox(height: 16),
            _LineChartCard(title: 'Consumo mês a mês', points: mesAMes, suffix: ' kg'),
          ],
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
  const _MonthSelector({required this.label, required this.onPrevious, required this.onNext});

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
        shadows: const [BoxShadow(color: Color(0x0A000000), blurRadius: 24, offset: Offset(0, 0))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(onTap: onPrevious, child: const Icon(Icons.arrow_back_rounded)),
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
          InkWell(onTap: onNext, child: const Icon(Icons.arrow_forward_rounded)),
        ],
      ),
    );
  }
}

class _LineChartCard extends StatelessWidget {
  const _LineChartCard({required this.title, required this.points, required this.suffix});

  final String title;
  final List<_ChartPoint> points;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    return _ChartCard(
      title: title,
      child: points.isEmpty
          ? const _EmptyChartText()
          : SizedBox(
              height: 260,
              child: CustomPaint(
                painter: _LineChartPainter(points: points, suffix: suffix),
                child: const SizedBox.expand(),
              ),
            ),
    );
  }
}

class _BarChartCard extends StatelessWidget {
  const _BarChartCard({required this.title, required this.points});

  final String title;
  final List<_ChartPoint> points;

  @override
  Widget build(BuildContext context) {
    return _ChartCard(
      title: title,
      child: points.isEmpty
          ? const _EmptyChartText()
          : SizedBox(
              height: 260,
              child: CustomPaint(
                painter: _BarChartPainter(points: points),
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
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0xFFEBEBEB)),
          borderRadius: BorderRadius.circular(16),
        ),
        shadows: const [BoxShadow(color: Color(0x0A000000), blurRadius: 24, offset: Offset(0, 0))],
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

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({required this.points, required this.suffix});

  final List<_ChartPoint> points;
  final String suffix;

  @override
  void paint(Canvas canvas, Size size) {
    const left = 56.0;
    const bottom = 38.0;
    const top = 12.0;
    const right = 10.0;
    final chart = Rect.fromLTRB(left, top, size.width - right, size.height - bottom);
    final maxValue = _niceMax(points.map((point) => point.value).fold(0, math.max));
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    final gridPaint = Paint()
      ..color = const Color(0xFFEDEDED)
      ..strokeWidth = 1;

    for (var i = 0; i <= 4; i++) {
      final y = chart.top + (chart.height / 4) * i;
      canvas.drawLine(Offset(chart.left, y), Offset(chart.right, y), gridPaint);
      final value = maxValue - (maxValue / 4) * i;
      _drawText(textPainter, canvas, '${_formatDecimal(value)}$suffix', Offset(0, y - 8));
    }

    if (points.length == 1) {
      final y = chart.bottom - (points.first.value / maxValue) * chart.height;
      _drawPoint(canvas, Offset(chart.left, y));
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
        Offset(x - 20, chart.bottom + 12),
      );
    }
  }

  void _drawPoint(Canvas canvas, Offset offset) {
    canvas.drawCircle(offset, 8, Paint()..color = Colors.white);
    canvas.drawCircle(offset, 6, Paint()..color = const Color(0xFF147AD6));
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.suffix != suffix;
  }
}

class _BarChartPainter extends CustomPainter {
  _BarChartPainter({required this.points});

  final List<_ChartPoint> points;

  @override
  void paint(Canvas canvas, Size size) {
    const left = 42.0;
    const bottom = 38.0;
    const top = 12.0;
    const right = 10.0;
    final chart = Rect.fromLTRB(left, top, size.width - right, size.height - bottom);
    final maxValue = _niceMax(points.map((point) => point.value).fold(0, math.max));
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
    final barWidth = math.min(42.0, slot * 0.42);
    for (var i = 0; i < points.length; i++) {
      final height = (points[i].value / maxValue) * chart.height;
      final x = chart.left + slot * i + (slot - barWidth) / 2;
      final rect = RRect.fromRectAndCorners(
        Rect.fromLTWH(x, chart.bottom - height, barWidth, height),
        topLeft: const Radius.circular(8),
        topRight: const Radius.circular(8),
      );
      canvas.drawRRect(rect, Paint()..color = const Color(0xFF008C42));
      _drawText(
        textPainter,
        canvas,
        _shortLabel(points[i].label),
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
  const _ChartPoint({required this.label, required this.value});

  final String label;
  final double value;
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
  painter.layout(maxWidth: 70);
  painter.paint(canvas, offset);
}

String _formatDecimal(double value) {
  if (value == value.truncateToDouble()) return value.toStringAsFixed(0);
  return value.toStringAsFixed(2).replaceAll('.', ',');
}

String _shortLabel(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return '-';
  final firstWord = trimmed.split(' ').first;
  return firstWord.length <= 10 ? firstWord : firstWord.substring(0, 10);
}

double? _asDouble(dynamic value) {
  if (value == null) return null;
  return double.tryParse(value.toString().replaceAll(',', '.'));
}
