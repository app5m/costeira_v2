import 'package:costeira/features/financeiro/domain/financeiro_mock.dart';
import 'package:costeira/features/financeiro/presentation/widgets/financeiro_ui.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';

class VisaoGeralPage extends StatelessWidget {
  const VisaoGeralPage({
    super.key,
    required this.aoVerExtrato,
    required this.aoAbrir,
  });

  final VoidCallback aoVerExtrato;
  final ValueChanged<LancamentoMock> aoAbrir;

  @override
  Widget build(BuildContext context) {
    final loja = FinanceiroEscopo.of(context);
    final recentes = loja.lancamentos.take(4).toList();
    final carregando = loja.carregando;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
      children: [
        const ContextoFinanceiroFiltros(),
        const SizedBox(height: 12),
        if (carregando && recentes.isEmpty) ...[
          const LoadingFinanceiro(
            altura: 220,
            rotulo: 'Carregando movimentações…',
          ),
        ] else ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: IndicadorMiniFinanceiro(
                  'Saldo disponível',
                  loja.saldoTexto,
                  MyColors.colorPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: IndicadorMiniFinanceiro(
                  'Entradas',
                  loja.entradasTexto,
                  MyColors.colorPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: IndicadorMiniFinanceiro(
                  'Saídas',
                  loja.saidasTexto,
                  const Color(0xFFC62828),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          CartaoBranco(child: _BarrasFluxo(valores: loja.barrasFluxo)),
          const SizedBox(height: 12),
          CartaoBranco(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pendências a pagar e receber',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'A pagar ${reais(loja.aPagar)}',
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    color: Color(0xFFC62828),
                  ),
                ),
                Text(
                  'A receber ${reais(loja.aReceber)}',
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    color: MyColors.colorPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Últimas movimentações',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
              TextButton(
                onPressed: aoVerExtrato,
                child: const Text('Ver extrato'),
              ),
            ],
          ),
          if (carregando)
            const LoadingFinanceiro(altura: 96, rotulo: 'Atualizando…')
          else if (recentes.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'Nenhum movimento no período.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 13,
                  color: Color(0xFF8692A8),
                ),
              ),
            )
          else
            for (final item in recentes) ...[
              CartaoBranco(
                aoToque: () => aoAbrir(item),
                child: Row(
                  children: [
                    Icon(
                      item.entrada ? Icons.south_west : Icons.north_east,
                      size: 16,
                      color: item.entrada
                          ? MyColors.colorPrimary
                          : const Color(0xFFC62828),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.titulo,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      reais(item.valor),
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
        ],
      ],
    );
  }
}

class _BarrasFluxo extends StatelessWidget {
  const _BarrasFluxo({required this.valores});

  final List<double> valores;

  @override
  Widget build(BuildContext context) {
    final barras = valores.isEmpty ? const [0.0] : valores;
    final topo = barras.reduce((a, b) => a > b ? a : b);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fluxo de caixa realizado',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 72,
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
                        height: topo == 0 ? 4 : (v / topo) * 72,
                        decoration: BoxDecoration(
                          color: MyColors.colorPrimary.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
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

class RelatoriosPage extends StatelessWidget {
  const RelatoriosPage({super.key, required this.aoAbrir});

  final ValueChanged<String> aoAbrir;

  @override
  Widget build(BuildContext context) {
    const itens = [
      ('extrato', 'Extrato / Livro caixa', 'Movimentos de caixa do ano'),
      ('fluxo', 'Fluxo de caixa', 'Saldo, entradas e meses'),
      ('dre', 'DRE', 'Livro caixa, financeira e econômica'),
      ('resultado', 'Resultado por categoria', 'Cabeças, custos e resultado'),
      ('investidor', 'Por investidor', 'Contratos e entradas de parceria'),
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        for (final item in itens) ...[
          CartaoBranco(
            aoToque: () => aoAbrir(item.$1),
            child: Row(
              children: [
                Icon(
                  item.$1 == 'investidor'
                      ? Icons.handshake_outlined
                      : Icons.insert_chart_outlined,
                  color: MyColors.colorPrimary,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.$2,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        item.$3,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 12,
                          color: Color(0xFF8A8A8A),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF8A8A8A),
                  size: 18,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}
