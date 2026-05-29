import 'dart:math' as math;

import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/features/potreiros/domain/entities/potreiro_charts_entity.dart';
import 'package:costeira/features/potreiros/presentation/controllers/get_potreiro_charts_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class DadosPotreiros extends StatefulWidget {
  const DadosPotreiros({super.key});

  @override
  State<DadosPotreiros> createState() => _DadosPotreirosState();
}

class _DadosPotreirosState extends State<DadosPotreiros> {
  final GetPotreiroChartsController _controller = Modular.get<GetPotreiroChartsController>();

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
        message: _controller.errorMessage ?? 'Nao foi possivel carregar os graficos.',
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

        final charts = _controller.charts;
        if (charts == null || charts.tabelaAreas.isEmpty) {
          return RefreshIndicator(
            onRefresh: _loadCharts,
            child: ListView(
              children: const [
                SizedBox(height: 120),
                Center(child: Text('Nenhum dado disponível ainda.')),
              ],
            ),
          );
        }

        final dominantAgua = _findDominantLevel(charts.agua);
        final dominantSombra = _findDominantLevel(charts.sombra);

        return RefreshIndicator(
          onRefresh: _loadCharts,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 16),
                _MapCard(charts: charts),
                const SizedBox(height: 16),
                _SummaryCards(charts: charts),
                const SizedBox(height: 16),
                _AvailabilityCard(
                  sombraPercentual: dominantSombra.percentual,
                  aguaPercentual: dominantAgua.percentual,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  PotreiroChartsLevelEntity _findDominantLevel(List<PotreiroChartsLevelEntity> items) {
    if (items.isEmpty) {
      return const PotreiroChartsLevelEntity(nivel: '', quantidade: 0, percentual: 0);
    }

    var dominant = items.first;
    for (final item in items.skip(1)) {
      if (item.percentual > dominant.percentual) {
        dominant = item;
      }
    }
    return dominant;
  }
}

String _formatDecimal(double value) {
  if (value == value.truncateToDouble()) {
    return value.toStringAsFixed(0);
  }
  return value.toStringAsFixed(2);
}

class _MapCard extends StatelessWidget {
  const _MapCard({required this.charts});

  final PotreiroChartsEntity charts;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mapa geral dos potreiros',
            style: TextStyle(
              color: Color(0xFF313131),
              fontSize: 12,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w500,
              letterSpacing: 0.10,
            ),
          ),
          const SizedBox(height: 16),
          AspectRatio(aspectRatio: 1.2, child: CustomPaint(painter: _PastureMapPainter(charts))),
        ],
      ),
    );
  }
}

class _PastureMapPainter extends CustomPainter {
  const _PastureMapPainter(this.charts);

  final PotreiroChartsEntity charts;

