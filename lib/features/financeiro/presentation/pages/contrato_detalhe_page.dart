import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/features/financeiro/domain/financeiro_mock.dart';
import 'package:costeira/features/financeiro/presentation/widgets/financeiro_ui.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';

class ContratoDetalhePage extends StatefulWidget {
  const ContratoDetalhePage({
    super.key,
    required this.parceriaId,
    required this.aoVoltar,
    required this.aoRegistrarEntrada,
    required this.aoDespesas,
    required this.aoVendas,
    required this.aoBaixaTitulo,
    required this.aoInativar,
  });

  final int parceriaId;
  final VoidCallback aoVoltar;
  final VoidCallback aoRegistrarEntrada;
  final VoidCallback aoDespesas;
  final VoidCallback aoVendas;
  final ValueChanged<TituloParceriaFin> aoBaixaTitulo;
  final Future<void> Function() aoInativar;

  @override
  State<ContratoDetalhePage> createState() => _ContratoDetalhePageState();
}

class _ContratoDetalhePageState extends State<ContratoDetalhePage> with SingleTickerProviderStateMixin {
  final _abertos = <int>{};
  late final TabController _tabs;
  bool _inativando = false;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _tabs.addListener(() {
      if (mounted) setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FinanceiroEscopo.of(context).carregarParceria(widget.parceriaId);
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  String _pct(String raw) {
    final n = double.tryParse(raw.replaceAll(',', '.'));
    if (n == null) return raw;
    return n == n.roundToDouble() ? '${n.toInt()}%' : '${n.toStringAsFixed(2)}%';
  }

  ParceriaFin? _parceria(FinanceiroLoja loja) {
    if (loja.parceriaDetalhe?.id == widget.parceriaId) return loja.parceriaDetalhe;
    return loja.parcerias.where((e) => e.id == widget.parceriaId).firstOrNull;
  }

  Future<void> _inativar(ParceriaFin parceria) async {
    if (_inativando || !parceria.ativo) return;
    final motivo = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Inativar contrato?', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${parceria.codigo.isEmpty ? 'Contrato #${parceria.id}' : parceria.codigo} será encerrado. Histórico preservado.',
              style: const TextStyle(fontFamily: 'Montserrat', fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: motivo,
              decoration: const InputDecoration(labelText: 'Motivo da inativação'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Voltar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Inativar')),
        ],
      ),
    );
    final texto = motivo.text;
    motivo.dispose();
    if (ok != true || !mounted) return;
    setState(() => _inativando = true);
    try {
      await FinanceiroEscopo.of(context).inativarParceria(
        id: parceria.id,
        motivo: texto.trim().isEmpty ? null : texto.trim(),
      );
      if (!mounted) return;
      await widget.aoInativar();
    } on ApiException catch (error) {
      if (!mounted) return;
      AppSnackBar.show(context: context, message: error.message);
    } finally {
      if (mounted) setState(() => _inativando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loja = FinanceiroEscopo.of(context);
    final parceria = _parceria(loja);
    final titulo = parceria?.codigo.isNotEmpty == true
        ? parceria!.codigo
        : 'Contrato #${widget.parceriaId}';

    return Scaffold(
      backgroundColor: fundoFinanceiro,
      appBar: AppBar(
        backgroundColor: MyColors.colorPrimary,
        foregroundColor: Colors.white,
        title: Text(titulo, style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.aoVoltar),
        actions: [
          if (parceria?.ativo == true)
            IconButton(
              onPressed: _inativando ? null : () => _inativar(parceria!),
              icon: const Icon(Icons.block),
              tooltip: 'Inativar contrato',
            ),
        ],
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700),
          tabs: const [
            Tab(text: 'Entradas'),
            Tab(text: 'Financeiro'),
          ],
        ),
      ),
      floatingActionButton: _tabs.index == 0 && parceria?.ativo == true
          ? FloatingActionButton(
              onPressed: widget.aoRegistrarEntrada,
              backgroundColor: MyColors.colorPrimary,
              tooltip: 'Registrar entrada',
              child: const Icon(Icons.add),
            )
          : null,
      body: parceria == null && loja.carregandoParcerias
          ? const LoadingFinanceiro(altura: 280, rotulo: 'Carregando contrato…')
          : parceria == null
              ? const Center(
                  child: Text(
                    'Contrato não encontrado.',
                    style: TextStyle(fontFamily: 'Montserrat', color: Color(0xFF8A8A8A)),
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: CartaoBranco(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    parceria.investidorNome.isEmpty
                                        ? 'Investidor #${parceria.investidorId}'
                                        : parceria.investidorNome,
                                    style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700),
                                  ),
                                ),
                                FlagStatusFinanceiro(
                                  rotulo: parceria.ativo ? 'Ativo' : 'Inativo',
                                  positivo: parceria.ativo,
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Início ${parceria.dataInicio}${parceria.dataFim == null || parceria.dataFim!.isEmpty ? '' : ' · Fim ${parceria.dataFim}'}',
                              style: const TextStyle(fontFamily: 'Montserrat', fontSize: 12, color: Color(0xFF8A8A8A)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Custo ${_pct(parceria.percentualCusto)} · Ganho ${_pct(parceria.percentualGanho)}',
                              style: const TextStyle(fontFamily: 'Montserrat', fontSize: 12, color: Color(0xFF8A8A8A)),
                            ),
                            if (parceria.periodoVencido) ...[
                              const SizedBox(height: 10),
                              AvisoPeriodoVencido(dataFim: parceria.dataFim),
                            ],
                            const SizedBox(height: 10),
                            Text(
                              '${parceria.qtdAnimais} ${parceria.qtdAnimais == 1 ? 'animal' : 'animais'} · ${parceria.entradas.length} ${parceria.entradas.length == 1 ? 'entrada' : 'entradas'}',
                              style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w700,
                                color: MyColors.colorPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabs,
                        children: [
                          _AbaEntradas(
                            parceria: parceria,
                            carregando: loja.carregandoParcerias,
                            abertos: _abertos,
                            aoAlternar: (id) => setState(() {
                              if (_abertos.contains(id)) {
                                _abertos.remove(id);
                              } else {
                                _abertos.add(id);
                              }
                            }),
                          ),
                          _AbaFinanceiro(
                            parceria: parceria,
                            carregando: loja.carregandoParcerias,
                            aoDespesas: widget.aoDespesas,
                            aoVendas: widget.aoVendas,
                            aoBaixaTitulo: widget.aoBaixaTitulo,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}

class _AbaEntradas extends StatelessWidget {
  const _AbaEntradas({
    required this.parceria,
    required this.carregando,
    required this.abertos,
    required this.aoAlternar,
  });

  final ParceriaFin parceria;
  final bool carregando;
  final Set<int> abertos;
  final ValueChanged<int> aoAlternar;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        const Text(
          'Entradas',
          style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700, fontSize: 15),
        ),
        const SizedBox(height: 10),
        if (carregando)
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: LoadingFinanceiro(altura: 48, rotulo: 'Atualizando…'),
          ),
        if (parceria.entradas.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Text(
              'Nenhuma entrada registrada.',
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Montserrat', color: Color(0xFF8A8A8A)),
            ),
          )
        else
          for (final entrada in parceria.entradas) ...[
            _CardEntrada(
              entrada: entrada,
              aberto: abertos.contains(entrada.id),
              aoAlternar: () => aoAlternar(entrada.id),
            ),
            const SizedBox(height: 8),
          ],
      ],
    );
  }
}

class _AbaFinanceiro extends StatelessWidget {
  const _AbaFinanceiro({
    required this.parceria,
    required this.carregando,
    required this.aoDespesas,
    required this.aoVendas,
    required this.aoBaixaTitulo,
  });

  final ParceriaFin parceria;
  final bool carregando;
  final VoidCallback aoDespesas;
  final VoidCallback aoVendas;
  final ValueChanged<TituloParceriaFin> aoBaixaTitulo;

  @override
  Widget build(BuildContext context) {
    final pendentes = [
      for (final t in parceria.lancamentos)
        if (t.pendente) t,
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        Row(
          children: [
            Expanded(
              child: IndicadorFaixaFinanceiro(
                rotulo: 'A receber',
                valor: reais(parceria.aReceber),
                fundo: const Color(0xFFE7F6EC),
                letra: const Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: IndicadorFaixaFinanceiro(
                rotulo: 'A pagar',
                valor: reais(parceria.aPagar),
                fundo: const Color(0xFFFDECEC),
                letra: const Color(0xFFC62828),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: aoDespesas,
                icon: const Icon(Icons.receipt_long_outlined, size: 18),
                label: Text(
                  'Despesas (${parceria.despesas.length})',
                  style: const TextStyle(fontFamily: 'Montserrat', fontSize: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: aoVendas,
                icon: const Icon(Icons.sell_outlined, size: 18),
                label: Text(
                  'Vendas (${parceria.vendas.length})',
                  style: const TextStyle(fontFamily: 'Montserrat', fontSize: 12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text(
          'Últimas movimentações',
          style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700, fontSize: 15),
        ),
        const SizedBox(height: 10),
        if (carregando)
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: LoadingFinanceiro(altura: 48, rotulo: 'Atualizando…'),
          ),
        if (pendentes.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Text(
              'Nenhuma movimentação.',
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Montserrat', color: Color(0xFF8A8A8A)),
            ),
          )
        else
          for (final titulo in pendentes) ...[
            CartaoBranco(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo.descricao.isEmpty
                        ? (titulo.categoriaNome ?? 'Título #${titulo.id}')
                        : titulo.descricao,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      FlagStatusFinanceiro.titulo(
                        pago: titulo.pago,
                        parcial: titulo.parcial,
                        pendente: titulo.pendente,
                      ),
                      const Spacer(),
                      Text(
                        titulo.valorString?.trim().isNotEmpty == true
                            ? titulo.valorString!
                            : reais(titulo.valor),
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w800,
                          color: titulo.eReceber
                              ? const Color(0xFF1B7A4A)
                              : const Color(0xFFC62828),
                        ),
                      ),
                    ],
                  ),
                  if (titulo.dataCompetencia.isNotEmpty ||
                      (titulo.categoriaNome != null && titulo.categoriaNome!.isNotEmpty)) ...[
                    const SizedBox(height: 6),
                    Text(
                      [
                        if (titulo.dataCompetencia.isNotEmpty) titulo.dataCompetencia,
                        if (titulo.categoriaNome != null && titulo.categoriaNome!.isNotEmpty)
                          titulo.categoriaNome!,
                      ].join(' · '),
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 12,
                        color: Color(0xFF8A8A8A),
                      ),
                    ),
                  ],
                  if (titulo.parcial || titulo.pendente) ...[
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          titulo.saldoPendenteString?.trim().isNotEmpty == true
                              ? 'Saldo ${titulo.saldoPendenteString!}'
                              : 'Saldo ${reais(titulo.saldoPendente)}',
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFC45C26),
                          ),
                        ),
                        const Spacer(),
                        if (titulo.pendente)
                          Material(
                            color: MyColors.colorPrimary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            child: InkWell(
                              onTap: () => aoBaixaTitulo(titulo),
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                child: Text(
                                  titulo.eReceber ? 'Receber' : 'Pagar',
                                  style: const TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: MyColors.colorPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
      ],
    );
  }
}

class _CardEntrada extends StatelessWidget {
  const _CardEntrada({
    required this.entrada,
    required this.aberto,
    required this.aoAlternar,
  });

  final EntradaParceriaFin entrada;
  final bool aberto;
  final VoidCallback aoAlternar;

  @override
  Widget build(BuildContext context) {
    return CartaoBranco(
      aoToque: aoAlternar,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entrada.data.isEmpty ? 'Entrada #${entrada.id}' : 'Entrada · ${entrada.data}',
                      style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700),
                    ),
                    Text(
                      '${entrada.animais.length} ${entrada.animais.length == 1 ? 'animal' : 'animais'}',
                      style: const TextStyle(fontFamily: 'Montserrat', fontSize: 12, color: Color(0xFF8A8A8A)),
                    ),
                  ],
                ),
              ),
              Icon(aberto ? Icons.expand_less : Icons.expand_more, color: const Color(0xFF8A8A8A)),
            ],
          ),
          if (aberto) ...[
            const SizedBox(height: 10),
            const Divider(height: 1, color: Color(0xFFE6E6E6)),
            const SizedBox(height: 10),
            if (entrada.animais.isEmpty)
              const Text(
                'Sem animais nesta entrada.',
                style: TextStyle(fontFamily: 'Montserrat', fontSize: 12, color: Color(0xFF8A8A8A)),
              )
            else
              for (final animal in entrada.animais) ...[
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        animal.brinco.isEmpty
                            ? (animal.appAnimaisId == null ? 'Animal' : 'Animal #${animal.appAnimaisId}')
                            : animal.brinco,
                        style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600),
                      ),
                    ),
                    Text(
                      animal.pesoEntradaKg.isEmpty ? '—' : '${_pesoLegivel(animal.pesoEntradaKg)} kg',
                      style: const TextStyle(fontFamily: 'Montserrat', fontSize: 12, color: Color(0xFF8A8A8A)),
                    ),
                  ],
                ),
                if (animal.dataSaida != null && animal.dataSaida!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2, bottom: 6),
                    child: Text(
                      'Saída ${animal.dataSaida}${animal.pesoSaidaKg == null || animal.pesoSaidaKg!.isEmpty ? '' : ' · ${_pesoLegivel(animal.pesoSaidaKg!)} kg'}',
                      style: const TextStyle(fontFamily: 'Montserrat', fontSize: 11, color: Color(0xFF8A8A8A)),
                    ),
                  )
                else
                  const SizedBox(height: 6),
              ],
          ],
        ],
      ),
    );
  }
}

String _pesoLegivel(String raw) {
  final n = double.tryParse(raw.replaceAll(',', '.'));
  if (n == null) return raw;
  return n == n.roundToDouble() ? n.toInt().toString() : n.toStringAsFixed(2);
}
