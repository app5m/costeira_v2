import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/features/financeiro/domain/financeiro_mock.dart';
import 'package:costeira/features/financeiro/presentation/pages/acerto_parceria_page.dart';
import 'package:costeira/features/financeiro/presentation/pages/baixa_titulo_parceria_page.dart';
import 'package:costeira/features/financeiro/presentation/pages/contas_page.dart';
import 'package:costeira/features/financeiro/presentation/pages/contrato_detalhe_page.dart';
import 'package:costeira/features/financeiro/presentation/pages/despesa_parceria_detalhe_page.dart';
import 'package:costeira/features/financeiro/presentation/pages/despesa_parceria_form_page.dart';
import 'package:costeira/features/financeiro/presentation/pages/despesas_parceria_page.dart';
import 'package:costeira/features/financeiro/presentation/pages/entrada_parceria_page.dart';
import 'package:costeira/features/financeiro/presentation/pages/investidores_page.dart';
import 'package:costeira/features/financeiro/presentation/pages/lancamento_form_page.dart';
import 'package:costeira/features/financeiro/presentation/pages/lancamentos_page.dart';
import 'package:costeira/features/financeiro/presentation/pages/relatorio_detalhe_page.dart';
import 'package:costeira/features/financeiro/presentation/pages/venda_parceria_form_page.dart';
import 'package:costeira/features/financeiro/presentation/pages/vendas_parceria_page.dart';
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
  const FinanceiroAbrir.form()
      : abrirForm = true,
        abrirInvestidores = false;
  const FinanceiroAbrir.modulo()
      : abrirForm = false,
        abrirInvestidores = false;
  const FinanceiroAbrir.investidores()
      : abrirForm = false,
        abrirInvestidores = true;

  final bool abrirForm;
  final bool abrirInvestidores;
}

class FinanceiroShellPage extends StatefulWidget {
  const FinanceiroShellPage({
    super.key,
    this.abrirForm = false,
    this.abrirInvestidores = false,
  });

  final bool abrirForm;
  final bool abrirInvestidores;

  @override
  State<FinanceiroShellPage> createState() => _FinanceiroShellPageState();
}

enum _Passo {
  abas,
  form,
  detalhe,
  baixa,
  conta,
  contaForm,
  saldo,
  relatorio,
  investidores,
  investidorForm,
  contratos,
  contratoForm,
  contratoDetalhe,
  entradaForm,
  despesasLista,
  despesaDetalhe,
  despesaForm,
  vendasLista,
  vendaForm,
  acerto,
  financeiroVenda,
  baixaTitulo,
}

enum _VoltaBaixa { contrato, despesas, despesaDetalhe, financeiroVenda }

class _FinanceiroShellPageState extends State<FinanceiroShellPage> {
  final _loja = FinanceiroLoja();
  int _aba = 0;
  _Passo _passo = _Passo.abas;
  LancamentoMock? _lancamento;
  ContaMock? _conta;
  bool _contaNova = true;
  bool _editando = false;
  String? _relatorio;
  ModoAjusteSaldo _modoSaldo = ModoAjusteSaldo.abertura;
  ParteFin? _investidor;
  ParteFin? _investidorEdicao;
  ParceriaFin? _parceria;
  TituloParceriaFin? _tituloParceria;
  VendaParceriaFin? _vendaParceria;
  _VoltaBaixa _voltaBaixa = _VoltaBaixa.contrato;
  _Passo _voltaDespesaForm = _Passo.despesasLista;
  _Passo _voltaVendaForm = _Passo.vendasLista;

  @override
  void initState() {
    super.initState();
    if (widget.abrirInvestidores) {
      _aba = 2;
      _passo = _Passo.investidores;
    } else if (widget.abrirForm) {
      _passo = _Passo.form;
    }
  }

