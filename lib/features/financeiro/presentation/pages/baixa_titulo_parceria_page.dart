import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/core/input_formatters/brazilian_currency_input_formatter.dart';
import 'package:costeira/features/financeiro/domain/financeiro_mock.dart';
import 'package:costeira/features/financeiro/presentation/widgets/financeiro_ui.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class BaixaTituloParceriaPage extends StatefulWidget {
  const BaixaTituloParceriaPage({
    super.key,
    required this.parceriaId,
    required this.titulo,
    required this.aoVoltar,
    required this.aoSalvo,
  });

  final int parceriaId;
  final TituloParceriaFin titulo;
  final VoidCallback aoVoltar;
  final VoidCallback aoSalvo;

  @override
  State<BaixaTituloParceriaPage> createState() => _BaixaTituloParceriaPageState();
}

class _BaixaTituloParceriaPageState extends State<BaixaTituloParceriaPage> {
  late final TextEditingController _valor;
  late final TextEditingController _data;
  late final MaskTextInputFormatter _maskData = mascaraData();
  int? _contaId;
  bool _enviando = false;

  @override
  void initState() {
    super.initState();
    final agora = DateTime.now();
    _valor = TextEditingController(text: BrazilianCurrency.format(widget.titulo.saldoPendente));
    _data = TextEditingController(
      text: '${agora.day.toString().padLeft(2, '0')}/${agora.month.toString().padLeft(2, '0')}/${agora.year}',
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final contas = FinanceiroEscopo.of(context).contas.where((c) => c.ativa).toList();
      if (_contaId == null && contas.isNotEmpty) {
        setState(() => _contaId = contas.first.id);
      }
    });
  }

  @override
  void dispose() {
    _valor.dispose();
    _data.dispose();
    super.dispose();
  }

  Future<void> _confirmar() async {
    final loja = FinanceiroEscopo.of(context);
    final valor = BrazilianCurrency.parse(_valor.text);
    if (valor == null || valor <= 0) {
      AppSnackBar.show(context: context, message: 'Informe o valor da baixa.');
      return;
    }
    if (valor > widget.titulo.saldoPendente + 0.001) {
      AppSnackBar.show(context: context, message: 'Valor maior que o saldo pendente.');
      return;
    }
    ContaMock? conta;
    for (final item in loja.contas) {
      if (item.id == _contaId) conta = item;
    }
    if (conta == null) {
      AppSnackBar.show(context: context, message: 'Selecione a conta.');
      return;
    }
    if (!widget.titulo.eReceber && conta.saldo + 0.001 < valor) {
      AppSnackBar.show(context: context, message: 'Saldo da conta insuficiente.');
      return;
    }
    if (_enviando) return;
    setState(() => _enviando = true);
    try {
      await loja.registrarBaixaTituloParceria(
        parceriaId: widget.parceriaId,
        lancamentoId: widget.titulo.id,
        contaId: conta.id,
        data: _data.text.trim(),
        valor: valor.toStringAsFixed(2),
        motivo: widget.titulo.eReceber ? 'Recebimento do título' : 'Pagamento do título',
      );
      if (!mounted) return;
      AppSnackBar.show(context: context, message: 'Baixa registrada.', isError: false);
      widget.aoSalvo();
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _enviando = false);
      AppSnackBar.show(context: context, message: error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _enviando = false);
      AppSnackBar.show(context: context, message: 'Não foi possível registrar a baixa.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final contas = FinanceiroEscopo.of(context).contas.where((c) => c.ativa).toList();
    final titulo = widget.titulo;
    return Scaffold(
      backgroundColor: fundoFinanceiro,
      appBar: AppBar(
        backgroundColor: MyColors.colorPrimary,
        foregroundColor: Colors.white,
        title: Text(
          titulo.eReceber ? 'Registrar recebimento' : 'Registrar pagamento',
          style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600),
        ),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: _enviando ? null : widget.aoVoltar),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            titulo.descricao.isEmpty ? (titulo.categoriaNome ?? 'Título #${titulo.id}') : titulo.descricao,
            style: const TextStyle(fontFamily: 'Montserrat', fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Saldo ${titulo.saldoPendenteString?.trim().isNotEmpty == true ? titulo.saldoPendenteString! : reais(titulo.saldoPendente)}',
            style: const TextStyle(fontFamily: 'Montserrat', color: Color(0xFF8A8A8A)),
          ),
          const SizedBox(height: 16),
          CampoFinanceiro(
            rotulo: 'VALOR',
            child: TextField(
              controller: _valor,
              keyboardType: tecladoMoeda,
              inputFormatters: [mascaraMoeda],
              decoration: decoracaoCampo('R\$ 0,00'),
            ),
          ),
          const SizedBox(height: 12),
          CampoFinanceiro(
            rotulo: 'DATA',
            child: TextField(
              controller: _data,
              inputFormatters: [_maskData],
              keyboardType: tecladoData,
              decoration: decoracaoCampo('DD/MM/AAAA'),
            ),
          ),
          const SizedBox(height: 12),
          CampoFinanceiro(
            rotulo: 'CONTA',
            child: DropdownButtonFormField<int>(
              initialValue: contas.any((c) => c.id == _contaId) ? _contaId : null,
              decoration: decoracaoCampo('Selecione'),
              items: [
                for (final conta in contas)
                  DropdownMenuItem(
                    value: conta.id,
                    child: Text('${conta.nome} · ${reais(conta.saldo)}', style: const TextStyle(fontFamily: 'Montserrat')),
                  ),
              ],
              onChanged: (valor) => setState(() => _contaId = valor),
            ),
          ),
          const SizedBox(height: 24),
          BotaoPrimarioFinanceiro(
            rotulo: titulo.eReceber ? 'Confirmar Recebimento' : 'Confirmar Pagamento',
            carregando: _enviando,
            onPressed: _confirmar,
          ),
        ],
      ),
    );
  }
}

