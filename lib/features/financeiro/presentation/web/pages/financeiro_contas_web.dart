import 'package:costeira/features/financeiro/domain/financeiro_mock.dart';
import 'package:costeira/features/financeiro/presentation/web/widgets/financeiro_web_ui.dart';
import 'package:costeira/features/financeiro/presentation/widgets/financeiro_ui.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';

class FinanceiroContasWeb extends StatefulWidget {
  const FinanceiroContasWeb({
    super.key,
    required this.aoAbrir,
    required this.aoNova,
  });

  final ValueChanged<ContaMock> aoAbrir;
  final VoidCallback aoNova;

  @override
  State<FinanceiroContasWeb> createState() => _FinanceiroContasWebState();
}

class _FinanceiroContasWebState extends State<FinanceiroContasWeb> {
  bool _somenteAtivas = true;

  @override
  Widget build(BuildContext context) {
    final loja = FinanceiroEscopo.of(context);
    final contas = loja.contas
        .where((c) => !_somenteAtivas || c.ativa)
        .toList(growable: false);
    final saldo = contas.fold<double>(0, (s, c) => s + c.saldo);
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final padding = MediaQuery.sizeOf(context).width < 760 ? 16.0 : 28.0;

    if (loja.carregando && loja.contas.isEmpty) {
      return const Center(child: LoadingFinanceiro(altura: 280));
    }

    return Column(
      children: [
        FinanceiroWebToolbar(
          title: contas.length == 1 ? '1 conta' : '${contas.length} contas',
          subtitle: 'Saldo consolidado ${financeiroWebReais(saldo)}',
          actions: [
            FinanceiroWebPrimaryButton(
              label: 'Adicionar conta',
              onPressed: widget.aoNova,
            ),
          ],
        ),
        const Divider(height: 1, color: financeiroWebBorda),
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(padding, 20, padding, 32),
            children: [
              GrupoChips(
                opcoes: const ['Ativas', 'Todas'],
                selecionado: _somenteAtivas ? 'Ativas' : 'Todas',
                aoEscolher: (v) =>
                    setState(() => _somenteAtivas = v == 'Ativas'),
              ),
              const SizedBox(height: 16),
              FinanceiroWebMetricCard(
                label: 'Saldo consolidado',
                value: financeiroWebReais(saldo),
              ),
              const SizedBox(height: 16),
              if (contas.isEmpty)
                const FinanceiroWebEmpty(message: 'Nenhuma conta encontrada.')
              else if (wide)
                FinanceiroWebPanel(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      const FinanceiroWebTableHeader(
                        columns: [
                          ('Conta', 4),
                          ('Tipo', 2),
                          ('Saldo', 2),
                          ('Status', 2),
                        ],
                      ),
                      for (var i = 0; i < contas.length; i++) ...[
                        if (i > 0)
                          const Divider(height: 1, color: financeiroWebBorda),
                        InkWell(
                          onTap: () => widget.aoAbrir(contas[i]),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    contas[i].nome,
                                    style: const TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    contas[i].tipo,
                                    style: const TextStyle(
                                      fontFamily: 'Montserrat',
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    financeiroWebReais(contas[i].saldo),
                                    style: const TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    contas[i].ativa ? 'Ativa' : 'Inativa',
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w600,
                                      color: contas[i].ativa
                                          ? MyColors.colorPrimary
                                          : const Color(0xFF8A8A8A),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                )
              else
                for (final conta in contas) ...[
                  FinanceiroWebPanel(
                    child: InkWell(
                      onTap: () => widget.aoAbrir(conta),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  conta.nome,
                                  style: const TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  '${conta.tipo} · ${conta.ativa ? 'Ativa' : 'Inativa'}',
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
                            financeiroWebReais(conta.saldo),
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
            ],
          ),
        ),
      ],
    );
  }
}
