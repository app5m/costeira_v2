import 'package:costeira/features/financeiro/domain/financeiro_mock.dart';
import 'package:costeira/features/financeiro/presentation/web/widgets/financeiro_web_ui.dart';
import 'package:costeira/features/financeiro/presentation/widgets/financeiro_ui.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class FinanceiroLancamentosWeb extends StatefulWidget {
  const FinanceiroLancamentosWeb({
    super.key,
    required this.aoAbrir,
    required this.aoNovo,
  });

  final ValueChanged<LancamentoMock> aoAbrir;
  final VoidCallback aoNovo;

  @override
  State<FinanceiroLancamentosWeb> createState() =>
      _FinanceiroLancamentosWebState();
}

class _FinanceiroLancamentosWebState extends State<FinanceiroLancamentosWeb> {
  String _filtro = 'Todos';
  String _busca = '';

  @override
  Widget build(BuildContext context) {
    final loja = FinanceiroEscopo.of(context);
    final itens = loja.lancamentos.where((item) {
      final casa =
          _filtro == 'Todos' ||
          (_filtro == 'A pagar' && !item.entrada) ||
          (_filtro == 'A receber' && item.entrada);
      final texto = '${item.titulo} ${item.rubrica}'.toLowerCase();
      return casa && (_busca.isEmpty || texto.contains(_busca.toLowerCase()));
    }).toList();
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final padding = MediaQuery.sizeOf(context).width < 760 ? 16.0 : 28.0;

    if (loja.carregando && loja.lancamentos.isEmpty) {
      return const Center(child: LoadingFinanceiro(altura: 280));
    }

    return Column(
      children: [
        FinanceiroWebToolbar(
          title: itens.length == 1
              ? '1 lançamento'
              : '${itens.length} lançamentos',
          subtitle: 'Busque, filtre e abra o detalhe',
          actions: [
            FinanceiroWebPrimaryButton(
              label: 'Novo lançamento',
              onPressed: widget.aoNovo,
            ),
          ],
        ),
        const Divider(height: 1, color: financeiroWebBorda),
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(padding, 20, padding, 32),
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final estreito = constraints.maxWidth < 720;
                  final busca = ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: estreito ? constraints.maxWidth : 320,
                    ),
                    child: TextField(
                      onChanged: (v) => setState(() => _busca = v),
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 13,
                      ),
                      decoration: decoracaoCampo(
                        'Buscar descrição ou documento',
                      ).copyWith(
                        isDense: true,
                        prefixIcon: const Icon(
                          LucideIcons.search,
                          size: 16,
                          color: Color(0xFF8A8A8A),
                        ),
                        prefixIconConstraints: const BoxConstraints(
                          minWidth: 40,
                          minHeight: 40,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                    ),
                  );
                  final chips = GrupoChips(
                    opcoes: const ['Todos', 'A pagar', 'A receber'],
                    selecionado: _filtro,
                    aoEscolher: (v) => setState(() => _filtro = v),
                  );
                  if (estreito) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        busca,
                        const SizedBox(height: 12),
                        chips,
                      ],
                    );
                  }
                  return Row(
                    children: [
                      busca,
                      const SizedBox(width: 16),
                      Expanded(child: chips),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FinanceiroWebMetricCard(
                      label: 'A pagar',
                      value: financeiroWebReais(loja.aPagar),
                      color: const Color(0xFFC62828),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FinanceiroWebMetricCard(
                      label: 'A receber',
                      value: financeiroWebReais(loja.aReceber),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (itens.isEmpty)
                const FinanceiroWebEmpty(
                  message: 'Nenhum lançamento encontrado.',
                )
              else if (wide)
                FinanceiroWebPanel(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      const FinanceiroWebTableHeader(
                        columns: [
                          ('Descrição', 4),
                          ('Tipo', 2),
                          ('Valor', 2),
                          ('Situação', 2),
                        ],
                      ),
                      for (var i = 0; i < itens.length; i++) ...[
                        if (i > 0)
                          const Divider(height: 1, color: financeiroWebBorda),
                        InkWell(
                          onTap: () => widget.aoAbrir(itens[i]),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        itens[i].titulo,
                                        style: const TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Text(
                                        itens[i].subtitulo,
                                        style: const TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontSize: 12,
                                          color: Color(0xFF8A8A8A),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    itens[i].entrada
                                        ? 'Recebimento'
                                        : 'Pagamento',
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w600,
                                      color: itens[i].entrada
                                          ? MyColors.colorPrimary
                                          : const Color(0xFFC62828),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    financeiroWebReais(itens[i].valor),
                                    style: const TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: FinanceiroWebStatusChip(
                                      itens[i].situacao,
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
                for (final item in itens) ...[
                  FinanceiroWebPanel(
                    child: InkWell(
                      onTap: () => widget.aoAbrir(item),
                      child: Row(
                        children: [
                          Icon(
                            item.entrada
                                ? Icons.south_west
                                : Icons.north_east,
                            color: item.entrada
                                ? MyColors.colorPrimary
                                : const Color(0xFFC62828),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.titulo,
                                  style: const TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  item.subtitulo,
                                  style: const TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 12,
                                    color: Color(0xFF8A8A8A),
                                  ),
                                ),
                                Text(
                                  financeiroWebReais(item.valor),
                                  style: const TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          FinanceiroWebStatusChip(item.situacao),
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
