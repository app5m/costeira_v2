import 'dart:math' as math;

import 'package:flutter/material.dart';

class MonthlyBarChartPoint {
  const MonthlyBarChartPoint({required this.month, required this.value});

  final int month;
  final double value;
}

class MonthlyBarChartCard extends StatelessWidget {
  const MonthlyBarChartCard({
    super.key,
    required this.title,
    required this.points,
    this.axisLabelBuilder,
  });

  final String title;
  final List<MonthlyBarChartPoint> points;
  final String Function(double value)? axisLabelBuilder;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0xFFEBEBEB)),
          borderRadius: BorderRadius.circular(12),
        ),
        shadows: const [BoxShadow(color: Color(0x0A000000), blurRadius: 24)],
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
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: points.isEmpty
                ? const Center(child: Text('Sem dados para o periodo.'))
                : CustomPaint(
                    painter: _MonthlyBarChartPainter(
                      points: points,
                      axisLabelBuilder: axisLabelBuilder ?? _formatAxisValue,
                    ),
                    child: const SizedBox.expand(),
                  ),
          ),
        ],
      ),
    );
  }
}

class _MonthlyBarChartPainter extends CustomPainter {
  _MonthlyBarChartPainter({
    required this.points,
    required this.axisLabelBuilder,
  });

  final List<MonthlyBarChartPoint> points;
  final String Function(double value) axisLabelBuilder;

  @override
  void paint(Canvas canvas, Size size) {
    const left = 54.0;
    const bottom = 34.0;
    const top = 12.0;
    const right = 12.0;
    final chartWidth = size.width - left - right;
    final chartHeight = size.height - top - bottom;
    final maxValue = _niceMax(
      points.map((item) => item.value).fold<double>(0, math.max),
    );

    final gridPaint = Paint()
      ..color = const Color(0xFFECECEC)
      ..strokeWidth = 1;
    final barPaint = Paint()
      ..color = const Color(0xFF008B42)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = math.min(14, chartWidth / (points.length * 3));
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (var i = 0; i <= 4; i++) {
      final ratio = i / 4;
      final y = top + chartHeight * ratio;
      canvas.drawLine(
        Offset(left, y),
        Offset(size.width - right, y),
        gridPaint,
      );

      textPainter.text = TextSpan(
        text: axisLabelBuilder(maxValue * (1 - ratio)),
        style: const TextStyle(
          color: Color(0xFF9E9E9E),
          fontSize: 12,
          fontFamily: 'Montserrat',
        ),
      );
      textPainter.layout(maxWidth: left - 8);
      textPainter.paint(canvas, Offset(0, y - textPainter.height / 2));
    }

    final step = chartWidth / points.length;
    for (var i = 0; i < points.length; i++) {
      final point = points[i];
      final x = left + step * i + step / 2;
      final barHeight = maxValue <= 0
          ? 0
          : chartHeight * (point.value / maxValue);
      final yBottom = top + chartHeight;
      final yTop = yBottom - barHeight;
      canvas.drawLine(Offset(x, yBottom), Offset(x, yTop), barPaint);

      textPainter.text = TextSpan(
        text: monthShortName(point.month),
        style: const TextStyle(
          color: Color(0xFF8C8C8C),
          fontSize: 12,
          fontFamily: 'Montserrat',
        ),
      );
      textPainter.layout(maxWidth: step);
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, size.height - bottom + 12),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MonthlyBarChartPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.axisLabelBuilder != axisLabelBuilder;
  }
}

double _niceMax(double value) {
  if (value <= 0) {
    return 1;
  }
  if (value <= 5) {
    return value.ceilToDouble();
  }
  final exponent = math.pow(10, value.toStringAsFixed(0).length - 1).toDouble();
  return (value / exponent).ceil() * exponent;
}

String _formatAxisValue(double value) {
  if (value == value.roundToDouble()) {
    return value.toStringAsFixed(0);
  }
  return value.toStringAsFixed(1).replaceAll('.', ',');
}

String monthShortName(int month) {
  if (month < 1 || month > 12) {
    return '-';
  }
  return _shortMonthNames[month - 1];
}

const _shortMonthNames = [
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
