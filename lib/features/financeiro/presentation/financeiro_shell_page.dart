import 'package:costeira/features/financeiro/domain/financeiro_mock.dart';
import 'package:costeira/features/financeiro/presentation/pages/contas_page.dart';
import 'package:costeira/features/financeiro/presentation/pages/lancamento_form_page.dart';
import 'package:costeira/features/financeiro/presentation/pages/lancamentos_page.dart';
import 'package:costeira/features/financeiro/presentation/pages/visao_page.dart';
import 'package:costeira/features/financeiro/presentation/widgets/financeiro_ui.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:lucide_icons/lucide_icons.dart';

class _BarraFinanceiro extends StatelessWidget {
  const _BarraFinanceiro({required this.indice, required this.aoEscolher});

  final int indice;
  final ValueChanged<int> aoEscolher;

  static const _itens = [
    (icone: LucideIcons.layoutDashboard, rotulo: 'Visão geral'),
    (icone: LucideIcons.list, rotulo: 'Lançamentos'),
    (icone: LucideIcons.barChart3, rotulo: 'Relatórios'),
    (icone: LucideIcons.landmark, rotulo: 'Contas'),
  ];

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 12,
      shadowColor: const Color(0x33000000),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              for (var i = 0; i < _itens.length; i++)
                Expanded(
                  child: InkWell(
                    onTap: () => aoEscolher(i),
                    child: _ItemBarra(
                      icone: _itens[i].icone,
                      rotulo: _itens[i].rotulo,
                      selecionado: indice == i,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ItemBarra extends StatelessWidget {
  const _ItemBarra({
    required this.icone,
    required this.rotulo,
    required this.selecionado,
  });

  final IconData icone;
  final String rotulo;
  final bool selecionado;

  @override
  Widget build(BuildContext context) {
    final cor = selecionado ? MyColors.colorPrimary : const Color(0xFF9A9A9A);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: selecionado ? const Color(0x1400823A) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icone, size: 22, color: cor),
        ),
        const SizedBox(height: 4),
        Text(
          rotulo,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 11,
            fontWeight: selecionado ? FontWeight.w700 : FontWeight.w500,
            color: cor,
          ),
        ),
      ],
    );
  }
}

class FinanceiroAbrir {
  const FinanceiroAbrir.form() : abrirForm = true;
  const FinanceiroAbrir.modulo() : abrirForm = false;

  final bool abrirForm;
}

class FinanceiroShellPage extends StatefulWidget {
  const FinanceiroShellPage({super.key, this.abrirForm = false});

  final bool abrirForm;

  @override
  State<FinanceiroShellPage> createState() => _FinanceiroShellPageState();
}

enum _Passo { abas, form, detalhe, baixa, conta, contaForm, saldo }

class _FinanceiroShellPageState extends State<FinanceiroShellPage> {
  final _loja = FinanceiroLoja();
  int _aba = 0;
  _Passo _passo = _Passo.abas;
  LancamentoMock? _lancamento;
  ContaMock? _conta;
  bool _contaNova = true;

  @override
  void initState() {
    super.initState();
    if (widget.abrirForm) _passo = _Passo.form;
  }

  @override
  void dispose() {
    _loja.dispose();
    super.dispose();
  }

  void _abaIr(int index) => setState(() {
    _aba = index;
    _passo = _Passo.abas;
  });

  void _sair() => Modular.to.pop();