class FinanceiroVendaParceriaPage extends StatefulWidget {
  const FinanceiroVendaParceriaPage({
    super.key,
    required this.parceriaId,
    required this.vendaId,
    required this.aoVoltar,
    required this.aoBaixa,
  });

  final int parceriaId;
  final int vendaId;
  final VoidCallback aoVoltar;
  final ValueChanged<TituloParceriaFin> aoBaixa;

  @override
  State<FinanceiroVendaParceriaPage> createState() => _FinanceiroVendaParceriaPageState();
}

class _FinanceiroVendaParceriaPageState extends State<FinanceiroVendaParceriaPage> {
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
    final parceria = loja.parceriaDetalhe?.id == widget.parceriaId ? loja.parceriaDetalhe : null;
    final venda = parceria?.vendas.where((v) => v.id == widget.vendaId).firstOrNull;
    final titulos = parceria?.titulosSistema ?? const <TituloParceriaFin>[];
    final vendaBruta = [
      for (final t in parceria?.lancamentos ?? const <TituloParceriaFin>[])
        if (t.categoriaId == 7) t,
    ];
    final todos = [...vendaBruta, ...titulos.where((t) => t.categoriaId != 7)];

    return Scaffold(
      backgroundColor: fundoFinanceiro,
      appBar: AppBar(
        backgroundColor: MyColors.colorPrimary,
        foregroundColor: Colors.white,
        title: const Text('Financeiro da venda', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.aoVoltar),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          if (venda != null)
            CartaoBranco(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    venda.data.isEmpty ? 'Venda #${venda.id}' : 'Venda · ${venda.data}',
                    style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    [
                      if (venda.compradorNome != null && venda.compradorNome!.isNotEmpty) venda.compradorNome!,
                      if (venda.precoKg.isNotEmpty) 'R\$ ${venda.precoKg}/kg',
                    ].join(' · '),
                    style: const TextStyle(fontFamily: 'Montserrat', fontSize: 12, color: Color(0xFF8A8A8A)),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          const Text(
            'Títulos',
            style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700, fontSize: 15),
          ),
          const SizedBox(height: 10),
          if (loja.carregandoParcerias && parceria == null)
            const LoadingFinanceiro(altura: 120, rotulo: 'Carregando…')
          else if (todos.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'Nenhum título gerado. Confirme o acerto para criar capital/ganho/reembolso.',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Montserrat', color: Color(0xFF8A8A8A)),
              ),
            )
          else
            for (final titulo in todos) ...[
              _CartaoTituloVenda(
                titulo: titulo,
                aoBaixa: () => widget.aoBaixa(titulo),
              ),
              const SizedBox(height: 8),
            ],
        ],
      ),
    );
  }
}

class _CartaoTituloVenda extends StatelessWidget {
  const _CartaoTituloVenda({
    required this.titulo,
    required this.aoBaixa,
  });

  final TituloParceriaFin titulo;
  final VoidCallback aoBaixa;

  @override
  Widget build(BuildContext context) {
    final nome = titulo.descricao.isEmpty
        ? (titulo.categoriaNome ?? 'Título #${titulo.id}')
        : titulo.descricao;
    final valor = titulo.valorString?.trim().isNotEmpty == true
        ? titulo.valorString!
        : reais(titulo.valor);
    final saldo = titulo.saldoPendenteString?.trim().isNotEmpty == true
        ? titulo.saldoPendenteString!
        : reais(titulo.saldoPendente);

    return CartaoBranco(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            nome,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: Color(0xFF1F2A24),
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
                valor,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: Color(0xFF1F2A24),
                ),
              ),
            ],
          ),
          if (titulo.categoriaNome != null && titulo.categoriaNome!.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              titulo.categoriaNome!.trim(),
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
                  'Saldo $saldo',
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFC45C26),
                  ),
                ),
                const Spacer(),
                if (titulo.pendente)
                  _BotaoAcaoTitulo(
                    rotulo: titulo.eReceber ? 'Receber' : 'Pagar',
                    onPressed: aoBaixa,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _BotaoAcaoTitulo extends StatelessWidget {
  const _BotaoAcaoTitulo({required this.rotulo, required this.onPressed});

  final String rotulo;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: MyColors.colorPrimary.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Text(
            rotulo,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: MyColors.colorPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