  @override
  void paint(Canvas canvas, Size size) {
    final area = Offset.zero & size;
    final blob = _buildBlobPath(area);

    final fillPaint = Paint()..color = const Color(0xFF0B8F3C);
    canvas.drawPath(blob, fillPaint);

    canvas.save();
    canvas.clipPath(blob);

    final dividerPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final dividerCount = math.max(1, charts.tabelaAreas.length);
    final normalizedAreas = _normalizedAreas(charts.tabelaAreas);

    for (var index = 0; index < dividerCount; index++) {
      final path = Path();
      final pivot = normalizedAreas[index % normalizedAreas.length];
      final bend = 0.15 + (pivot * 0.35);

      if (index % 3 == 0) {
        path.moveTo(size.width * (0.18 + (index * 0.07) % 0.45), size.height);
        path.cubicTo(
          size.width * (0.22 + bend),
          size.height * 0.76,
          size.width * (0.42 - bend * 0.5),
          size.height * 0.42,
          size.width * (0.55 + bend * 0.25),
          0,
        );
      } else if (index % 3 == 1) {
        path.moveTo(0, size.height * (0.45 + (index * 0.06) % 0.18));
        path.cubicTo(
          size.width * 0.18,
          size.height * (0.4 - bend * 0.2),
          size.width * 0.38,
          size.height * (0.65 + bend * 0.25),
          size.width,
          size.height * (0.52 - bend * 0.15),
        );
      } else {
        path.moveTo(size.width * (0.75 - bend * 0.2), size.height);
        path.cubicTo(
          size.width * (0.7 + bend * 0.1),
          size.height * 0.72,
          size.width * (0.62 - bend * 0.3),
          size.height * 0.33,
          size.width * (0.3 + bend * 0.15),
          size.height * 0.08,
        );
      }

      canvas.drawPath(path, dividerPaint);
    }

    if (_shouldPaintWater()) {
      final waterPath = Path()
        ..moveTo(size.width * 0.2, size.height * 0.72)
        ..cubicTo(
          size.width * 0.14,
          size.height * 0.69,
          size.width * 0.15,
          size.height * 0.61,
          size.width * 0.23,
          size.height * 0.61,
        )
        ..cubicTo(
          size.width * 0.3,
          size.height * 0.6,
          size.width * 0.34,
          size.height * 0.63,
          size.width * 0.33,
          size.height * 0.68,
        )
        ..cubicTo(
          size.width * 0.31,
          size.height * 0.73,
          size.width * 0.25,
          size.height * 0.75,
          size.width * 0.2,
          size.height * 0.72,
        );
      canvas.drawPath(waterPath, Paint()..color = const Color(0xFFA9EFFF));
    }

    canvas.restore();
  }

  Path _buildBlobPath(Rect rect) {
    return Path()
      ..moveTo(rect.width * 0.16, rect.height * 0.56)
      ..cubicTo(
        rect.width * 0.14,
        rect.height * 0.46,
        rect.width * 0.28,
        rect.height * 0.46,
        rect.width * 0.33,
        rect.height * 0.38,
      )
      ..lineTo(rect.width * 0.45, rect.height * 0.18)
      ..cubicTo(
        rect.width * 0.48,
        rect.height * 0.12,
        rect.width * 0.56,
        rect.height * 0.12,
        rect.width * 0.59,
        rect.height * 0.18,
      )
      ..lineTo(rect.width * 0.83, rect.height * 0.36)
      ..lineTo(rect.width * 0.83, rect.height * 0.66)
      ..cubicTo(
        rect.width * 0.9,
        rect.height * 0.73,
        rect.width * 0.95,
        rect.height * 0.82,
        rect.width * 0.96,
        rect.height * 0.9,
      )
      ..cubicTo(
        rect.width * 0.85,
        rect.height * 0.9,
        rect.width * 0.78,
        rect.height * 0.83,
        rect.width * 0.73,
        rect.height * 0.84,
      )
      ..cubicTo(
        rect.width * 0.68,
        rect.height * 0.85,
        rect.width * 0.65,
        rect.height * 0.94,
        rect.width * 0.57,
        rect.height * 0.92,
      )
      ..cubicTo(
        rect.width * 0.5,
        rect.height * 0.91,
        rect.width * 0.48,
        rect.height * 0.84,
        rect.width * 0.42,
        rect.height * 0.84,
      )
      ..cubicTo(
        rect.width * 0.36,
        rect.height * 0.84,
        rect.width * 0.33,
        rect.height * 0.92,
        rect.width * 0.25,
        rect.height * 0.9,
      )
      ..cubicTo(
        rect.width * 0.17,
        rect.height * 0.87,
        rect.width * 0.14,
        rect.height * 0.73,
        rect.width * 0.16,
        rect.height * 0.56,
      )
      ..close();
  }

  List<double> _normalizedAreas(List<PotreiroAreaTableItemEntity> items) {
    final total = items.fold<double>(0, (sum, item) => sum + item.areaTotal);
    if (total <= 0) {
      return List<double>.filled(items.length, 1 / math.max(1, items.length));
    }
    return items
        .map((item) => (item.areaTotal / total).clamp(0.08, 0.55))
        .cast<double>()
        .toList(growable: false);
  }

