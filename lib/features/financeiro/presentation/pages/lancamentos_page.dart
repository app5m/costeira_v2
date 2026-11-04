import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/components/adaptive_selection_modal.dart';
import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/core/components/custom_button.dart';
import 'package:costeira/core/input_formatters/brazilian_currency_input_formatter.dart';
import 'package:costeira/features/financeiro/domain/financeiro_mock.dart';
import 'package:costeira/features/financeiro/presentation/widgets/financeiro_ui.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class LancamentosPage extends StatefulWidget {
  const LancamentosPage({super.key, required this.aoAbrir});

  final ValueChanged<LancamentoMock> aoAbrir;

  @override
  State<LancamentosPage> createState() => _LancamentosPageState();
}

class _LancamentosPageState extends State<LancamentosPage> {
  String _filtro = 'Todos';
  String _busca = '';

  @override
  Widget build(BuildContext context) {
    final loja = FinanceiroEscopo.of(context);
    final itens = loja.lancamentos.where((item) {
      final casa = _filtro == 'Todos' ||
          (_filtro == 'A pagar' && !item.entrada) ||
          (_filtro == 'A receber' && item.entrada);
      final texto = '${item.titulo} ${item.rubrica}'.toLowerCase();
      return casa && (_busca.isEmpty || texto.contains(_busca.toLowerCase()));
    }).toList();

    if (loja.carregando && loja.lancamentos.isEmpty) {
      return const LoadingFinanceiro(altura: 320, rotulo: 'Carregando lançamentos…');
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
      children: [
        TextField(
          onChanged: (v) => setState(() => _busca = v),
          style: const TextStyle(fontFamily: 'Montserrat', fontSize: 13),
          decoration: decoracaoCampo('Buscar descrição ou documento'),
        ),
        const SizedBox(height: 10),
        GrupoChips(
          opcoes: const ['Todos', 'A pagar', 'A receber'],
          selecionado: _filtro,
          aoEscolher: (v) => setState(() => _filtro = v),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: IndicadorMiniFinanceiro('A pagar', reais(loja.aPagar), const Color(0xFFC62828))),
            const SizedBox(width: 8),
            Expanded(child: IndicadorMiniFinanceiro('A receber', reais(loja.aReceber), MyColors.colorPrimary)),
          ],
        ),
        const SizedBox(height: 12),
        if (loja.carregando)
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: LoadingFinanceiro(altura: 48, rotulo: 'Atualizando…'),
          ),
        for (final item in itens) ...[
          CartaoBranco(
            aoToque: () => widget.aoAbrir(item),
            child: Row(
              children: [
                Icon(
                  item.entrada ? Icons.south_west : Icons.north_east,
                  color: item.entrada ? MyColors.colorPrimary : const Color(0xFFC62828),
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.titulo,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
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
                        reais(item.valor),
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                _Selo(item.situacao),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

}

class _Selo extends StatelessWidget {
  const _Selo(this.situacao);

  final SituacaoLancamento situacao;

  @override
  Widget build(BuildContext context) {
    final (rotulo, fundo, letra) = switch (situacao) {
      SituacaoLancamento.parcial => ('Parcial', const Color(0xFFFFF4E5), const Color(0xFFB86E00)),
      SituacaoLancamento.liquidado => ('Liquidado', const Color(0xFFE7F6EC), MyColors.colorPrimary),
      SituacaoLancamento.pendente => ('Pendente', const Color(0xFFFDECEC), const Color(0xFFC62828)),
      SituacaoLancamento.rascunho => ('Rascunho', const Color(0xFFF3F6F4), const Color(0xFF3D5346)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: fundo,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        rotulo,
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: letra,
        ),
      ),
    );
  }
}

class LancamentoDetalhePage extends StatelessWidget {
  const LancamentoDetalhePage({
    super.key,
    required this.item,
    required this.aoVoltar,
    required this.aoBaixa,
    required this.aoEditar,
    required this.aoEstornar,
    required this.aoEstornarPagamento,
  });

  final LancamentoMock item;
  final VoidCallback aoVoltar;
  final VoidCallback aoBaixa;
  final VoidCallback aoEditar;
  final Future<void> Function({required String data, required String motivo}) aoEstornar;
  final Future<void> Function({required String data, required String motivo, int? baixaId}) aoEstornarPagamento;

  @override
  Widget build(BuildContext context) {
    final atual = FinanceiroEscopo.of(context).lancamentos.firstWhere(
      (l) => l.id == item.id,
      orElse: () => item,
    );
    final temBaixa = atual.temLiquidacao;
    final podeBaixa = atual.pendente > 0.001 &&
        atual.situacao != SituacaoLancamento.rascunho &&
        atual.estado != 'estornado';
    final podeEstornarAjuste = atual.ehAjusteConta &&
        atual.estado != 'estornado' &&
        atual.situacao != SituacaoLancamento.rascunho;
    final podeEstornarLancamento = !atual.ehAjusteConta &&
        !temBaixa &&
        atual.estado != 'estornado' &&
        atual.situacao != SituacaoLancamento.rascunho;
    final tituloHero = atual.rubrica.trim().isNotEmpty ? atual.rubrica : atual.titulo;
    final corValor = atual.entrada ? MyColors.colorPrimary : const Color(0xFF1F2A24);
    final icone = iconePorTextoFinanceiro(atual.rubrica.isEmpty ? atual.categoria : atual.rubrica);

    return Scaffold(
      backgroundColor: fundoFinanceiro,
      appBar: AppBar(
        backgroundColor: MyColors.colorPrimary,
        foregroundColor: Colors.white,
        title: const Text(
          'Detalhe do lançamento',
          style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600),
        ),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: aoVoltar),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          CartaoBranco(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF0E6),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(icone, color: const Color(0xFFC45C26)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tituloHero,
                            style: const TextStyle(fontFamily: 'Montserrat', fontSize: 17, fontWeight: FontWeight.w700),
                          ),
                          Text(
                            '${atual.dataCurta} · ${atual.categoria}',
                            style: const TextStyle(fontFamily: 'Montserrat', fontSize: 12, color: Color(0xFF8A8A8A)),
                          ),
                          if (atual.descricao.trim().isNotEmpty && atual.descricao != tituloHero) ...[
                            const SizedBox(height: 2),
                            Text(
                              atual.descricao,
                              style: const TextStyle(fontFamily: 'Montserrat', fontSize: 12, color: Color(0xFF6B6B6B)),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (atual.estado.isNotEmpty) _selo(_rotuloEstado(atual.estado), MyColors.colorPrimary, const Color(0xFFE7F6EC)),
                    _selo(_rotuloSituacao(atual.situacao), _corSituacao(atual.situacao), _fundoSituacao(atual.situacao)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  reais(atual.valor),
                  style: TextStyle(fontFamily: 'Montserrat', fontSize: 28, fontWeight: FontWeight.w800, color: corValor),
                ),
                const SizedBox(height: 10),
                _linha('Liquidado', reais(atual.liquidado), valorCor: MyColors.colorPrimary),
                _linha('Pendente', reais(atual.pendente), valorCor: atual.pendente > 0 ? const Color(0xFFC45C26) : null),
                _linha('Competência', atual.competencia),
                if (_rotuloParteInvestidor(atual) != null)
                  _linha('Investidor', _rotuloParteInvestidor(atual)!)
                else if (atual.fornecedor != null)
                  _linha('Fornecedor', atual.fornecedor!),
                if (atual.comprador != null) _linha('Comprador', atual.comprador!),
              ],
            ),
          ),
          if (atual.alocacao.isNotEmpty) ...[
            const SizedBox(height: 12),
            CartaoBranco(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SecaoRotulo('ALOCAÇÃO'),
                  const SizedBox(height: 8),
                  for (final parte in atual.alocacao)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE7F6EC),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.pets_outlined, color: MyColors.colorPrimary, size: 18),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(parte.nome, style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600)),
                                if (parte.percentual > 0)
                                  Text(
                                    '${parte.percentual.toStringAsFixed(0)}%',
                                    style: const TextStyle(fontFamily: 'Montserrat', fontSize: 11, color: Color(0xFF8A8A8A)),
                                  ),
                              ],
                            ),
                          ),
                          Text(reais(parte.valor), style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
          if (atual.pagamentos.isNotEmpty) ...[
            const SizedBox(height: 12),
            CartaoBranco(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SecaoRotulo('PAGAMENTOS'),
                  const SizedBox(height: 8),
                  for (final pag in atual.pagamentos) ...[
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${pag.data} · ${pag.conta}',
                            style: const TextStyle(fontFamily: 'Montserrat', fontSize: 13),
                          ),
                        ),
                        Text(
                          reais(pag.valor),
                          style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700, color: MyColors.colorPrimary),
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () => _pedirEstorno(
                          context,
                          titulo: 'Estornar baixa',
                          motivoPadrao: 'Estorno da baixa',
                          aoConfirmar: ({required data, required motivo}) =>
                              aoEstornarPagamento(data: data, motivo: motivo, baixaId: pag.id),
                        ),
                        icon: const Icon(Icons.undo_rounded, size: 16, color: MyColors.colorPrimary),
                        label: const Text(
                          'Estornar baixa',
                          style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600, color: MyColors.colorPrimary),
                        ),
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          CartaoBranco(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SecaoRotulo('HISTÓRICO'),
                const SizedBox(height: 8),
                if (atual.historico.isEmpty)
                  const Text(
                    'Sem eventos registrados.',
                    style: TextStyle(fontFamily: 'Montserrat', fontSize: 12, color: Color(0xFF8A8A8A)),
                  )
                else
                  for (var i = 0; i < atual.historico.length; i++)
                    _eventoHistorico(
                      atual.historico[i],
                      ultimo: i == atual.historico.length - 1,
                      pagamento: atual.historico[i].toLowerCase().contains('pagamento'),
                    ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: RodapeAcoesFinanceiro(
        filhos: [
          if (podeEstornarAjuste)
            OutlinedButton(
              onPressed: () => _pedirEstorno(
                context,
                titulo: 'Estornar ajuste de saldo',
                motivoPadrao: 'Estorno do ajuste de saldo',
                aoConfirmar: aoEstornar,
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                foregroundColor: const Color(0xFFC62828),
                side: const BorderSide(color: Color(0xFFE0B4B4)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Estornar ajuste',
                style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600),
              ),
            )
          else if (podeEstornarLancamento)
            OutlinedButton(
              onPressed: () => _pedirEstorno(
                context,
                titulo: 'Estornar lançamento',
                motivoPadrao: 'Estorno do lançamento',
                aoConfirmar: aoEstornar,
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                foregroundColor: const Color(0xFFC62828),
                side: const BorderSide(color: Color(0xFFE0B4B4)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Estornar lançamento',
                style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600),
              ),
            )
          else if (temBaixa && atual.estado != 'estornado')
            Column(
              children: [
                OutlinedButton.icon(
                  onPressed: null,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    side: const BorderSide(color: Color(0xFFF0C7C7)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.lock_outline, color: Color(0xFFC62828), size: 18),
                  label: const Text(
                    'Estornar lançamento',
                    style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600, color: Color(0xFFC62828)),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Primeiro estorne o pagamento existente.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'Montserrat', fontSize: 12, color: Color(0xFF8A8A8A)),
                ),
              ],
            ),
          if (atual.situacao == SituacaoLancamento.rascunho)
            BotaoPrimarioFinanceiro(rotulo: 'Editar rascunho', onPressed: aoEditar)
          else if (podeBaixa)
            BotaoPrimarioFinanceiro(rotulo: 'Registrar baixa', onPressed: aoBaixa),
        ],
      ),
    );
  }