  Future<void> _inativar() async {
    final conta = _conta;
    if (conta == null) return;
    final motivo = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Inativar conta?',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${conta.nome} deixará de aceitar novas baixas. O histórico será preservado.',
              style: const TextStyle(fontFamily: 'Montserrat', fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: motivo,
              decoration: const InputDecoration(
                labelText: 'Motivo da inativação',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Voltar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Inativar'),
          ),
        ],
      ),
    );
    final texto = motivo.text;
    motivo.dispose();
    if (ok != true || !mounted) return;
    _loja.salvarConta(
      ContaMock(
        id: conta.id,
        nome: conta.nome,
        tipo: conta.tipo,
        saldo: conta.saldo,
        ativa: false,
        motivo: texto,
        saldoInicialRegistrado: conta.saldoInicialRegistrado,
        movimentos: conta.movimentos,
      ),
    );
    setState(() => _passo = _Passo.abas);
  }

  @override
  Widget build(BuildContext context) {
    return FinanceiroEscopo(
      loja: _loja,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final largo = constraints.maxWidth >= 760;
          final miolo = _miolo(barra: !largo);
          if (!largo || _passo != _Passo.abas) return miolo;
          return Row(
            children: [
              _menuLateral(),
              const VerticalDivider(width: 1),
              Expanded(child: miolo),
            ],
          );
        },
      ),
    );
  }

  Widget _menuLateral() {
    const itens = ['Visão geral', 'Lançamentos', 'Relatórios', 'Contas'];
    return ColoredBox(
      color: Colors.white,
      child: SizedBox(
        width: 220,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
            for (var i = 0; i < itens.length; i++)
              ListTile(
                selected: _aba == i,
                selectedColor: MyColors.colorPrimary,
                title: Text(
                  itens[i],
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () => _abaIr(i),
              ),
          ],
        ),
      ),
    );
  }

  Widget _miolo({required bool barra}) {
    if (_passo == _Passo.form) {
      return LancamentoFormPage(
        aoFechar: () => setState(() {
          _aba = 1;
          _passo = _Passo.abas;
        }),
      );
    }
    if (_passo == _Passo.detalhe && _lancamento != null) {
      return LancamentoDetalhePage(
        item: _lancamento!,
        aoVoltar: () => setState(() => _passo = _Passo.abas),
        aoBaixa: () => setState(() => _passo = _Passo.baixa),
        aoEstornar: () {
          _loja.estornar(_lancamento!.id);
          setState(() {});
        },
        aoEstornarPagamento: () {
          _loja.estornarPagamento(_lancamento!.id);
          setState(() {});
        },
      );
    }
    if (_passo == _Passo.baixa && _lancamento != null) {
      return RegistrarBaixaPage(
        item: _lancamento!,
        aoVoltar: () => setState(() => _passo = _Passo.detalhe),
        aoConfirmar: (valor, conta) {
          _loja.registrarBaixa(_lancamento!.id, valor: valor, conta: conta);
          setState(() => _passo = _Passo.detalhe);
        },
      );
    }
    if (_passo == _Passo.conta && _conta != null) {
      return ContaDetalhePage(
        conta: _conta!,
        aoVoltar: () => setState(() => _passo = _Passo.abas),
        aoEditar: () => setState(() {
          _contaNova = false;
          _passo = _Passo.contaForm;
        }),
        aoInativar: _inativar,
        aoSaldo: () => setState(() => _passo = _Passo.saldo),
      );
    }
    if (_passo == _Passo.contaForm) {
      return ContaFormPage(
        conta: _contaNova ? null : _conta,
        aoVoltar: () =>
            setState(() => _passo = _contaNova ? _Passo.abas : _Passo.conta),
      );
    }
    if (_passo == _Passo.saldo && _conta != null) {
      return SaldoInicialPage(
        conta: _conta!,
        aoVoltar: () => setState(() => _passo = _Passo.conta),
      );
    }

    return Scaffold(
      backgroundColor: fundoFinanceiro,
      appBar: AppBar(
        backgroundColor: MyColors.colorPrimary,
        automaticallyImplyLeading: false,
        titleSpacing: 12,
        title: Align(
          alignment: Alignment.centerLeft,
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            child: InkWell(
              onTap: _sair,
              borderRadius: BorderRadius.circular(24),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      LucideIcons.home,
                      size: 16,
                      color: MyColors.colorPrimary,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Dashboard',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: MyColors.colorPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: IndexedStack(
        index: _aba,
        children: [
          VisaoGeralPage(
            aoVerExtrato: () => _abaIr(2),
            aoAbrir: (item) => setState(() {
              _lancamento = item;
              _passo = _Passo.detalhe;
            }),
          ),
          LancamentosPage(
            aoAbrir: (item) => setState(() {
              _lancamento = item;
              _passo = _Passo.detalhe;
            }),
          ),
          const RelatoriosPage(),
          ContasPage(
            aoAbrir: (conta) => setState(() {
              _conta = conta;
              _passo = _Passo.conta;
            }),
          ),
        ],
      ),
      floatingActionButton: _aba == 0 || _aba == 1
          ? FloatingActionButton.extended(
              onPressed: () => setState(() => _passo = _Passo.form),
              backgroundColor: MyColors.colorPrimary,
              icon: const Icon(Icons.add),
              label: const Text(
                'Novo lançamento',
                style: TextStyle(fontFamily: 'Montserrat'),
              ),
            )
          : _aba == 3
          ? FloatingActionButton.extended(
              onPressed: () => setState(() {
                _contaNova = true;
                _conta = null;
                _passo = _Passo.contaForm;
              }),
              backgroundColor: MyColors.colorPrimary,
              icon: const Icon(Icons.add),
              label: const Text(
                'Adicionar conta',
                style: TextStyle(fontFamily: 'Montserrat'),
              ),
            )
          : null,
      bottomNavigationBar: barra
          ? _BarraFinanceiro(indice: _aba, aoEscolher: _abaIr)
          : null,
    );
  }
}
