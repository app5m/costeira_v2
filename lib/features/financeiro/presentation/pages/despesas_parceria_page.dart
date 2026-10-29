import 'package:costeira/features/financeiro/domain/financeiro_mock.dart';
import 'package:costeira/features/financeiro/presentation/widgets/financeiro_ui.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';

enum _FiltroDespesa { todas, pendentes, pagas }

class DespesasParceriaPage extends StatefulWidget {
  const DespesasParceriaPage({
    super.key,
    required this.parceriaId,
    required this.aoVoltar,
    required this.aoAdicionar,
    required this.aoAbrir,
  });

  final int parceriaId;
  final VoidCallback aoVoltar;
  final VoidCallback aoAdicionar;
  final ValueChanged<TituloParceriaFin> aoAbrir;

  @override
  State<DespesasParceriaPage> createState() => _DespesasParceriaPageState();
}

class _DespesasParceriaPageState extends State<DespesasParceriaPage> {
  _FiltroDespesa _filtro = _FiltroDespesa.todas;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FinanceiroEscopo.of(context).carregarParceria(widget.parceriaId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final loja = FinanceiroEscopo.of(context);
    final parceria = loja.parceriaDetalhe?.id == widget.parceriaId
        ? loja.parceriaDetalhe
        : loja.parcerias.where((e) => e.id == widget.parceriaId).firstOrNull;
    final despesas = parceria?.despesas ?? const <TituloParceriaFin>[];
    final filtradas = [
      for (final item in despesas)
        if (_filtro == _FiltroDespesa.todas ||
            (_filtro == _FiltroDespesa.pendentes && item.pendente) ||
            (_filtro == _FiltroDespesa.pagas && !item.pendente))
          item,
    ];

    return Scaffold(
      backgroundColor: fundoFinanceiro,
      appBar: AppBar(
        backgroundColor: MyColors.colorPrimary,
        foregroundColor: Colors.white,
        title: const Text('Despesas', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.aoVoltar),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: widget.aoAdicionar,
        backgroundColor: MyColors.colorPrimary,
        tooltip: 'Adicionar despesa',
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
        children: [
          if (parceria != null) ...[
            Row(
              children: [
                Expanded(
                  child: IndicadorFaixaFinanceiro(
                    rotulo: 'Total',
                    valor: reais(parceria.totalDespesas),
                    fundo: const Color(0xFFF3F1EA),
                    letra: const Color(0xFF3D5346),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: IndicadorFaixaFinanceiro(
                    rotulo: 'A pagar',
                    valor: reais(parceria.saldoAPagarDespesas),
                    fundo: const Color(0xFFFDECEC),
                    letra: const Color(0xFFC62828),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          GrupoChips(
            opcoes: const ['Todas', 'Pendentes', 'Pagas'],
            selecionado: switch (_filtro) {
              _FiltroDespesa.todas => 'Todas',
              _FiltroDespesa.pendentes => 'Pendentes',
              _FiltroDespesa.pagas => 'Pagas',
            },
            aoEscolher: (rotulo) => setState(() {
              _filtro = switch (rotulo) {
                'Pendentes' => _FiltroDespesa.pendentes,
                'Pagas' => _FiltroDespesa.pagas,
                _ => _FiltroDespesa.todas,
              };
            }),
          ),
          const SizedBox(height: 12),
          if (loja.carregandoParcerias && parceria == null)
            const LoadingFinanceiro(altura: 160, rotulo: 'Carregando despesas…')
          else if (filtradas.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Text(
                'Nenhuma despesa neste filtro.',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Montserrat', color: Color(0xFF8A8A8A)),
              ),
            )
          else
            for (final item in filtradas) ...[
              CartaoBranco(
                aoToque: () => widget.aoAbrir(item),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0x1400823A),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.receipt_long_outlined, color: MyColors.colorPrimary, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  item.descricao.isEmpty
                                      ? (item.categoriaNome ?? 'Despesa #${item.id}')
                                      : item.descricao,
                                  style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                item.valorString?.trim().isNotEmpty == true
                                    ? item.valorString!
                                    : reais(item.valor),
                                style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          FlagStatusFinanceiro.titulo(
                            pago: item.pago,
                            parcial: item.parcial,
                            pendente: item.pendente,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            [
                              if (item.dataCompetencia.isNotEmpty) item.dataCompetencia,
                              if (item.classificacaoNome != null && item.classificacaoNome!.isNotEmpty)
                                item.classificacaoNome!,
                              if (item.categoriaNome != null && item.categoriaNome!.isNotEmpty) item.categoriaNome!,
                            ].join(' · '),
                            style: const TextStyle(fontFamily: 'Montserrat', fontSize: 12, color: Color(0xFF8A8A8A)),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            [
                              if (item.parteNome != null && item.parteNome!.isNotEmpty)
                                item.parteNome!
                              else
                                'Sem fornecedor',
                              () {
                                final qtd = item.qtdAnimais ??
                                    parceria?.qtdAnimaisDoLancamento(item.id) ??
                                    0;
                                return qtd > 0
                                    ? '$qtd ${qtd == 1 ? 'animal' : 'animais'}'
                                    : null;
                              }(),
                            ].whereType<String>().join(' · '),
                            style: const TextStyle(fontFamily: 'Montserrat', fontSize: 12, color: Color(0xFF8A8A8A)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
        ],
      ),
    );
  }
}
