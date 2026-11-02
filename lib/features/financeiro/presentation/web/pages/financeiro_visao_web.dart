import 'package:costeira/features/financeiro/domain/financeiro_mock.dart';
import 'package:costeira/features/financeiro/presentation/web/widgets/financeiro_web_ui.dart';
import 'package:costeira/features/financeiro/presentation/widgets/financeiro_ui.dart';
import 'package:costeira/theme/colors.dart';
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
    final wide = MediaQuery.sizeOf(context).width >= 980;
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
            final gap = 12.0;
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
        if (wide)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 5, child: _fluxo(loja)),
                const SizedBox(width: 12),
                Expanded(flex: 4, child: _recentes(recentes, loja.carregando)),
              ],
            ),
          )
        else ...[
          _fluxo(loja),
          const SizedBox(height: 12),
          _recentes(recentes, loja.carregando),
        ],
      ],
    );
  }

  Widget _fluxo(FinanceiroLoja loja) {
    final barras = loja.barrasFluxo.isEmpty ? const [0.0] : loja.barrasFluxo;
    final topo = barras.reduce((a, b) => a > b ? a : b);
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
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final v in barras)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: topo == 0 ? 4 : (v / topo) * 140,
                          decoration: BoxDecoration(
                            color: MyColors.colorPrimary.withValues(
                              alpha: 0.85,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
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