  String _rotuloEstado(String estado) {
    switch (estado) {
      case 'confirmado':
        return 'Confirmado';
      case 'rascunho':
        return 'Rascunho';
      case 'estornado':
        return 'Estornado';
      case 'cancelado':
        return 'Cancelado';
      default:
        return estado.isEmpty ? '' : '${estado[0].toUpperCase()}${estado.substring(1)}';
    }
  }

  String _rotuloSituacao(SituacaoLancamento situacao) {
    switch (situacao) {
      case SituacaoLancamento.parcial:
        return 'Parcial';
      case SituacaoLancamento.liquidado:
        return 'Liquidado';
      case SituacaoLancamento.pendente:
        return 'Pendente';
      case SituacaoLancamento.rascunho:
        return 'Rascunho';
    }
  }

  Color _corSituacao(SituacaoLancamento situacao) {
    switch (situacao) {
      case SituacaoLancamento.parcial:
        return const Color(0xFFC45C26);
      case SituacaoLancamento.liquidado:
        return MyColors.colorPrimary;
      case SituacaoLancamento.pendente:
        return const Color(0xFFB8860B);
      case SituacaoLancamento.rascunho:
        return const Color(0xFF6B6B6B);
    }
  }

  Color _fundoSituacao(SituacaoLancamento situacao) {
    switch (situacao) {
      case SituacaoLancamento.parcial:
        return const Color(0xFFFFF0E6);
      case SituacaoLancamento.liquidado:
        return const Color(0xFFE7F6EC);
      case SituacaoLancamento.pendente:
        return const Color(0xFFFFF7E0);
      case SituacaoLancamento.rascunho:
        return const Color(0xFFF0F0F0);
    }
  }

