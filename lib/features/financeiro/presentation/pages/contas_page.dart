import 'package:costeira/features/financeiro/domain/financeiro_mock.dart';
import 'package:costeira/features/financeiro/presentation/widgets/financeiro_ui.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';

class ContasPage extends StatefulWidget {
  const ContasPage({super.key, required this.aoAbrir});

  final ValueChanged<ContaMock> aoAbrir;

  @override
  State<ContasPage> createState() => _ContasPageState();
}

class _ContasPageState extends State<ContasPage> {
  bool _ativas = true;

  @override
  Widget build(BuildContext context) {
    final loja = FinanceiroEscopo.of(context);
    final itens = loja.contas.where((c) => c.ativa == _ativas).toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
      children: [
        const _Filtro('Fazenda Filial Norte'),
        const SizedBox(height: 10),
        GrupoChips(
          opcoes: const ['Ativas', 'Inativas'],
          selecionado: _ativas ? 'Ativas' : 'Inativas',
          aoEscolher: (v) => setState(() => _ativas = v == 'Ativas'),
        ),
        const SizedBox(height: 12),
        CartaoBranco(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Saldo consolidado', style: TextStyle(fontFamily: 'Montserrat', color: Color(0xFF8A8A8A))),
              Text(
                reais(loja.saldoDisponivel),
                style: const TextStyle(fontFamily: 'Montserrat', fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const Text('Posição em 20/10/2026', style: TextStyle(fontFamily: 'Montserrat', fontSize: 12, color: Color(0xFF8A8A8A))),
            ],
          ),
        ),
        const SizedBox(height: 12),
        for (final conta in itens) ...[
          CartaoBranco(
            aoToque: () => widget.aoAbrir(conta),
            child: Row(
              children: [
                Icon(
                  conta.tipo == 'Banco' ? Icons.account_balance_outlined : Icons.payments_outlined,
                  color: MyColors.colorPrimary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(conta.nome, style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700)),
                      Text('Saldo disponível', style: const TextStyle(fontFamily: 'Montserrat', fontSize: 12, color: Color(0xFF8A8A8A))),
                      Text(reais(conta.saldo), style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w800, fontSize: 16)),
                    ],
                  ),
                ),
                Text(conta.tipo, style: const TextStyle(fontFamily: 'Montserrat', fontSize: 12, color: Color(0xFF8A8A8A))),
                const Icon(Icons.chevron_right, color: Color(0xFF8A8A8A)),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
        const Text(
          'Saldo calculado pelas movimentações de cada conta.',
          style: TextStyle(fontFamily: 'Montserrat', fontSize: 12, color: Color(0xFF8A8A8A)),
        ),
      ],
    );
  }
}

class _Filtro extends StatelessWidget {
  const _Filtro(this.rotulo);
  final String rotulo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE6E6E6)),
      ),
      child: Text(rotulo, style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600)),
    );
  }
}

class ContaDetalhePage extends StatelessWidget {
  const ContaDetalhePage({
    super.key,
    required this.conta,
    required this.aoVoltar,
    required this.aoEditar,
    required this.aoInativar,
    required this.aoSaldo,
  });

  final ContaMock conta;
  final VoidCallback aoVoltar;
  final VoidCallback aoEditar;
  final VoidCallback aoInativar;
  final VoidCallback aoSaldo;

