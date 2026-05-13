import 'dart:math' as math;

import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/features/movimentacoes/domain/entities/venda_charts_entity.dart';
import 'package:costeira/features/movimentacoes/vendas/presentation/controllers/get_venda_charts_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class GraficosVendas extends StatefulWidget {
  const GraficosVendas({super.key});

  @override
  State<GraficosVendas> createState() => _GraficosVendasState();
}

class _GraficosVendasState extends State<GraficosVendas> {
  final GetVendaChartsController _controller =
      Modular.get<GetVendaChartsController>();

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
        message: 'Nao foi possivel carregar os graficos.',
        isError: true,
      );
    }
  }

  Future<void> _previousMonth() async {
    try {
      await _controller.previousMonth();
    } catch (_) {}
  }

  Future<void> _nextMonth() async {
    try {
      await _controller.nextMonth();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = _controller.isLoading;
    final charts = _controller.charts;
    final error = _controller.errorMessage;

    if (isLoading && charts == null) {
      return const Expanded(child: Center(child: CircularProgressIndicator()));
    }

    if (error != null && charts == null) {
      return Expanded(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(error, textAlign: TextAlign.center),
          ),
        ),
      );
    }

    final data = charts ?? VendaChartsEntity.empty;
    return Expanded(
      child: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          children: [
            _MonthSelector(
              month: _controller.month,
              isLoading: isLoading,
              onPrevious: _previousMonth,
              onNext: _nextMonth,
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _MetricCard(title: 'Total vendido', value: data.totalVendido),
                _MetricCard(
                  title: 'kg vendidos',
                  value: '${_formatNumber(data.kgTotais)} kg',
                ),
                _MetricCard(title: 'Preco medio', value: data.precoMedio),
                _MetricCard(
                  title: 'Total de cabecas',
                  value: '${data.totalCabecas} cabecas',
                ),
              ],
            ),
            const SizedBox(height: 16),
            _ChartCard(points: data.valorTotalMesAMes),
          ],
        ),
      ),
    );
  }
}

class _BaseCard extends StatelessWidget {
  const _BaseCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0xFFEBEBEB)),
          borderRadius: BorderRadius.circular(12),
        ),
        shadows: const [BoxShadow(color: Color(0x0A000000), blurRadius: 24)],
      ),
      child: child,
    );
  }
}

class _MonthSelector extends StatelessWidget {
  const _MonthSelector({
    required this.month,
    required this.isLoading,
    required this.onPrevious,
    required this.onNext,
  });

  final DateTime month;
  final bool isLoading;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return _BaseCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: isLoading ? null : onPrevious,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          Text(
            _formatMonth(month),
            style: const TextStyle(
              color: Color(0xFF313131),
              fontSize: 14,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            onPressed: isLoading ? null : onNext,
            icon: const Icon(Icons.arrow_forward_rounded),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return _BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF8C8C8C),
              fontSize: 14,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          FittedBox(
            alignment: Alignment.centerLeft,
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF313131),
                fontSize: 20,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.points});

  final List<VendaMonthlyValueEntity> points;

  @override
  Widget build(BuildContext context) {
    return _BaseCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vendas',
            style: TextStyle(
              color: Color(0xFF313131),
              fontSize: 16,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 260,
            child: points.isEmpty
                ? const Center(child: Text('Sem dados para o periodo.'))
                : CustomPaint(
                    painter: _BarChartPainter(points: points),
                    child: const SizedBox.expand(),
                  ),
          ),
        ],
      ),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  _BarChartPainter({required this.points});

  final List<VendaMonthlyValueEntity> points;

  @override
  void paint(Canvas canvas, Size size) {
    const left = 54.0;
    const bottom = 34.0;
    const top = 12.0;
    const right = 12.0;
    final chartWidth = size.width - left - right;
    final chartHeight = size.height - top - bottom;
    final maxValue = _niceMax(
      points.map((item) => item.valueRaw).fold<double>(0, math.max),
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
      final value = maxValue * (1 - ratio);
      textPainter.text = TextSpan(
        text: _formatAxisValue(value),
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
          : chartHeight * (point.valueRaw / maxValue);
      final yBottom = top + chartHeight;
      final yTop = yBottom - barHeight;
      canvas.drawLine(Offset(x, yBottom), Offset(x, yTop), barPaint);

      textPainter.text = TextSpan(
        text: _monthShortName(point.month),
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
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) {
    return oldDelegate.points != points;
  }
}

double _niceMax(double value) {
  if (value <= 0) {
    return 1;
  }
  final exponent = math.pow(10, value.toStringAsFixed(0).length - 1).toDouble();
  return (value / exponent).ceil() * exponent;
}

String _formatAxisValue(double value) {
  if (value >= 1000000) {
    return 'R\$ ${(value / 1000000).toStringAsFixed(0)}M';
  }
  if (value >= 1000) {
    return 'R\$ ${(value / 1000).toStringAsFixed(0)}k';
  }
  return 'R\$ ${value.toStringAsFixed(0)}';
}

String _formatNumber(double value) {
  if (value == value.roundToDouble()) {
    return value.toStringAsFixed(0);
  }
  return value.toStringAsFixed(2).replaceAll('.', ',');
}

String _formatMonth(DateTime date) {
  return '${_monthNames[date.month - 1]} ${date.year}';
}

String _monthShortName(int month) {
  if (month < 1 || month > 12) {
    return '-';
  }
  return _shortMonthNames[month - 1];
}

const _monthNames = [
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
