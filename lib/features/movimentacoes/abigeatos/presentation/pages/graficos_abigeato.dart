import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/features/movimentacoes/domain/entities/abigeato_charts_entity.dart';
import 'package:costeira/features/movimentacoes/abigeatos/presentation/controllers/get_abigeato_charts_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class GraficosAbigeato extends StatefulWidget {
  const GraficosAbigeato({super.key});

  @override
  State<GraficosAbigeato> createState() => _GraficosAbigeatoState();
}

class _GraficosAbigeatoState extends State<GraficosAbigeato> {
  final GetAbigeatoChartsController _controller =
      Modular.get<GetAbigeatoChartsController>();

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

    final data = charts ?? AbigeatoChartsEntity.empty;
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
            _TotalCard(value: data.quantidadeAbigeatos),
            const SizedBox(height: 16),
            _MonthlyCard(points: data.mesAMes),
          ],
        ),
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

class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    return _BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Abigeatos',
            style: TextStyle(
              color: Color(0xFF313131),
              fontSize: 16,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            value.toString(),
            style: const TextStyle(
              color: Color(0xFF313131),
              fontSize: 24,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthlyCard extends StatelessWidget {
  const _MonthlyCard({required this.points});

  final List<AbigeatoMonthlyEntity> points;

  @override
  Widget build(BuildContext context) {
    final maxValue = points
        .map((item) => item.quantity)
        .fold<int>(0, (max, value) => value > max ? value : max);

    return _BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Abigeatos por mes',
            style: TextStyle(
              color: Color(0xFF313131),
              fontSize: 16,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          if (points.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 80),
              child: Center(child: Text('Sem dados para o periodo.')),
            )
          else
            for (final point in points) ...[
              _MonthBar(point: point, maxValue: maxValue),
              const SizedBox(height: 12),
            ],
        ],
      ),
    );
  }
}

class _MonthBar extends StatelessWidget {
  const _MonthBar({required this.point, required this.maxValue});

  final AbigeatoMonthlyEntity point;
  final int maxValue;

  @override
  Widget build(BuildContext context) {
    final factor = maxValue <= 0 ? 0.0 : point.quantity / maxValue;
    return Row(
      children: [
        SizedBox(
          width: 44,
          child: Text(
            _monthShortName(point.month),
            style: const TextStyle(
              color: Color(0xFF8C8C8C),
              fontSize: 12,
              fontFamily: 'Montserrat',
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: factor,
              minHeight: 12,
              backgroundColor: const Color(0xFFECECEC),
              color: const Color(0xFF008B42),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 32,
          child: Text(
            point.quantity.toString(),
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Color(0xFF313131),
              fontSize: 12,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
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
