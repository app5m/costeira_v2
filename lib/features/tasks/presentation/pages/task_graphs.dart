import 'dart:math' as math;

import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/features/tasks/domain/entities/task_charts_entity.dart';
import 'package:costeira/features/tasks/presentation/controllers/get_task_charts_controller.dart';
import 'package:costeira/features/tasks/presentation/helpers/task_formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class TaskGraphs extends StatefulWidget {
  const TaskGraphs({super.key});

  @override
  State<TaskGraphs> createState() => _TaskGraphsState();
}

class _TaskGraphsState extends State<TaskGraphs> {
  final GetTaskChartsController _controller = Modular.get<GetTaskChartsController>();

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
    if (mounted) setState(() {});
  }

  Future<void> _load() async {
    try {
      await _controller.load();
    } catch (error) {
      if (!mounted || error is ApiException) return;
      AppSnackBar.show(
        context: context,
        message: 'Nao foi possivel carregar os graficos.',
        isError: true,
      );
    }
  }

  Future<void> _prev() async {
    try {
      await _controller.previousMonth();
    } catch (_) {}
  }

  Future<void> _next() async {
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
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null && charts == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(error, textAlign: TextAlign.center),
        ),
      );
    }

    final data = charts ?? TaskChartsEntity.empty;
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          _MonthSelector(
            month: _controller.month,
            isLoading: isLoading,
            onPrev: _prev,
            onNext: _next,
          ),
          const SizedBox(height: 16),
          _ExecucaoCard(charts: data),
          const SizedBox(height: 16),
          _RealizadasCard(percentual: data.realizadas.percentual),
          const SizedBox(height: 16),
          _RankingCard(items: data.rankingFuncionarios),
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
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
    required this.onPrev,
    required this.onNext,
  });

  final DateTime month;
  final bool isLoading;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return _BaseCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: isLoading ? null : onPrev,
            child: Icon(
              Icons.arrow_back_rounded,
              color: isLoading ? const Color(0xFFBDBDBD) : null,
            ),
          ),
          Text(
            formatTaskMonth(month),
            style: const TextStyle(
              color: Color(0xFF8C8C8C),
              fontSize: 14,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w500,
              height: 1.50,
            ),
          ),
          GestureDetector(
            onTap: isLoading ? null : onNext,
            child: Icon(
              Icons.arrow_forward_rounded,
              color: isLoading ? const Color(0xFFBDBDBD) : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExecucaoCard extends StatelessWidget {
  const _ExecucaoCard({required this.charts});

  final TaskChartsEntity charts;

  @override
  Widget build(BuildContext context) {
    final segments = <_DonutSegment>[
      _DonutSegment(
        value: charts.realizadas.percentual,
        color: const Color(0xFF394762),
        label: 'Realizado',
      ),
      _DonutSegment(
        value: charts.programadas.percentual,
        color: const Color(0xFF7E97C2),
        label: 'Planejado',
      ),
      if (charts.atrasadas.percentual > 0)
        _DonutSegment(
          value: charts.atrasadas.percentual,
          color: const Color(0xFFE8744F),
          label: 'Atrasado',
        ),
    ];

    return _BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Execução',
            style: TextStyle(
              color: Color(0xFF313131),
              fontSize: 14,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: SizedBox(
              width: 180,
              height: 180,
              child: CustomPaint(painter: _DonutPainter(segments: segments)),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: segments
                .map(
                  (s) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(color: s.color, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${s.label} (${_formatPercent(s.value)}%)',
                        style: const TextStyle(
                          color: Color(0xFF5C5C5C),
                          fontSize: 12,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
                .toList(growable: false),
          ),
        ],
      ),
    );
  }
}

class _RealizadasCard extends StatelessWidget {
  const _RealizadasCard({required this.percentual});

  final double percentual;

  @override
  Widget build(BuildContext context) {
    final clamped = percentual.clamp(0, 100).toDouble();
    return _BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tarefas realizadas',
            style: TextStyle(
              color: Color(0xFF313131),
              fontSize: 14,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: clamped / 100,
              minHeight: 12,
              backgroundColor: const Color(0xFFEBEBEB),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF394762)),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${_formatPercent(clamped)}%',
              style: const TextStyle(
                color: Color(0xFF5C5C5C),
                fontSize: 12,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RankingCard extends StatelessWidget {
  const _RankingCard({required this.items});

  final List<TaskChartsRankingItemEntity> items;

  @override
  Widget build(BuildContext context) {
    return _BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ranking de execução por funcionário',
            style: TextStyle(
              color: Color(0xFF313131),
              fontSize: 14,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            const Text(
              'Nenhum funcionario com tarefas realizadas no periodo.',
              style: TextStyle(
                color: Color(0xFF8C8C8C),
                fontSize: 12,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w500,
              ),
            )
          else
            ...List.generate(items.length, (index) {
              final item = items[index];
              return Padding(
                padding: EdgeInsets.only(top: index == 0 ? 0 : 8),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Color(0xFF394762),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.responsavel.nome,
                        style: const TextStyle(
                          color: Color(0xFF313131),
                          fontSize: 13,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      '${item.quantidadeRealizadas}',
                      style: const TextStyle(
                        color: Color(0xFF5C5C5C),
                        fontSize: 13,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _DonutSegment {
  const _DonutSegment({required this.value, required this.color, required this.label});

  final double value;
  final Color color;
  final String label;
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({required this.segments});

  final List<_DonutSegment> segments;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = 22.0;
    final rect = Rect.fromLTWH(stroke / 2, stroke / 2, size.width - stroke, size.height - stroke);

    final background = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = const Color(0xFFEBEBEB);
    canvas.drawArc(rect, 0, math.pi * 2, false, background);

    final total = segments.fold<double>(0, (sum, s) => sum + s.value);
    if (total <= 0) return;

    var startAngle = -math.pi / 2;
    for (final segment in segments) {
      if (segment.value <= 0) continue;
      final sweep = (segment.value / total) * math.pi * 2;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.butt
        ..color = segment.color;
      canvas.drawArc(rect, startAngle, sweep, false, paint);
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    if (oldDelegate.segments.length != segments.length) return true;
    for (var i = 0; i < segments.length; i++) {
      final a = oldDelegate.segments[i];
      final b = segments[i];
      if (a.value != b.value || a.color != b.color) return true;
    }
    return false;
  }
}

String _formatPercent(double value) {
  if (value == value.roundToDouble()) {
    return value.toStringAsFixed(0);
  }
  return value.toStringAsFixed(1);
}
