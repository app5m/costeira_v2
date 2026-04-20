import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/features/animals/presentation/controllers/get_animal_charts_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class DadosAnimais extends StatefulWidget {
  const DadosAnimais({super.key});

  @override
  State<DadosAnimais> createState() => _DadosAnimaisState();
}

class _DadosAnimaisState extends State<DadosAnimais> {
  final GetAnimalChartsController _controller =
      Modular.get<GetAnimalChartsController>();

  @override
  void initState() {
    super.initState();
    AppLogger.info('DADOS ANIMAIS PAGE: INIT STATE');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCharts();
    });
  }

  Future<void> _loadCharts() async {
    AppLogger.info('DADOS ANIMAIS PAGE: CARREGANDO GRAFICOS');
    try {
      await _controller.load();
      AppLogger.success('DADOS ANIMAIS PAGE: GRAFICOS CARREGADOS');
    } catch (_) {
      if (!mounted) return;
      AppLogger.error('DADOS ANIMAIS PAGE: ERRO AO CARREGAR GRAFICOS');
      AppSnackBar.show(
        context: context,
        message:
            _controller.errorMessage ??
            'Não foi possível carregar os gráficos.',
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

        final charts = _controller.charts;
        if (charts == null || charts.quantidadeAnimais == 0) {
          return RefreshIndicator(
            onRefresh: _loadCharts,
            child: ListView(
              children: const [
                SizedBox(height: 120),
                Center(child: Text('Nenhum dado dispon\u00edvel ainda.')),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadCharts,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 16),
                _StatCard(
                  label: 'Peso m\u00e9dio',
                  value: '${_formatDecimal(charts.pesoMedioFazenda)} kg',
                  subtitle: '(Baseado em ${charts.quantidadeAnimais} animais)',
                ),
                const SizedBox(height: 16),
                _StatCard(
                  label: 'Total de UA',
                  value: '${_formatDecimal(charts.totalUa)} UA',
                  subtitle: '(Baseado em ${charts.quantidadeAnimais} animais)',
                ),
                const SizedBox(height: 16),
                _StatCard(
                  label: 'Peso total do rebanho',
                  value: '${_formatDecimal(charts.pesoTotalRebanho)} kg',
                  subtitle: '(${charts.quantidadeAnimais} animais)',
                ),
                const SizedBox(height: 16),
                _DistributionCard(
                  title: 'Composi\u00e7\u00e3o do rebanho',
                  items: charts.distribuicaoCategoria
                      .where((item) => item.quantidade > 0)
                      .map(
                        (item) => _DistributionItem(
                          label: item.categoria.trim(),
                          quantidade: item.quantidade,
                          percentual: item.percentual,
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 16),
                _DistributionCard(
                  title: 'Propor\u00e7\u00e3o por sexo',
                  items: charts.proporcaoSexo
                      .where((item) => item.quantidade > 0)
                      .map(
                        (item) => _DistributionItem(
                          label: item.sexoNome,
                          quantidade: item.quantidade,
                          percentual: item.percentual,
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}

String _formatDecimal(double value) {
  if (value == value.truncateToDouble()) {
    return value.toStringAsFixed(0);
  }
  return value.toStringAsFixed(2);
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.subtitle,
  });

  final String label;
  final String value;
  final String subtitle;

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
        shadows: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 24,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF8C8C8C),
              fontSize: 12,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF313131),
                  fontSize: 14,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF8C8C8C),
                    fontSize: 12,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DistributionItem {
  const _DistributionItem({
    required this.label,
    required this.quantidade,
    required this.percentual,
  });

  final String label;
  final int quantidade;
  final double percentual;
}

class _DistributionCard extends StatelessWidget {
  const _DistributionCard({required this.title, required this.items});

  final String title;
  final List<_DistributionItem> items;

  static const List<Color> _barColors = [
    Color(0xFF0A8F3E),
    Color(0xFFFF9442),
    Color(0xFF43D09A),
    Color(0xFFFFC443),
    Color(0xFF4A7CFF),
    Color(0xFF9A5CFF),
  ];

  @override
  Widget build(BuildContext context) {
    final chartItems = items.take(6).toList(growable: false);

    return Container(
      width: MediaQuery.of(context).size.width - 40,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0xFFEBEBEB)),
          borderRadius: BorderRadius.circular(12),
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
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF8C8C8C),
              fontSize: 14,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),
          if (chartItems.isEmpty)
            const Text(
              'Sem dados para exibir.',
              style: TextStyle(
                color: Color(0xFF8C8C8C),
                fontSize: 12,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w500,
              ),
            )
          else
            _DistributionChart(items: chartItems, colors: _barColors),
        ],
      ),
    );
  }
}

class _DistributionChart extends StatelessWidget {
  const _DistributionChart({required this.items, required this.colors});

  final List<_DistributionItem> items;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    final maxValue = items
        .map((item) => item.quantidade)
        .fold<int>(0, (current, value) => value > current ? value : current);
    final topValue = _calculateChartMax(maxValue);
    final ticks = _buildTicks(topValue);

    return Column(
      children: [
        SizedBox(
          height: 360,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 44,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: ticks
                      .map(
                        (tick) => Text(
                          '$tick',
                          style: const TextStyle(
                            color: Color(0xFFA1A1A1),
                            fontSize: 12,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                      .toList(growable: false),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Stack(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(
                        ticks.length,
                        (index) => Container(
                          height: 1,
                          color: const Color(0xFFE9E9E9),
                        ),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(items.length, (index) {
                        final item = items[index];
                        final color = colors[index % colors.length];
                        final ratio = topValue == 0
                            ? 0.0
                            : item.quantidade / topValue;
                        final barLabel = String.fromCharCode(65 + index);

                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: index == 0 ? 4 : 12,
                              right: index == items.length - 1 ? 4 : 12,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  '${item.quantidade}',
                                  style: const TextStyle(
                                    color: Color(0xFF8C8C8C),
                                    fontSize: 13,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  height: 220 * ratio.clamp(0.0, 1.0),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        color.withValues(alpha: 0.78),
                                        color,
                                      ],
                                    ),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 18),
                                Text(
                                  barLabel,
                                  style: const TextStyle(
                                    color: Color(0xFFA1A1A1),
                                    fontSize: 14,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 24,
          runSpacing: 18,
          children: List.generate(items.length, (index) {
            final item = items[index];
            final color = colors[index % colors.length];
            return SizedBox(
              width: (MediaQuery.of(context).size.width - 120) / 2,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
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
                      '${item.label} (${_formatDecimal(item.percentual)}%)',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF5C5C5C),
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
    );
  }

  static int _calculateChartMax(int value) {
    if (value <= 0) {
      return 100;
    }
    final padded = value + (value * 0.2).ceil();
    final step = padded <= 100 ? 25 : 50;
    return ((padded + step - 1) ~/ step) * step;
  }

  static List<int> _buildTicks(int maxValue) {
    const segments = 4;
    final step = (maxValue / segments).ceil();
    return List.generate(
      segments + 1,
      (index) => maxValue - (step * index),
    ).map((value) => value < 0 ? 0 : value).toList(growable: false);
  }
}
