import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/features/movimentacoes/domain/entities/troca_categoria_charts_entity.dart';
import 'package:costeira/features/movimentacoes/presentation/widgets/monthly_bar_chart_card.dart';
import 'package:costeira/features/movimentacoes/troca_categoria/presentation/controllers/get_troca_categoria_charts_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class GraficosTrocaCategoria extends StatefulWidget {
  const GraficosTrocaCategoria({super.key});

  @override
  State<GraficosTrocaCategoria> createState() => _GraficosTrocaCategoriaState();
}

class _GraficosTrocaCategoriaState extends State<GraficosTrocaCategoria> {
  final GetTrocaCategoriaChartsController _controller =
      Modular.get<GetTrocaCategoriaChartsController>();

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
        child: SafeArea(top: false, child: Center(child: CircularProgressIndicator())),
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

    final data = charts ?? TrocaCategoriaChartsEntity.empty;
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
              _TotalCard(value: data.quantidadeTrocas),
              const SizedBox(height: 16),
              MonthlyBarChartCard(
                title: 'Trocas por mês',
                points: data.mesAMes
                    .map(
                      (point) => MonthlyBarChartPoint(
                        month: point.month,
                        value: point.quantity.toDouble(),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
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
            'Trocas de categoria',
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

String _formatMonth(DateTime date) {
  return '${_monthNames[date.month - 1]} ${date.year}';
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