  void _voltarInvestidoresRaiz() {
    if (widget.abrirInvestidores) {
      Modular.to.pop();
      return;
    }
    setState(() {
      _aba = 2;
      _passo = _Passo.abas;
    });
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
        title: const Text('Inativar conta?', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700)),
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
    try {
      await _loja.inativar(conta.id, texto.trim().isEmpty ? 'Inativação da conta' : texto.trim());
    } on ApiException catch (error) {
      if (!mounted) return;
      AppSnackBar.show(context: context, message: error.message);
      return;
    }
    if (!mounted) return;
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
          final mioloPilha = _passo == _Passo.abas
              ? miolo
              : Theme(
                  data: Theme.of(context).copyWith(
                    appBarTheme: Theme.of(context).appBarTheme.copyWith(
                          titleTextStyle: estiloTituloAppBarPilha(),
                        ),
                    textTheme: Theme.of(context).textTheme.apply(fontSizeFactor: 0.94),
                  ),
                  child: miolo,
                );
          if (!largo || _passo != _Passo.abas) return mioloPilha;
          return Row(
            children: [
              _menuLateral(),
              const VerticalDivider(width: 1),
              Expanded(child: mioloPilha),
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
                title: Text(itens[i], style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600)),
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
        item: _editando ? _lancamento : null,
        aoFechar: () => setState(() {
          _editando = false;
          _aba = 1;
          _passo = _Passo.abas;
        }),
      );
    }
    if (_passo == _Passo.detalhe && _lancamento != null) {
      return LancamentoDetalhePage(
        item: _lancamento!,
        aoVoltar: () => setState(() => _passo = _Passo.abas),
        aoBaixa: () => setState(() {
          final id = _lancamento!.id;
          _lancamento = _loja.lancamentos.where((e) => e.id == id).firstOrNull ?? _lancamento;
          _passo = _Passo.baixa;
        }),
        aoEditar: () => setState(() {
          _editando = true;
          _passo = _Passo.form;
        }),
        aoEstornar: ({required data, required motivo}) async {
          await _loja.estornar(_lancamento!.id, data: data, motivo: motivo);
          if (!mounted) return;
          setState(() {
            _lancamento = _loja.lancamentos.cast<LancamentoMock?>().where((e) => e?.id == _lancamento!.id).firstOrNull;
            _passo = _Passo.abas;
          });
        },
        aoEstornarPagamento: ({required data, required motivo, baixaId}) async {
          final id = _lancamento!.id;
          await _loja.estornarPagamento(
            id,
            data: data,
            motivo: motivo,
            baixaId: baixaId,
          );
          if (!mounted) return;
          final atualizado = _loja.lancamentos.where((e) => e.id == id).firstOrNull;
          setState(() {
            _lancamento = atualizado;
            _passo = atualizado == null ? _Passo.abas : _Passo.detalhe;
          });
          if (atualizado != null && mounted) {
            AppSnackBar.show(context: context, message: 'Baixa estornada.', isError: false);
          }
        },
      );
    }
    if (_passo == _Passo.baixa && _lancamento != null) {
      return RegistrarBaixaPage(
        item: _lancamento!,
        aoVoltar: () => setState(() => _passo = _Passo.detalhe),
        aoConfirmar: (valor, conta, {data}) async {
          try {
            final id = _lancamento!.id;
            await _loja.registrarBaixa(
              id,
              valor: valor,
              conta: conta,
              data: data,
            );
            if (!mounted) return;
            final atualizado = _loja.lancamentos.where((e) => e.id == id).firstOrNull;
            setState(() {
              _lancamento = atualizado;
              _passo = atualizado == null || atualizado.pendente <= 0.001
                  ? _Passo.abas
                  : _Passo.detalhe;
            });
            AppSnackBar.show(context: context, message: 'Baixa registrada.', isError: false);
          } on ApiException catch (error) {
            if (!mounted) return;
            AppSnackBar.show(context: context, message: error.message);
          }
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
        aoSaldo: (modo) => setState(() {
          _modoSaldo = modo;
          _passo = _Passo.saldo;
        }),
      );
    }
    if (_passo == _Passo.contaForm) {
      return ContaFormPage(
        conta: _contaNova ? null : _conta,
        aoVoltar: () => setState(() {
          if (!_contaNova && _conta != null) {
            _conta = _loja.contas.where((c) => c.id == _conta!.id).firstOrNull ?? _conta;
          }
          _passo = _contaNova ? _Passo.abas : _Passo.conta;
        }),
        aoSaldoInicial: (conta) => setState(() {
          _conta = conta;
          _modoSaldo = ModoAjusteSaldo.abertura;
          _passo = _Passo.saldo;
        }),
      );
    }
    if (_passo == _Passo.saldo && _conta != null) {
      return SaldoInicialPage(
        conta: _conta!,
        modo: _modoSaldo,
        aoVoltar: () => setState(() {
          _conta = _loja.contas.where((c) => c.id == _conta!.id).firstOrNull ?? _conta;
          _passo = _Passo.conta;
        }),
      );
    }
    if (_passo == _Passo.relatorio && _relatorio != null) {
      return RelatorioDetalhePage(
        id: _relatorio!,
        aoVoltar: () => setState(() => _passo = _Passo.abas),
      );
    }
    if (_passo == _Passo.investidores) {
      return InvestidoresPage(
        aoVoltar: _voltarInvestidoresRaiz,
        aoAbrir: (item) => setState(() {
          _investidor = item;
          _passo = _Passo.contratos;
        }),
        aoAdicionar: () => setState(() {
          _investidorEdicao = null;
          _passo = _Passo.investidorForm;
        }),
      );
    }
    if (_passo == _Passo.investidorForm) {
      final editando = _investidorEdicao != null;
      return InvestidorFormPage(
        investidor: _investidorEdicao,
        aoVoltar: () => setState(() {
          _passo = editando ? _Passo.contratos : _Passo.investidores;
          _investidorEdicao = null;
        }),
        aoSalvo: (item) => setState(() {
          _investidor = item;
          _investidorEdicao = null;
          _passo = _Passo.contratos;
        }),
      );
    }
    if (_passo == _Passo.contratos && _investidor != null) {
      return ContratosInvestidorPage(
        investidor: _investidor!,
        aoVoltar: () => setState(() => _passo = _Passo.investidores),
        aoAbrir: (item) => setState(() {
          _parceria = item;
          _passo = _Passo.contratoDetalhe;
        }),
        aoAdicionar: () => setState(() => _passo = _Passo.contratoForm),
        aoEditar: () => setState(() {
          _investidorEdicao = _investidor;
          _passo = _Passo.investidorForm;
        }),
        aoExcluir: () async {
          if (!mounted) return;
          setState(() {
            _investidor = null;
            _parceria = null;
            _passo = _Passo.investidores;
          });
        },
      );
    }
    if (_passo == _Passo.contratoForm && _investidor != null) {
      return ContratoFormPage(
        investidor: _investidor!,
        aoVoltar: () => setState(() => _passo = _Passo.contratos),
        aoSalvo: (item) => setState(() {
          _parceria = item;
          _passo = _Passo.contratoDetalhe;
        }),
      );
    }
    if (_passo == _Passo.contratoDetalhe && _parceria != null) {
      return ContratoDetalhePage(
        parceriaId: _parceria!.id,
        aoVoltar: () => setState(() => _passo = _Passo.contratos),
        aoRegistrarEntrada: () => setState(() => _passo = _Passo.entradaForm),
        aoDespesas: () => setState(() => _passo = _Passo.despesasLista),
        aoVendas: () => setState(() => _passo = _Passo.vendasLista),
        aoBaixaTitulo: (titulo) => setState(() {
          _tituloParceria = titulo;
          _voltaBaixa = _VoltaBaixa.contrato;
          _passo = _Passo.baixaTitulo;
        }),
        aoInativar: () async {
          if (!mounted) return;
          setState(() => _passo = _Passo.contratos);
        },
      );
    }
    if (_passo == _Passo.entradaForm && _parceria != null) {
      return EntradaParceriaPage(
        parceriaId: _parceria!.id,
        aoVoltar: () => setState(() => _passo = _Passo.contratoDetalhe),
        aoSalvo: () => setState(() => _passo = _Passo.contratoDetalhe),
      );
    }
    if (_passo == _Passo.despesasLista && _parceria != null) {
      return DespesasParceriaPage(
        parceriaId: _parceria!.id,
        aoVoltar: () => setState(() => _passo = _Passo.contratoDetalhe),
        aoAdicionar: () => setState(() {
          _voltaDespesaForm = _Passo.despesasLista;
          _passo = _Passo.despesaForm;
        }),
        aoAbrir: (titulo) => setState(() {
          _tituloParceria = titulo;
          _passo = _Passo.despesaDetalhe;
        }),
      );
    }
    if (_passo == _Passo.despesaDetalhe && _parceria != null && _tituloParceria != null) {
      return DespesaParceriaDetalhePage(
        parceriaId: _parceria!.id,
        titulo: _tituloParceria!,
        aoVoltar: () => setState(() => _passo = _Passo.despesasLista),
        aoPagar: () => setState(() {
          _voltaBaixa = _VoltaBaixa.despesaDetalhe;
          _passo = _Passo.baixaTitulo;
        }),
      );
    }
    if (_passo == _Passo.despesaForm && _parceria != null) {
      return DespesaParceriaFormPage(
        parceriaId: _parceria!.id,
        aoVoltar: () => setState(() => _passo = _voltaDespesaForm),
        aoSalvo: () => setState(() => _passo = _Passo.despesasLista),
      );
    }
    if (_passo == _Passo.vendasLista && _parceria != null) {
      return VendasParceriaPage(
        parceriaId: _parceria!.id,
        aoVoltar: () => setState(() => _passo = _Passo.contratoDetalhe),
        aoRegistrar: () => setState(() {
          _voltaVendaForm = _Passo.vendasLista;
          _passo = _Passo.vendaForm;
        }),
        aoAcerto: (venda) => setState(() {
          _vendaParceria = venda;
          // Acerto já confirmado: só financeiro (não reabre simulação).
          _passo = venda.acertoConfirmado ? _Passo.financeiroVenda : _Passo.acerto;
        }),
        aoFinanceiro: (venda) => setState(() {
          _vendaParceria = venda;
          _passo = _Passo.financeiroVenda;
        }),
      );
    }
    if (_passo == _Passo.vendaForm && _parceria != null) {
      return VendaParceriaFormPage(
        parceriaId: _parceria!.id,
        aoVoltar: () => setState(() => _passo = _voltaVendaForm),
        aoSalvo: (vendaId) => setState(() {
          _vendaParceria = VendaParceriaFin(
            id: vendaId,
            data: '',
            precoKg: '',
          );
          _passo = _Passo.acerto;
        }),
      );
    }
    if (_passo == _Passo.acerto && _parceria != null && _vendaParceria != null) {
      // Defesa: se lista atualizou e venda já tem acerto, manda pro financeiro.
      final vendaAtual = (_parceria?.vendas ?? const <VendaParceriaFin>[])
          .where((v) => v.id == _vendaParceria!.id)
          .firstOrNull;
      if (vendaAtual?.acertoConfirmado == true || _vendaParceria!.acertoConfirmado) {
        return FinanceiroVendaParceriaPage(
          parceriaId: _parceria!.id,
          vendaId: _vendaParceria!.id,
          aoVoltar: () => setState(() => _passo = _Passo.vendasLista),
          aoBaixa: (titulo) => setState(() {
            _tituloParceria = titulo;
            _voltaBaixa = _VoltaBaixa.financeiroVenda;
            _passo = _Passo.baixaTitulo;
          }),
        );
      }
      return AcertoParceriaPage(
        parceriaId: _parceria!.id,
        vendaId: _vendaParceria!.id,
        aoVoltar: () => setState(() => _passo = _Passo.vendasLista),
        aoConfirmado: () => setState(() {
          _vendaParceria = (_vendaParceria ?? vendaAtual)?.copiar(acertoConfirmado: true) ??
              VendaParceriaFin(id: _vendaParceria!.id, data: '', precoKg: '', acertoConfirmado: true);
          _passo = _Passo.financeiroVenda;
        }),
      );
    }
    if (_passo == _Passo.financeiroVenda && _parceria != null && _vendaParceria != null) {
      return FinanceiroVendaParceriaPage(
        parceriaId: _parceria!.id,
        vendaId: _vendaParceria!.id,
        aoVoltar: () => setState(() => _passo = _Passo.vendasLista),
        aoBaixa: (titulo) => setState(() {
          _tituloParceria = titulo;
          _voltaBaixa = _VoltaBaixa.financeiroVenda;
          _passo = _Passo.baixaTitulo;
        }),
      );
    }
    if (_passo == _Passo.baixaTitulo && _parceria != null && _tituloParceria != null) {
      return BaixaTituloParceriaPage(
        parceriaId: _parceria!.id,
        titulo: _tituloParceria!,
        aoVoltar: () => setState(() {
          _passo = switch (_voltaBaixa) {
            _VoltaBaixa.contrato => _Passo.contratoDetalhe,
            _VoltaBaixa.despesas => _Passo.despesasLista,
            _VoltaBaixa.despesaDetalhe => _Passo.despesaDetalhe,
            _VoltaBaixa.financeiroVenda => _Passo.financeiroVenda,
          };
        }),
        aoSalvo: () => setState(() {
          _passo = switch (_voltaBaixa) {
            _VoltaBaixa.contrato => _Passo.contratoDetalhe,
            _VoltaBaixa.despesas => _Passo.despesasLista,
            _VoltaBaixa.despesaDetalhe => _Passo.despesasLista,
            _VoltaBaixa.financeiroVenda => _Passo.financeiroVenda,
          };
        }),
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
                    Icon(LucideIcons.home, size: 16, color: MyColors.colorPrimary),
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
          RelatoriosPage(
            aoAbrir: (id) => setState(() {
              _aba = 2;
              if (id == 'investidor') {
                _passo = _Passo.investidores;
                return;
              }
              _relatorio = id;
              _passo = _Passo.relatorio;
            }),
          ),
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
              onPressed: () => setState(() {
                _editando = false;
                _lancamento = null;
                _passo = _Passo.form;
              }),
              backgroundColor: MyColors.colorPrimary,
              icon: const Icon(Icons.add),
              label: const Text('Novo lançamento', style: TextStyle(fontFamily: 'Montserrat')),
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
                  label: const Text('Adicionar conta', style: TextStyle(fontFamily: 'Montserrat')),
                )
              : null,
      bottomNavigationBar: barra
          ? _BarraFinanceiro(indice: _aba, aoEscolher: _abaIr)
          : null,
    );
  }
}