  bool _shouldPaintWater() {
    return charts.agua.any((item) => item.percentual > 0);
  }

  @override
  bool shouldRepaint(covariant _PastureMapPainter oldDelegate) {
    return oldDelegate.charts != charts;
  }
}

class _SummaryCards extends StatelessWidget {
  const _SummaryCards({required this.charts});

  final PotreiroChartsEntity charts;

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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 320;

          return Column(
            children: [
              Row(
                children: const [
                  Expanded(child: _HeaderText('Área total')),
                  Expanded(child: _HeaderText('Área útil')),
                  Expanded(child: _HeaderText('Uso')),
                ],
              ),
              const Divider(height: 28, color: Color(0xFFF1F1F5)),
              Row(
                children: [
                  Expanded(child: _ValueText('${_formatDecimal(charts.areaTotalSomada)} ha')),
                  Expanded(child: _ValueText('${_formatDecimal(charts.areaUtilSomada)} ha')),
                  Expanded(child: _ValueText('${_formatDecimal(charts.percentualUso)}%')),
                ],
              ),
              const Divider(height: 28, color: Color(0xFFF1F1F5)),
              if (compact) ...[
                _ValueText('Perda: ${_formatDecimal(charts.areaPerdida)} ha'),
                const SizedBox(height: 8),
                _ValueText('Campo perdido: ${_formatDecimal(charts.percentualCampoPerdido)}%'),
              ] else
                Row(
                  children: [
                    Expanded(child: _ValueText('${_formatDecimal(charts.areaPerdida)} ha')),
                    Expanded(
                      child: _ValueText('${_formatDecimal(charts.percentualCampoPerdido)}%'),
                    ),
                    const Expanded(child: _ValueText('Perda')),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}

class _HeaderText extends StatelessWidget {
  const _HeaderText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Color(0xFF313131),
        fontSize: 12,
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _ValueText extends StatelessWidget {
  const _ValueText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF8C8C8C),
          fontSize: 12,
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _AvailabilityCard extends StatelessWidget {
  const _AvailabilityCard({required this.sombraPercentual, required this.aguaPercentual});

  final double sombraPercentual;
  final double aguaPercentual;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Disponibilidade de água',
            style: TextStyle(
              color: Color(0xFF313131),
              fontSize: 12,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          _AvailabilityBar(
            label: 'Sombra',
            percentual: sombraPercentual,
            color: const Color(0xFF0A8F3E),
          ),
          const SizedBox(height: 22),
          _AvailabilityBar(
            label: 'Água',
            percentual: aguaPercentual,
            color: const Color(0xFF1D75CF),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              SizedBox(width: 54),
              _AxisText('0'),
              _AxisText('20%'),
              _AxisText('40%'),
              _AxisText('60%'),
              _AxisText('80%'),
              _AxisText('100%'),
            ],
          ),
        ],
      ),
    );
  }
}

class _AvailabilityBar extends StatelessWidget {
  const _AvailabilityBar({required this.label, required this.percentual, required this.color});

  final String label;
  final double percentual;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final clamped = percentual.clamp(0, 100).toDouble();

    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF8C8C8C),
              fontSize: 14,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Row(
                children: List.generate(
                  5,
                  (index) => Expanded(
                    child: Container(
                      height: 46,
                      margin: EdgeInsets.only(right: index == 4 ? 0 : 2),
                      decoration: BoxDecoration(
                        border: Border(
                          left: const BorderSide(color: Color(0xFFE9E9E9)),
                          right: index == 4
                              ? const BorderSide(color: Color(0xFFE9E9E9))
                              : BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              FractionallySizedBox(
                widthFactor: clamped / 100,
                child: Container(
                  height: 28,
                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AxisText extends StatelessWidget {
  const _AxisText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFFA1A1A1),
        fontSize: 12,
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
