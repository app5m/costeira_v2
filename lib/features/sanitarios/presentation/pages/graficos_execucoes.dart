import 'dart:math' as math;

import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/features/sanitarios/domain/entities/sanitario.dart';
import 'package:costeira/features/sanitarios/presentation/controllers/get_sanitario_charts_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class GraficosExcucao extends StatefulWidget {
  const GraficosExcucao({super.key});

  @override
  State<GraficosExcucao> createState() => _GraficosExcucaoState();
}

class _GraficosExcucaoState extends State<GraficosExcucao> {
  late final GetSanitarioChartsController _controller;

  static const _colors = [Color(0xFF354662), Color(0xFF5B7CBC)];

  @override
  void initState() {
    super.initState();
    _controller = Modular.get<GetSanitarioChartsController>();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCharts());
  }

  Future<void> _loadCharts() async {
    try {
      await _controller.load();
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.show(
        context: context,
        message: _controller.errorMessage ?? 'Nao foi possivel carregar os graficos.',
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
        message: _controller.errorMessage ?? 'Nao foi possivel carregar os graficos.',
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
        message: _controller.errorMessage ?? 'Nao foi possivel carregar os graficos.',
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

          final charts = _controller.charts ?? SanitarioChartsEntity.empty;
          return RefreshIndicator(
            onRefresh: _loadCharts,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(height: 16),
                  _MonthSelector(
                    label: _formatMonth(_controller.selectedMonth),
                    onPrevious: _controller.isLoading ? null : _previousMonth,
                    onNext: _controller.isLoading ? null : _nextMonth,
                  ),
                  const SizedBox(height: 16),
                  _ExecutionCard(data: charts.planejadosExecutados, colors: _colors),
                  const SizedBox(height: 16),
                  _TimelineCard(items: charts.planejadosExecutadosMesAMes),
                  const SizedBox(height: 16),
                  _ProductsCard(items: charts.executadoPorInsumoTipoManejo),
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
}

class _MonthSelector extends StatelessWidget {
  const _MonthSelector({required this.label, required this.onPrevious, required this.onNext});

  final String label;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return _ChartCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(onTap: onPrevious, child: const Icon(Icons.arrow_back_rounded)),
          Text(
            label,
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

class _ExecutionCard extends StatelessWidget {
  const _ExecutionCard({required this.data, required this.colors});

  final SanitarioPlanejadoExecutadoEntity data;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    final total = data.planejado + data.executado;
    final planejadoPct = total == 0 ? 0.0 : (data.planejado / total) * 100;
    final executadoPct = total == 0 ? 0.0 : (data.executado / total) * 100;

    return _ChartCard(
      title: 'Execução',
      child: total == 0
          ? const _EmptyChartText()
          : Column(
              children: [
                SizedBox(
                  height: 230,
                  child: Center(
                    child: SizedBox(
                      width: 180,
                      height: 180,
                      child: CustomPaint(
                        painter: _DonutChartPainter(
                          values: [data.executado, data.planejado],
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
                    _LegendItem(
                      color: colors[0],
                      label: 'Executado (${_formatDecimal(executadoPct)}%)',
                    ),
                    _LegendItem(
                      color: colors[1],
                      label: 'Planejado (${_formatDecimal(planejadoPct)}%)',
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  const _TimelineCard({required this.items});

  final List<SanitarioPlanejadoExecutadoMesEntity> items;

  @override
  Widget build(BuildContext context) {
    return _ChartCard(
      title: 'Linha do tempo dos manejos sanitários',
      child: items.isEmpty
          ? const _EmptyChartText()
          : SizedBox(
              height: 220,
              child: CustomPaint(
                painter: _LineChartPainter(items: items),
                child: const SizedBox.expand(),
              ),
            ),
    );
  }
}

class _ProductsCard extends StatelessWidget {
  const _ProductsCard({required this.items});

  final List<SanitarioExecutadoInsumoTipoManejoEntity> items;

  @override
  Widget build(BuildContext context) {
    return _ChartCard(
      title: 'Produtos aplicados por manejo',
      child: items.isEmpty
          ? const _EmptyChartText()
          : SizedBox(
              height: math.max(180, items.length * 58).toDouble(),
              child: CustomPaint(
                painter: _HorizontalBarPainter(items: items),
                child: const SizedBox.expand(),
              ),
            ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.child, this.title, this.padding = const EdgeInsets.all(16)});

  final String? title;
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width - 40,
      padding: padding,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0xFFEBEBEB)),
          borderRadius: BorderRadius.circular(16),
        ),
        shadows: const [BoxShadow(color: Color(0x0A000000), blurRadius: 24)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: const TextStyle(
                color: Color(0xFF313131),
                fontSize: 14,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
          ],
          child,
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF666666),
            fontSize: 13,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
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
  _DonutChartPainter({required this.values, required this.colors});

  final List<double> values;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold<double>(0, (sum, value) => sum + value);
    if (total <= 0) return;

    final strokeWidth = size.width * 0.16;
    var startAngle = -math.pi / 2;
    for (var i = 0; i < values.length; i++) {
      final sweep = (values[i] / total) * math.pi * 2;
      canvas.drawArc(
        (Offset.zero & size).deflate(strokeWidth / 2),
        startAngle,
        math.max(0.02, sweep),
        false,
        Paint()
          ..color = colors[i % colors.length]
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
      );
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) => true;
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({required this.items});

  final List<SanitarioPlanejadoExecutadoMesEntity> items;

  @override
  void paint(Canvas canvas, Size size) {
    final grouped = <String, double>{};
    for (final item in items) {
      final key = '${item.mes.toString().padLeft(2, '0')}/${item.ano}';
      grouped[key] = (grouped[key] ?? 0) + item.quantidade;
    }
    final points = grouped.entries.toList(growable: false);
    if (points.isEmpty) return;

    const left = 36.0;
    const top = 12.0;
    const bottom = 34.0;
    final chart = Rect.fromLTRB(left, top, size.width - 8, size.height - bottom);
    final maxValue = _niceMax(points.map((point) => point.value).fold(0, math.max));
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final x = points.length == 1
          ? chart.left
          : chart.left + (chart.width / (points.length - 1)) * i;
      final y = chart.bottom - (points[i].value / maxValue) * chart.height;
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF147AD6)
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );

    for (var i = 0; i < points.length; i++) {
      final x = points.length == 1
          ? chart.left
          : chart.left + (chart.width / (points.length - 1)) * i;
      final y = chart.bottom - (points[i].value / maxValue) * chart.height;
      canvas.drawCircle(Offset(x, y), 7, Paint()..color = Colors.white);
      canvas.drawCircle(Offset(x, y), 5, Paint()..color = const Color(0xFF147AD6));
      _drawText(
        textPainter,
        canvas,
        points[i].key.substring(0, 2),
        Offset(x - 8, chart.bottom + 12),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) => true;
}

class _HorizontalBarPainter extends CustomPainter {
  _HorizontalBarPainter({required this.items});

  final List<SanitarioExecutadoInsumoTipoManejoEntity> items;

  @override
  void paint(Canvas canvas, Size size) {
    final maxValue = _niceMax(items.map((item) => item.quantidade).fold(0, math.max));
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    const left = 112.0;
    const right = 8.0;
    const top = 10.0;
    final chartWidth = size.width - left - right;
    final rowHeight = size.height / items.length;

    for (var i = 0; i < items.length; i++) {
      final y = top + rowHeight * i + 10;
      final width = chartWidth * (items[i].quantidade / maxValue);
      _drawText(textPainter, canvas, _shortText(items[i].insumo.nome), Offset(0, y + 4));
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(left, y, width, 20), const Radius.circular(4)),
        Paint()..color = const Color(0xFF147AD6),
      );
      _drawText(
        textPainter,
        canvas,
        _formatDecimal(items[i].quantidade),
        Offset(left + width + 6, y + 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _HorizontalBarPainter oldDelegate) => true;
}

double _niceMax(double value) {
  if (value <= 0) return 10;
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
  painter.layout(maxWidth: 108);
  painter.paint(canvas, offset);
}

String _formatDecimal(double value) {
  if (value == value.truncateToDouble()) return value.toStringAsFixed(0);
  return value.toStringAsFixed(2).replaceAll('.', ',');
}

String _shortText(String value) {
  final trimmed = value.trim();
  if (trimmed.length <= 14) return trimmed;
  return '${trimmed.substring(0, 13)}.';
}
