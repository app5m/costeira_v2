import 'package:costeira/core/components/custom_button.dart';
import 'package:costeira/features/financeiro/domain/financeiro_mock.dart';
import 'package:costeira/features/financeiro/presentation/widgets/financeiro_ui.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';

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
          children: [
            Expanded(child: _total('A pagar', loja.aPagar, const Color(0xFFC62828))),
            const SizedBox(width: 8),
            Expanded(child: _total('A receber', loja.aReceber, MyColors.colorPrimary)),
          ],
        ),
        const SizedBox(height: 12),
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

  Widget _total(String rotulo, double valor, Color cor) {
    return CartaoBranco(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            rotulo,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: cor,
            ),
          ),
          Text(
            reais(valor),
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: cor,
            ),
          ),
        ],
      ),
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
    required this.aoEstornar,
    required this.aoEstornarPagamento,
  });

  final LancamentoMock item;
  final VoidCallback aoVoltar;
  final VoidCallback aoBaixa;
  final VoidCallback aoEstornar;
  final VoidCallback aoEstornarPagamento;

  @override
  Widget build(BuildContext context) {
    final atual = FinanceiroEscopo.of(context).lancamentos.firstWhere(
      (l) => l.id == item.id,
      orElse: () => item,
    );
    final temBaixa = atual.pagamentos.isNotEmpty;
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
                Text(
                  atual.titulo,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${atual.dataCurta} · ${atual.categoria}',
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    color: Color(0xFF8A8A8A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  reais(atual.valor),
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                _linha('Liquidado', reais(atual.liquidado)),
                _linha('Pendente', reais(atual.pendente)),
                _linha('Competência', atual.competencia),
                if (atual.fornecedor != null) _linha('Fornecedor', atual.fornecedor!),
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
                  const SizedBox(height: 6),
                  for (final parte in atual.alocacao)
                    _linha(parte.nome, reais(parte.valor)),
                ],
              ),
            ),
          ],
          if (temBaixa) ...[
            const SizedBox(height: 12),
            CartaoBranco(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SecaoRotulo('PAGAMENTOS'),
                  const SizedBox(height: 6),
                  for (final pag in atual.pagamentos)
                    _linha('${pag.data} · ${pag.conta}', reais(pag.valor)),
                  const SizedBox(height: 4),
                  const Text(
                    'Estorne o pagamento antes de estornar o lançamento.',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 12,
                      color: Color(0xFF8A8A8A),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () => _confirmarEstorno(
                        context,
                        titulo: 'Estornar pagamento',
                        mensagem: 'Tem certeza que deseja estornar este pagamento?',
                        aoConfirmar: aoEstornarPagamento,
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: MyColors.colorBtnNo,
                        padding: EdgeInsets.zero,
                      ),
                      child: const Text(
                        'Estornar pagamento',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                          color: MyColors.colorBtnNo,
                        ),
                      ),
                    ),
                  ),
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
                const SizedBox(height: 6),
                for (final linha in atual.historico)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      linha,
                      style: const TextStyle(fontFamily: 'Montserrat', fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (atual.pendente > 0)
            CustomButton(
              onPressed: aoBaixa,
              text: 'Registrar baixa',
              borderRadius: 12,
            ),
          if (!temBaixa)
            TextButton(
              onPressed: () => _confirmarEstorno(
                context,
                titulo: 'Estornar lançamento',
                mensagem: 'Tem certeza que deseja estornar este lançamento?',
                aoConfirmar: aoEstornar,
              ),
              child: const Text(
                'Estornar lançamento',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                  color: MyColors.colorBtnNo,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _confirmarEstorno(
    BuildContext context, {
    required String titulo,
    required String mensagem,
    required VoidCallback aoConfirmar,
  }) async {
    final ok = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheet) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                mensagem,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  color: Color(0xFF8692A8),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(sheet).pop(true),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: MyColors.colorBtnNo,
                    side: const BorderSide(color: MyColors.colorBtnNo),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Estornar',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      color: MyColors.colorBtnNo,
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(sheet).pop(false),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 16,
                    color: Color(0xFF313131),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (ok == true) aoConfirmar();
  }

  Widget _linha(String rotulo, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              rotulo,
              style: const TextStyle(fontFamily: 'Montserrat', color: Color(0xFF6B6B6B)),
            ),
          ),
          Text(
            valor,
            style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700),
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
  final void Function(double valor, String conta) aoConfirmar;

  @override
  State<RegistrarBaixaPage> createState() => _RegistrarBaixaPageState();
}

class _RegistrarBaixaPageState extends State<RegistrarBaixaPage> {
  late final TextEditingController _valor;
  String _conta = 'Banco principal';
  final _data = TextEditingController(text: '21/10/2026');
  final _motivo = TextEditingController(text: 'Pagamento do saldo');

  @override
  void initState() {
    super.initState();
    _valor = TextEditingController(
      text: widget.item.pendente.toStringAsFixed(2).replaceAll('.', ','),
    );
  }

  @override
  void dispose() {
    _valor.dispose();
    _data.dispose();
    _motivo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contas = FinanceiroEscopo.of(context).contas.where((c) => c.ativa);
    return Scaffold(
      backgroundColor: fundoFinanceiro,
      appBar: AppBar(
        backgroundColor: MyColors.colorPrimary,
        foregroundColor: Colors.white,
        title: const Text(
          'Registrar pagamento',
          style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600),
        ),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.aoVoltar),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            widget.item.titulo,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            'Valor total ${reais(widget.item.valor)} · Já liquidado ${reais(widget.item.liquidado)}',
            style: const TextStyle(fontFamily: 'Montserrat', fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(
            'Saldo pendente ${reais(widget.item.pendente)}',
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w700,
              color: Color(0xFFB86E00),
            ),
          ),
          const SizedBox(height: 16),
          CampoFinanceiro(
            rotulo: 'CONTA',
            child: DropdownButtonFormField<String>(
              initialValue: _conta,
              decoration: decoracaoCampo(''),
              items: [
                for (final conta in contas)
                  DropdownMenuItem(value: conta.nome, child: Text(conta.nome)),
              ],
              onChanged: (v) => setState(() => _conta = v ?? _conta),
            ),
          ),
          const SizedBox(height: 12),
          CampoFinanceiro(
            rotulo: 'DATA',
            child: TextField(controller: _data, decoration: decoracaoCampo('')),
          ),
          const SizedBox(height: 12),
          CampoFinanceiro(
            rotulo: 'VALOR DA BAIXA',
            child: TextField(
              controller: _valor,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: decoracaoCampo('0,00'),
            ),
          ),
          const SizedBox(height: 12),
          CampoFinanceiro(
            rotulo: 'MOTIVO',
            child: TextField(controller: _motivo, decoration: decoracaoCampo('')),
          ),
          const SizedBox(height: 8),
          const Text(
            'Você pode pagar parcialmente ou usar outra conta em uma nova baixa.',
            style: TextStyle(fontFamily: 'Montserrat', fontSize: 12, color: Color(0xFF8A8A8A)),
          ),
          const SizedBox(height: 16),
          CustomButton(
            onPressed: () {
              final valor = double.tryParse(
                _valor.text.replaceAll('.', '').replaceAll(',', '.'),
              );
              if (valor == null || valor <= 0) return;
              widget.aoConfirmar(valor, _conta);
            },
            text: 'Confirmar pagamento',
            borderRadius: 12,
          ),
          TextButton(
            onPressed: widget.aoVoltar,
            child: const Text('Voltar', style: TextStyle(fontFamily: 'Montserrat')),
          ),
        ],
      ),
    );
  }
}
