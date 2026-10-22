import 'package:costeira/features/financeiro/domain/financeiro_mock.dart';
import 'package:costeira/features/financeiro/presentation/widgets/financeiro_ui.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';

class VisaoGeralPage extends StatelessWidget {
  const VisaoGeralPage({super.key, required this.aoVerExtrato, required this.aoAbrir});

  final VoidCallback aoVerExtrato;
  final ValueChanged<LancamentoMock> aoAbrir;

  @override
  Widget build(BuildContext context) {
    final loja = FinanceiroEscopo.of(context);
    final recentes = loja.lancamentos.take(4);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
      children: [
        Row(
          children: const [
            Expanded(child: _FiltroPill(icone: Icons.warehouse_outlined, rotulo: 'Fazenda Filial Norte')),
            SizedBox(width: 8),
            Expanded(child: _FiltroPill(icone: Icons.calendar_today_outlined, rotulo: '2026/2027')),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _Mini('Saldo disponível', reais(loja.saldoDisponivel), MyColors.colorPrimary)),
            const SizedBox(width: 8),
            Expanded(child: _Mini('Entradas', reais(8900), MyColors.colorPrimary)),
            const SizedBox(width: 8),
            Expanded(child: _Mini('Saídas', reais(3250), const Color(0xFFC62828))),
          ],
        ),
        const SizedBox(height: 12),
        const CartaoBranco(child: _BarrasFluxo()),
        const SizedBox(height: 12),
        CartaoBranco(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pendências a pagar e receber',
                style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text('A pagar ${reais(loja.aPagar)}', style: const TextStyle(fontFamily: 'Montserrat', color: Color(0xFFC62828))),
              Text('A receber ${reais(loja.aReceber)}', style: const TextStyle(fontFamily: 'Montserrat', color: MyColors.colorPrimary)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Últimos movimentos',
                style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ),
            TextButton(onPressed: aoVerExtrato, child: const Text('Ver extrato')),
          ],
        ),
        for (final item in recentes) ...[
          CartaoBranco(
            aoToque: () => aoAbrir(item),
            child: Row(
              children: [
                Icon(
                  item.entrada ? Icons.south_west : Icons.north_east,
                  size: 16,
                  color: item.entrada ? MyColors.colorPrimary : const Color(0xFFC62828),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(item.titulo, style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600)),
                ),
                Text(reais(item.valor), style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _FiltroPill extends StatelessWidget {
  const _FiltroPill({required this.icone, required this.rotulo});

  final IconData icone;
  final String rotulo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE6E6E6)),
      ),
      child: Row(
        children: [
          Icon(icone, size: 14, color: MyColors.colorPrimary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              rotulo,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontFamily: 'Montserrat', fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _Mini extends StatelessWidget {
  const _Mini(this.rotulo, this.valor, this.cor);

  final String rotulo;
  final String valor;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE6E6E6)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 28,
              child: Text(
                rotulo,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 10,
                  height: 1.25,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8A8A8A),
                ),
              ),
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                valor,
                maxLines: 1,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: cor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BarrasFluxo extends StatelessWidget {
  const _BarrasFluxo();

  @override
  Widget build(BuildContext context) {
    const valores = [40.0, 70.0, 35.0, 90.0, 55.0, 80.0];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fluxo de caixa realizado',
          style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 72,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final v in valores)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: v,
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
  const RelatoriosPage({super.key});

  @override
  Widget build(BuildContext context) {
    const itens = [
      'Extrato / Livro caixa',
      'DRE',
      'Resultado por categoria',
      'Por investidor',
      'Fluxo de caixa detalhado',
    ];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Em desenvolvimento',
          style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700, fontSize: 16),
        ),
        const SizedBox(height: 6),
        const Text(
          'Os relatórios entram quando o fluxo fechar. Por enquanto só a lista.',
          style: TextStyle(fontFamily: 'Montserrat', color: Color(0xFF8A8A8A)),
        ),
        const SizedBox(height: 12),
        for (final item in itens) ...[
          CartaoBranco(
            child: Row(
              children: [
                const Icon(Icons.insert_chart_outlined, color: MyColors.colorPrimary, size: 18),
                const SizedBox(width: 10),
                Expanded(child: Text(item, style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600))),
                const Text('Em breve', style: TextStyle(fontFamily: 'Montserrat', fontSize: 12, color: Color(0xFF8A8A8A))),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}