  @override
  Widget build(BuildContext context) {
    final atual = FinanceiroEscopo.of(context).contas.firstWhere((c) => c.id == conta.id);
    return Scaffold(
      backgroundColor: fundoFinanceiro,
      appBar: AppBar(
        backgroundColor: MyColors.colorPrimary,
        foregroundColor: Colors.white,
        title: Text(atual.nome, style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: aoVoltar),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('${atual.tipo} · ${atual.ativa ? 'Ativa' : 'Inativa'}', style: const TextStyle(fontFamily: 'Montserrat')),
          Text(reais(atual.saldo), style: const TextStyle(fontFamily: 'Montserrat', fontSize: 28, fontWeight: FontWeight.w800)),
          const Text('Saldo disponível em 20/10/2026', style: TextStyle(fontFamily: 'Montserrat', color: Color(0xFF8A8A8A))),
          const SizedBox(height: 12),
          const Text('Movimentações', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          if (atual.movimentos.isEmpty)
            const Text('Sem movimentos neste período.', style: TextStyle(fontFamily: 'Montserrat', color: Color(0xFF8A8A8A)))
          else
            for (final mov in atual.movimentos)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: CartaoBranco(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(mov.titulo, style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600)),
                            Text(mov.data, style: const TextStyle(fontFamily: 'Montserrat', fontSize: 12, color: Color(0xFF8A8A8A))),
                          ],
                        ),
                      ),
                      Text(
                        reais(mov.valor),
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w700,
                          color: mov.valor < 0 ? const Color(0xFFC62828) : MyColors.colorPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: atual.saldoInicialRegistrado ? null : aoSaldo,
            style: FilledButton.styleFrom(backgroundColor: MyColors.colorPrimary),
            child: Text(
              atual.saldoInicialRegistrado ? 'Saldo inicial já registrado' : 'Informar saldo inicial',
              style: const TextStyle(fontFamily: 'Montserrat'),
            ),
          ),
          OutlinedButton(
            onPressed: aoEditar,
            child: const Text('Editar conta', style: TextStyle(fontFamily: 'Montserrat')),
          ),
          TextButton(
            onPressed: atual.ativa ? aoInativar : null,
            child: const Text('Inativar conta', style: TextStyle(fontFamily: 'Montserrat', color: Color(0xFFC62828))),
          ),
        ],
      ),
    );
  }
}

class ContaFormPage extends StatefulWidget {
  const ContaFormPage({super.key, required this.aoVoltar, this.conta});

  final VoidCallback aoVoltar;
  final ContaMock? conta;

  @override
  State<ContaFormPage> createState() => _ContaFormPageState();
}

class _ContaFormPageState extends State<ContaFormPage> {
  late final TextEditingController _nome;
  late final TextEditingController _motivo;
  late String _tipo;

  @override
  void initState() {
    super.initState();
    _nome = TextEditingController(text: widget.conta?.nome ?? '');
    _motivo = TextEditingController(text: widget.conta?.motivo ?? 'Cadastro da conta da fazenda');
    _tipo = widget.conta?.tipo ?? 'Banco';
  }

  @override
  void dispose() {
    _nome.dispose();
    _motivo.dispose();
    super.dispose();
  }

