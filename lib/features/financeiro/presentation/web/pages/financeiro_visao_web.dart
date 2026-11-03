import 'dart:math' as math;

import 'package:costeira/features/financeiro/domain/financeiro_mock.dart';
import 'package:costeira/features/financeiro/presentation/web/widgets/financeiro_web_ui.dart';
import 'package:costeira/features/financeiro/presentation/widgets/financeiro_ui.dart';
import 'package:costeira/theme/colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class FinanceiroVisaoWeb extends StatelessWidget {
  const FinanceiroVisaoWeb({
    super.key,
    required this.aoVerExtrato,
    required this.aoAbrir,
    required this.aoNovoLancamento,
  });

  final VoidCallback aoVerExtrato;
  final ValueChanged<LancamentoMock> aoAbrir;
  final VoidCallback aoNovoLancamento;

  @override
  Widget build(BuildContext context) {
    final loja = FinanceiroEscopo.of(context);
    final recentes = loja.lancamentos.take(8).toList();
    final padding = MediaQuery.sizeOf(context).width < 760 ? 16.0 : 28.0;

    if (loja.carregando && loja.lancamentos.isEmpty) {
      return const Center(child: LoadingFinanceiro(altura: 220));
    }

    return ListView(
      padding: EdgeInsets.fromLTRB(padding, 20, padding, 32),
      children: [
        if (loja.erro != null) ...[
          FinanceiroWebPanel(
            child: Text(
              loja.erro!,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                color: Color(0xFFC4473A),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 980
                ? 5
                : (constraints.maxWidth >= 720 ? 3 : 2);
            const gap = 12.0;
            final width =
                (constraints.maxWidth - gap * (columns - 1)) / columns;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                SizedBox(
                  width: width,
                  child: FinanceiroWebMetricCard(
                    label: 'Saldo disponível',
                    value: loja.saldoTexto,
                  ),
                ),
                SizedBox(
                  width: width,
                  child: FinanceiroWebMetricCard(
                    label: 'Entradas',
                    value: loja.entradasTexto,
                  ),
                ),
                SizedBox(
                  width: width,
                  child: FinanceiroWebMetricCard(
                    label: 'Saídas',
                    value: loja.saidasTexto,
                    color: const Color(0xFFC62828),
                  ),
                ),
                SizedBox(
                  width: width,
                  child: FinanceiroWebMetricCard(
                    label: 'A pagar',
                    value: financeiroWebReais(loja.aPagar),
                    color: const Color(0xFFC62828),
                  ),
                ),
                SizedBox(
                  width: width,
                  child: FinanceiroWebMetricCard(
                    label: 'A receber',
                    value: financeiroWebReais(loja.aReceber),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        _fluxo(loja),
        const SizedBox(height: 12),
        _recentes(recentes, loja.carregando),
      ],
    );
  }

  Widget _fluxo(FinanceiroLoja loja) {
    return FinanceiroWebPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FinanceiroWebSectionTitle(
            'Fluxo de caixa realizado',
            trailing: TextButton(
              onPressed: aoVerExtrato,
              child: const Text('Ver extrato'),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Entradas e saídas no período',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 12,
              color: Color(0xFF8A8A8A),
            ),
          ),
          const SizedBox(height: 16),
          _FluxoCaixaChart(
            entradas: loja.barrasFluxo,
            saidas: loja.barrasSaidasFluxo,
            rotulos: loja.rotulosFluxo,
          ),
          const SizedBox(height: 14),
          const Row(
            children: [
              _Legenda(cor: MyColors.colorPrimary, rotulo: 'Entradas'),
              SizedBox(width: 16),
              _Legenda(cor: Color(0xFFC45C4A), rotulo: 'Saídas'),
            ],
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: FinanceiroWebPrimaryButton(
              label: 'Novo lançamento',
              onPressed: aoNovoLancamento,
            ),
          ),
        ],
      ),
    );
  }

  Widget _recentes(List<LancamentoMock> recentes, bool carregando) {
    return FinanceiroWebPanel(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: FinanceiroWebSectionTitle('Últimas movimentações'),
          ),
          if (carregando && recentes.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: LoadingFinanceiro(altura: 80),
            )
          else if (recentes.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: FinanceiroWebEmpty(
                message: 'Nenhum movimento no período.',
              ),
            )
          else
            for (var i = 0; i < recentes.length; i++) ...[
              if (i > 0) const Divider(height: 1, color: financeiroWebBorda),
              InkWell(
                onTap: () => aoAbrir(recentes[i]),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        recentes[i].entrada
                            ? Icons.south_west
                            : Icons.north_east,
                        size: 16,
                        color: recentes[i].entrada
                            ? MyColors.colorPrimary
                            : const Color(0xFFC62828),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              recentes[i].titulo,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              recentes[i].dataCurta,
                              style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 12,
                                color: Color(0xFF8A8A8A),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        financeiroWebReais(recentes[i].valor),
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
        ],
      ),
    );
  }
}