  Widget _selo(String texto, Color cor, Color fundo) {
    if (texto.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: fundo, borderRadius: BorderRadius.circular(20)),
      child: Text(
        texto,
        style: TextStyle(fontFamily: 'Montserrat', fontSize: 11, fontWeight: FontWeight.w700, color: cor),
      ),
    );
  }

  Widget _eventoHistorico(String linha, {required bool ultimo, required bool pagamento}) {
    return Padding(
      padding: EdgeInsets.only(bottom: ultimo ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: pagamento ? const Color(0xFFE7F6EC) : const Color(0xFFE8F0FE),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  pagamento ? Icons.payments_outlined : Icons.check_rounded,
                  size: 15,
                  color: pagamento ? MyColors.colorPrimary : const Color(0xFF2F6FED),
                ),
              ),
              if (!ultimo)
                Container(
                  width: 2,
                  height: 18,
                  margin: const EdgeInsets.only(top: 2),
                  color: const Color(0xFFE6E6E6),
                ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              linha,
              style: const TextStyle(fontFamily: 'Montserrat', fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pedirEstorno(
    BuildContext context, {
    required String titulo,
    required String motivoPadrao,
    required Future<void> Function({required String data, required String motivo}) aoConfirmar,
  }) async {
    final agora = DateTime.now();
    final dataCtrl = TextEditingController(
      text: '${agora.day.toString().padLeft(2, '0')}/${agora.month.toString().padLeft(2, '0')}/${agora.year}',
    );
    final motivoCtrl = TextEditingController(text: motivoPadrao);
    final mascara = mascaraData();
    String? erroLocal;
    var salvando = false;

    try {
      await showAdaptiveSelectionModal<void>(
        context: context,
        title: titulo,
        builder: (embeddedInDialog) {
          return StatefulBuilder(
            builder: (modal, setSheet) {
              return PopScope(
                canPop: !salvando,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    embeddedInDialog ? 8 : 8,
                    20,
                    16 + MediaQuery.of(modal).viewInsets.bottom,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!embeddedInDialog) ...[
                          Text(
                            titulo,
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 6),
                        ],
                        const Text(
                          'Informe a data e o motivo do estorno.',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 13,
                            color: Color(0xFF8692A8),
                          ),
                        ),
                        const SizedBox(height: 14),
                        CampoFinanceiro(
                          rotulo: 'DATA',
                          child: TextField(
                            controller: dataCtrl,
                            enabled: !salvando,
                            keyboardType: tecladoData,
                            inputFormatters: [mascara],
                            decoration: decoracaoCampo('dd/MM/aaaa'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        CampoFinanceiro(
                          rotulo: 'MOTIVO',
                          child: TextField(
                            controller: motivoCtrl,
                            enabled: !salvando,
                            decoration: decoracaoCampo('Motivo do estorno'),
                          ),
                        ),
                        if (erroLocal != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            erroLocal!,
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 12,
                              color: Color(0xFFC62828),
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: salvando ? null : () => Navigator.pop(modal),
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(50),
                                  foregroundColor: const Color(0xFF313131),
                                  side: const BorderSide(color: Color(0xFFD4D9D1)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Cancelar',
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: BotaoPrimarioFinanceiro(
                                rotulo: 'Confirmar estorno',
                                carregando: salvando,
                                habilitado: !salvando,
                                onPressed: () async {
                                  if (dataCtrl.text.trim().length < 10) {
                                    setSheet(() => erroLocal = 'Informe a data.');
                                    return;
                                  }
                                  if (motivoCtrl.text.trim().isEmpty) {
                                    setSheet(() => erroLocal = 'Informe o motivo.');
                                    return;
                                  }
                                  setSheet(() {
                                    salvando = true;
                                    erroLocal = null;
                                  });
                                  try {
                                    await aoConfirmar(
                                      data: dataCtrl.text.trim(),
                                      motivo: motivoCtrl.text.trim(),
                                    );
                                    if (!modal.mounted) return;
                                    Navigator.pop(modal);
                                  } on ApiException catch (error) {
                                    setSheet(() {
                                      salvando = false;
                                      erroLocal = error.message;
                                    });
                                  } catch (error) {
                                    setSheet(() {
                                      salvando = false;
                                      erroLocal = error.toString();
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
    } finally {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        dataCtrl.dispose();
        motivoCtrl.dispose();
      });
    }
  }

  String? _rotuloParteInvestidor(LancamentoMock atual) {
    if (atual.investidor != null && atual.investidor!.trim().isNotEmpty) {
      return atual.investidor!.trim();
    }
    final categoriaId = atual.categoriaId ?? 0;
    if (rubricaParceriaSistema(categoriaId) &&
        atual.fornecedor != null &&
        atual.fornecedor!.trim().isNotEmpty) {
      return atual.fornecedor!.trim();
    }
    return null;
  }

  Widget _linha(String rotulo, String valor, {Color? valorCor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              rotulo,
              style: const TextStyle(fontFamily: 'Montserrat', color: Color(0xFF8A8A8A)),
            ),
          ),
          Text(
            valor,
            style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700, color: valorCor),
          ),
        ],
      ),
    );
  }
}

class RegistrarBaixaPage extends StatefulWidget {
  const RegistrarBaixaPage({
    super.key,
    required this.item,
    required this.aoVoltar,
    required this.aoConfirmar,
  });

  final LancamentoMock item;
  final VoidCallback aoVoltar;
  final Future<void> Function(double valor, String conta, {String? data}) aoConfirmar;

  @override
  State<RegistrarBaixaPage> createState() => _RegistrarBaixaPageState();
}

class _RegistrarBaixaPageState extends State<RegistrarBaixaPage> {
  late final TextEditingController _valor;
  int? _contaId;
  late final TextEditingController _data;
  final _motivo = TextEditingController(text: 'Pagamento do saldo');
  late final MaskTextInputFormatter _mascaraData = mascaraData();
  bool _valorSincronizado = false;
  bool _enviando = false;

  @override
  void initState() {
    super.initState();
    final agora = DateTime.now();
    _valor = TextEditingController(text: BrazilianCurrency.format(widget.item.pendente));
    _valor.addListener(_aoMudarValor);
    _data = TextEditingController(
      text: '${agora.day.toString().padLeft(2, '0')}/${agora.month.toString().padLeft(2, '0')}/${agora.year}',
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_valorSincronizado) return;
    _valorSincronizado = true;
    final atual = _lancamentoAtual(context);
    _valor.text = BrazilianCurrency.format(atual.pendente);
    final contas = FinanceiroEscopo.of(context).contas.where((c) => c.ativa).toList();
    if (_contaId == null && contas.isNotEmpty) {
      _contaId = contas.first.id;
    }
  }

  @override
  void dispose() {
    _valor.removeListener(_aoMudarValor);
    _valor.dispose();
    _data.dispose();
    _motivo.dispose();
    super.dispose();
  }

  void _aoMudarValor() {
    if (mounted) setState(() {});
  }

  LancamentoMock _lancamentoAtual(BuildContext context) {
    return FinanceiroEscopo.of(context).lancamentos.firstWhere(
      (l) => l.id == widget.item.id,
      orElse: () => widget.item,
    );
  }

  ContaMock? _contaAtual(List<ContaMock> contas) {
    for (final conta in contas) {
      if (conta.id == _contaId) return conta;
    }
    return contas.isEmpty ? null : contas.first;
  }

  bool _exigeSaldoConta(LancamentoMock atual) => !atual.entrada;

  bool _saldoInsuficiente(LancamentoMock atual, ContaMock? conta, double? valor) {
    if (!_exigeSaldoConta(atual) || conta == null || valor == null || valor <= 0) return false;
    return conta.saldo + 0.001 < valor;
  }

  @override
  Widget build(BuildContext context) {
    final atual = _lancamentoAtual(context);
    final contas = FinanceiroEscopo.of(context).contas.where((c) => c.ativa).toList();
    final conta = _contaAtual(contas);
    final valorAtual = BrazilianCurrency.parse(_valor.text);
    final saldoInsuficiente = _saldoInsuficiente(atual, conta, valorAtual);
    if (conta != null && conta.id != _contaId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _contaId = conta.id);
      });
    }
    return Scaffold(
      backgroundColor: fundoFinanceiro,
      appBar: AppBar(
        backgroundColor: MyColors.colorPrimary,
        foregroundColor: Colors.white,
        title: const Text(
          'Registrar pagamento',
          style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _enviando ? null : widget.aoVoltar,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            atual.titulo,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            'Valor total ${reais(atual.valor)} · Já liquidado ${reais(atual.liquidado)}',
            style: const TextStyle(fontFamily: 'Montserrat', fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(
            'Saldo pendente ${reais(atual.pendente)}',
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w700,
              color: Color(0xFFB86E00),
            ),
          ),
          const SizedBox(height: 16),
          CampoFinanceiro(
            rotulo: 'CONTA',
            child: contas.isEmpty
                ? const Text(
                    'Nenhuma conta ativa. Cadastre uma conta antes de registrar a baixa.',
                    style: TextStyle(fontFamily: 'Montserrat', fontSize: 13, color: Color(0xFFC62828)),
                  )
                : IgnorePointer(
                    ignoring: _enviando,
                    child: SeletorContaFinanceiro(
                      contas: contas,
                      selecionada: conta,
                      onChanged: (escolhida) => setState(() => _contaId = escolhida.id),
                    ),
                  ),
          ),
          const SizedBox(height: 12),
          CampoFinanceiro(
            rotulo: 'DATA',
            child: TextField(
              controller: _data,
              enabled: !_enviando,
              keyboardType: tecladoData,
              inputFormatters: [_mascaraData],
              decoration: decoracaoCampo('dd/MM/aaaa'),
            ),
          ),
          const SizedBox(height: 12),
          CampoFinanceiro(
            rotulo: 'VALOR DA BAIXA',
            child: TextField(
              controller: _valor,
              enabled: !_enviando,
              keyboardType: tecladoMoeda,
              inputFormatters: const [mascaraMoeda],
              decoration: decoracaoCampo(r'R$ 0,00'),
            ),
          ),
          const SizedBox(height: 12),
          CampoFinanceiro(
            rotulo: 'MOTIVO',
            child: TextField(
              controller: _motivo,
              enabled: !_enviando,
              decoration: decoracaoCampo(''),
            ),
          ),
          const SizedBox(height: 8),
          if (saldoInsuficiente)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFDECEC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF5C2C2)),
              ),
              child: Text(
                conta!.saldo <= 0
                    ? 'Saldo da conta insuficiente (${reais(conta.saldo)}). Escolha outra conta ou registre saldo antes de pagar.'
                    : 'Valor da baixa (${reais(valorAtual!)}) maior que o saldo da conta (${reais(conta.saldo)}).',
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFC62828),
                ),
              ),
            )
          else
            const Text(
              'Você pode pagar parcialmente ou usar outra conta em uma nova baixa.',
              style: TextStyle(fontFamily: 'Montserrat', fontSize: 12, color: Color(0xFF8A8A8A)),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _enviando ? null : widget.aoVoltar,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    foregroundColor: const Color(0xFF313131),
                    side: const BorderSide(color: Color(0xFFD4D9D1)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Voltar',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  enabled: !_enviando &&
                      conta != null &&
                      atual.pendente > 0.001 &&
                      !saldoInsuficiente,
                  isLoading: _enviando,
                  onPressed: () => _confirmar(atual, conta),
                  text: 'Confirmar pagamento',
                  borderRadius: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmar(LancamentoMock atual, ContaMock? conta) async {
    if (_enviando) return;
    final valor = BrazilianCurrency.parse(_valor.text);
    if (valor == null || valor <= 0 || conta == null) return;
    if (valor > atual.pendente + 0.001) {
      AppSnackBar.show(
        context: context,
        message:
            'Valor máximo da baixa: ${reais(atual.pendente)}. Já há ${reais(atual.liquidado)} liquidado.',
      );
      return;
    }
    if (_saldoInsuficiente(atual, conta, valor)) {
      AppSnackBar.show(
        context: context,
        message: 'Saldo da conta insuficiente (${reais(conta.saldo)}).',
      );
      return;
    }
    setState(() => _enviando = true);
    try {
      await widget.aoConfirmar(valor, conta.nome, data: _data.text.trim());
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }
}