  void _salvar() {
    if (_nome.text.trim().isEmpty) return;
    final loja = FinanceiroEscopo.of(context);
    final atual = widget.conta;
    loja.salvarConta(
      ContaMock(
        id: atual?.id ?? loja.novoIdConta(),
        nome: _nome.text.trim(),
        tipo: _tipo,
        saldo: atual?.saldo ?? 0,
        ativa: atual?.ativa ?? true,
        motivo: _motivo.text.trim(),
        saldoInicialRegistrado: atual?.saldoInicialRegistrado ?? false,
        movimentos: atual?.movimentos ?? const [],
      ),
    );
    widget.aoVoltar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fundoFinanceiro,
      appBar: AppBar(
        backgroundColor: MyColors.colorPrimary,
        foregroundColor: Colors.white,
        title: Text(
          widget.conta == null ? 'Adicionar conta' : 'Editar conta',
          style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600),
        ),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.aoVoltar),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          CampoFinanceiro(
            rotulo: 'NOME DA CONTA',
            child: TextField(controller: _nome, decoration: decoracaoCampo('Banco principal')),
          ),
          const SizedBox(height: 12),
          const SecaoRotulo('TIPO'),
          const SizedBox(height: 8),
          GrupoChips(
            opcoes: const ['Caixa', 'Banco'],
            selecionado: _tipo,
            aoEscolher: (v) => setState(() => _tipo = v),
          ),
          const SizedBox(height: 12),
          CampoFinanceiro(
            rotulo: 'MOTIVO',
            child: TextField(controller: _motivo, decoration: decoracaoCampo('')),
          ),
          const SizedBox(height: 8),
          const Text('Fazenda Filial Norte', style: TextStyle(fontFamily: 'Montserrat', color: Color(0xFF8A8A8A))),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _salvar,
            style: FilledButton.styleFrom(backgroundColor: MyColors.colorPrimary, minimumSize: const Size.fromHeight(48)),
            child: const Text('Salvar conta', style: TextStyle(fontFamily: 'Montserrat')),
          ),
          TextButton(
            onPressed: widget.aoVoltar,
            child: const Text(
              'Cancelar',
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
}

class SaldoInicialPage extends StatefulWidget {
  const SaldoInicialPage({super.key, required this.conta, required this.aoVoltar});

  final ContaMock conta;
  final VoidCallback aoVoltar;

  @override
  State<SaldoInicialPage> createState() => _SaldoInicialPageState();
}

class _SaldoInicialPageState extends State<SaldoInicialPage> {
  final _data = TextEditingController(text: '01/10/2026');
  final _valor = TextEditingController(text: '0,00');
  final _doc = TextEditingController();
  final _motivo = TextEditingController(text: 'Saldo conferido no início do controle');
  bool _positivo = true;

  @override
  void dispose() {
    _data.dispose();
    _valor.dispose();
    _doc.dispose();
    _motivo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fundoFinanceiro,
      appBar: AppBar(
        backgroundColor: MyColors.colorPrimary,
        foregroundColor: Colors.white,
        title: const Text('Saldo inicial', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.aoVoltar),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(widget.conta.nome, style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700, fontSize: 16)),
          Text('${widget.conta.tipo} · Ativa', style: const TextStyle(fontFamily: 'Montserrat', color: Color(0xFF8A8A8A))),
          const SizedBox(height: 12),
          CampoFinanceiro(rotulo: 'DATA DE ABERTURA', child: TextField(controller: _data, decoration: decoracaoCampo(''))),
          const SizedBox(height: 12),
          const SecaoRotulo('SITUAÇÃO DO SALDO'),
          const SizedBox(height: 8),
          GrupoChips(
            opcoes: const ['Positivo', 'Negativo'],
            selecionado: _positivo ? 'Positivo' : 'Negativo',
            aoEscolher: (v) => setState(() => _positivo = v == 'Positivo'),
          ),
          const SizedBox(height: 12),
          CampoFinanceiro(rotulo: 'VALOR', child: TextField(controller: _valor, decoration: decoracaoCampo('0,00'))),
          const SizedBox(height: 12),
          CampoFinanceiro(rotulo: 'DOCUMENTO (OPCIONAL)', child: TextField(controller: _doc, decoration: decoracaoCampo('Conciliação de abertura'))),
          const SizedBox(height: 12),
          CampoFinanceiro(rotulo: 'MOTIVO', child: TextField(controller: _motivo, decoration: decoracaoCampo(''))),
          const SizedBox(height: 8),
          const Text(
            'Informe o saldo existente na data de início do controle. Não é uma receita.',
            style: TextStyle(fontFamily: 'Montserrat', fontSize: 12, color: Color(0xFF8A8A8A)),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: widget.conta.saldoInicialRegistrado
                ? null
                : () {
                    final bruto = double.tryParse(_valor.text.replaceAll('.', '').replaceAll(',', '.')) ?? 0;
                    final sinal = _positivo ? bruto : -bruto;
                    final loja = FinanceiroEscopo.of(context);
                    loja.salvarConta(
                      ContaMock(
                        id: widget.conta.id,
                        nome: widget.conta.nome,
                        tipo: widget.conta.tipo,
                        saldo: widget.conta.saldo + sinal,
                        ativa: widget.conta.ativa,
                        motivo: widget.conta.motivo,
                        saldoInicialRegistrado: true,
                        movimentos: [
                          MovimentoContaMock(_data.text, 'Saldo inicial', sinal, 'Abertura'),
                          ...widget.conta.movimentos,
                        ],
                      ),
                    );
                    widget.aoVoltar();
                  },
            style: FilledButton.styleFrom(backgroundColor: MyColors.colorPrimary, minimumSize: const Size.fromHeight(48)),
            child: Text(
              widget.conta.saldoInicialRegistrado ? 'Saldo inicial já registrado' : 'Registrar saldo inicial',
              style: const TextStyle(fontFamily: 'Montserrat'),
            ),
          ),
        ],
      ),
    );
  }
}