class _FluxoCaixaChart extends StatelessWidget {
  const _FluxoCaixaChart({
    required this.entradas,
    required this.saidas,
    required this.rotulos,
  });

  final List<double> entradas;
  final List<double> saidas;
  final List<String> rotulos;

  int get _len => math.max(entradas.length, math.max(saidas.length, 1));

  bool get _temDados {
    for (final v in entradas) {
      if (v > 0) return true;
    }
    for (final v in saidas) {
      if (v > 0) return true;
    }
    return false;
  }

  double get _maxY {
    var max = 0.0;
    for (final v in entradas) {
      max = math.max(max, v);
    }
    for (final v in saidas) {
      max = math.max(max, v);
    }
    if (max <= 0) return 4;
    return max * 1.2;
  }

  String _rotulo(int index) {
    if (index >= 0 && index < rotulos.length) return rotulos[index];
    return '${index + 1}';
  }

  String _fmt(double value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(value >= 10000 ? 0 : 1)}k';
    return value.toStringAsFixed(value == value.roundToDouble() ? 0 : 1);
  }

  @override
  Widget build(BuildContext context) {
    if (!_temDados) {
      return const SizedBox(
        height: 220,
        child: FinanceiroWebEmpty(
          message: 'Sem movimento de caixa no período.',
        ),
      );
    }

    final maxY = _maxY;
    final interval = maxY / 4;
    final count = _len;
    final showSaidas = saidas.any((v) => v > 0);
    final barWidth = count > 10 ? 6.0 : (count > 6 ? 8.0 : 11.0);

    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          minY: 0,
          alignment: BarChartAlignment.spaceAround,
          groupsSpace: 10,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: interval,
            getDrawingHorizontalLine: (_) => const FlLine(
              color: Color(0xFFE8E4D9),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: interval,
                getTitlesWidget: (value, _) {
                  if (value < 0 || value > maxY * 1.01) {
                    return const SizedBox.shrink();
                  }
                  return Text(
                    _fmt(value),
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 10,
                      color: Color(0xFF8A8A8A),
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                getTitlesWidget: (value, _) {
                  final index = value.toInt();
                  if (index < 0 || index >= count) {
                    return const SizedBox.shrink();
                  }
                  // Evita poluir o eixo com muitos rótulos.
                  final step = count > 12 ? 2 : 1;
                  if (index % step != 0 && index != count - 1) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      _rotulo(index),
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6B6B6B),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => const Color(0xFF1F3D2A),
              getTooltipItem: (group, _, rod, rodIndex) {
                final label = rodIndex == 0 ? 'Entradas' : 'Saídas';
                return BarTooltipItem(
                  '${_rotulo(group.x)}\n$label ${financeiroWebReais(rod.toY)}',
                  const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Montserrat',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
          ),
          barGroups: [
            for (var i = 0; i < count; i++)
              BarChartGroupData(
                x: i,
                barsSpace: 3,
                barRods: [
                  BarChartRodData(
                    toY: i < entradas.length ? entradas[i] : 0,
                    width: barWidth,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(5),
                    ),
                    color: MyColors.colorPrimary,
                  ),
                  if (showSaidas)
                    BarChartRodData(
                      toY: i < saidas.length ? saidas[i] : 0,
                      width: barWidth,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(5),
                      ),
                      color: const Color(0xFFC45C4A),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _Legenda extends StatelessWidget {
  const _Legenda({required this.cor, required this.rotulo});

  final Color cor;
  final String rotulo;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: cor,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          rotulo,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6B6B6B),
          ),
        ),
      ],
    );
  }
}
