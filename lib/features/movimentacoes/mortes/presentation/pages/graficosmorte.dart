import 'dart:math' as math;

import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/features/movimentacoes/domain/entities/morte_charts_entity.dart';
import 'package:costeira/features/movimentacoes/mortes/presentation/controllers/get_morte_charts_controller.dart';
import 'package:costeira/features/movimentacoes/presentation/widgets/monthly_bar_chart_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class GraficosMorte extends StatefulWidget {
  const GraficosMorte({super.key});

  @override
  State<GraficosMorte> createState() => _GraficosMorteState();
}

class _GraficosMorteState extends State<GraficosMorte> {
  final GetMorteChartsController _controller =
      Modular.get<GetMorteChartsController>();

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
      return const Expanded(
        child: SafeArea(
          top: false,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (error != null && charts == null) {
      return Expanded(
        child: SafeArea(
          top: false,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(error, textAlign: TextAlign.center),
            ),
          ),
        ),
      );
    }

    final data = charts ?? MorteChartsEntity.empty;
    return Expanded(
      child: SafeArea(
        top: false,
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
              MonthlyBarChartCard(
                title: 'Linha de mortalidade',
                points: data.totalMesAMes
                    .map(
                      (point) => MonthlyBarChartPoint(
                        month: point.month,
                        value: point.quantity.toDouble(),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
              _CauseChartCard(causes: data.porCausa),
            ],
          ),
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

class _CauseChartCard extends StatelessWidget {
  const _CauseChartCard({required this.causes});

  final List<MorteCauseEntity> causes;

  @override
  Widget build(BuildContext context) {
    return _BaseCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Causas de morte',
            style: TextStyle(
              color: Color(0xFF313131),
              fontSize: 14,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 250,
            child: causes.isEmpty
                ? const Center(child: Text('Sem dados para o periodo.'))
                : CustomPaint(
                    painter: _DonutPainter(causes: causes),
                    child: const SizedBox.expand(),
                  ),
          ),
          if (causes.isNotEmpty) ...[
            const SizedBox(height: 12),
            _CauseLegend(causes: causes),
          ],
        ],
      ),
    );
  }
}

class _CauseLegend extends StatelessWidget {
  const _CauseLegend({required this.causes});

  final List<MorteCauseEntity> causes;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 18,
      runSpacing: 14,
      children: [
        for (var i = 0; i < causes.length; i++)
          SizedBox(
            width: (MediaQuery.of(context).size.width - 92) / 2,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _causeColors[i % _causeColors.length],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${causes[i].cause} (${_formatPercent(causes[i].percent)})',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF6F6F6F),
                      fontSize: 13,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({required this.causes});

  final List<MorteCauseEntity> causes;

  @override
  void paint(Canvas canvas, Size size) {
    final total = causes
        .map((item) => item.percent > 0 ? item.percent : item.quantity)
        .fold<double>(0, (sum, value) => sum + value);
    if (total <= 0) {
      return;
    }

    final diameter = math.min(size.width, size.height) * 0.82;
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: diameter,
      height: diameter,
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24
      ..strokeCap = StrokeCap.round;

    var start = -math.pi / 2;
    for (var i = 0; i < causes.length; i++) {
      final value = causes[i].percent > 0
          ? causes[i].percent
          : causes[i].quantity;
      final sweep = (value / total) * math.pi * 2;
      paint.color = _causeColors[i % _causeColors.length];
      canvas.drawArc(rect, start, sweep, false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.causes != causes;
  }
}

String _formatPercent(double value) {
  if (value == value.roundToDouble()) {
    return '${value.toStringAsFixed(0)}%';
  }
  return '${value.toStringAsFixed(1).replaceAll('.', ',')}%';
}

String _formatMonth(DateTime date) {
  return '${_monthNames[date.month - 1]} ${date.year}';
}

const _causeColors = [
  Color(0xFF071996),
  Color(0xFFD13CCD),
  Color(0xFF2FB15C),
  Color(0xFFFF9F3A),
  Color(0xFF008B42),
  Color(0xFF7E57C2),
];

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
