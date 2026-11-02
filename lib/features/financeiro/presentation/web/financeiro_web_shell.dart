import 'dart:async';

import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/core/components/web_dialog_frame.dart';
import 'package:costeira/core/components/web_page_dialog.dart';
import 'package:costeira/core/menus/app_menus_controller.dart';
import 'package:costeira/features/dashboard/presentation/web/dashboard_web_page.dart';
import 'package:costeira/features/financeiro/domain/financeiro_mock.dart';
import 'package:costeira/features/financeiro/presentation/financeiro_acesso.dart';
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
import 'package:costeira/features/financeiro/presentation/pages/venda_parceria_form_page.dart';
import 'package:costeira/features/financeiro/presentation/pages/vendas_parceria_page.dart';
// FinanceiroVendaParceriaPage vive neste arquivo junto com a baixa de título.
import 'package:costeira/features/financeiro/presentation/web/pages/financeiro_contas_web.dart';
import 'package:costeira/features/financeiro/presentation/web/pages/financeiro_lancamentos_web.dart';
import 'package:costeira/features/financeiro/presentation/web/pages/financeiro_relatorios_web.dart';
import 'package:costeira/features/financeiro/presentation/web/pages/financeiro_visao_web.dart';
import 'package:costeira/features/financeiro/presentation/web/widgets/financeiro_web_ui.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:lucide_icons/lucide_icons.dart';

enum FinanceiroWebAba { visao, lancamentos, relatorios, contas }

enum _PassoWeb {
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

enum _VoltaBaixaWeb { contrato, despesas, despesaDetalhe, financeiroVenda }

class FinanceiroWebShell extends StatefulWidget {
  const FinanceiroWebShell({
    super.key,
    required this.onExit,
    this.abrirForm = false,
    this.abrirInvestidores = false,
  });

  final VoidCallback onExit;
  final bool abrirForm;
  final bool abrirInvestidores;

  @override
  State<FinanceiroWebShell> createState() => _FinanceiroWebShellState();
}

class _FinanceiroWebShellState extends State<FinanceiroWebShell> {
  final _loja = FinanceiroLoja();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _passoTick = ValueNotifier<int>(0);
  FinanceiroWebAba _aba = FinanceiroWebAba.visao;
  _PassoWeb _passo = _PassoWeb.abas;
  bool _dialogAberto = false;
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
  _VoltaBaixaWeb _voltaBaixa = _VoltaBaixaWeb.contrato;
  _PassoWeb _voltaDespesaForm = _PassoWeb.despesasLista;
  _PassoWeb _voltaVendaForm = _PassoWeb.vendasLista;

  @override
  void initState() {
    super.initState();
    if (widget.abrirInvestidores) {
      _aba = FinanceiroWebAba.relatorios;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.abrirInvestidores) {
        _setPasso(_PassoWeb.investidores);
      } else if (widget.abrirForm) {
        _setPasso(_PassoWeb.form);
      }
    });
  }

  @override
  void dispose() {
    _passoTick.dispose();
    _loja.dispose();
    super.dispose();
  }

  void _abaIr(FinanceiroWebAba aba) {
    setState(() => _aba = aba);
    _setPasso(_PassoWeb.abas);
  }

  void _setPasso(_PassoWeb passo) {
    final saindo = _passo != _PassoWeb.abas && passo == _PassoWeb.abas;
    final entrando = _passo == _PassoWeb.abas && passo != _PassoWeb.abas;
    if (_passo == passo && !entrando && !saindo) {
      _passoTick.value++;
      return;
    }
    setState(() => _passo = passo);
    _passoTick.value++;
    if (entrando) {
      unawaited(_abrirDialogSecundario());
    } else if (saindo && _dialogAberto) {
      final nav = Navigator.of(context, rootNavigator: true);
      if (nav.canPop()) nav.pop();
    }
  }

  String _tituloPasso() {
    return switch (_passo) {
      _PassoWeb.form => _editando ? 'Editar lançamento' : 'Novo lançamento',
      _PassoWeb.detalhe => 'Detalhe do lançamento',
      _PassoWeb.baixa => 'Registrar baixa',
      _PassoWeb.conta => 'Detalhe da conta',
      _PassoWeb.contaForm => _contaNova ? 'Nova conta' : 'Editar conta',
      _PassoWeb.saldo => switch (_modoSaldo) {
        ModoAjusteSaldo.abertura => 'Saldo inicial',
        ModoAjusteSaldo.entrada => 'Ajuste de entrada',
        ModoAjusteSaldo.saida => 'Ajuste de saída',
      },
      _PassoWeb.relatorio => switch (_relatorio) {
        'extrato' => 'Extrato / Livro caixa',
        'fluxo' => 'Fluxo de caixa',
        'dre' => 'DRE',
        'resultado' => 'Resultado por categoria',
        _ => 'Relatório',
      },
      _PassoWeb.investidores => 'Investidores',
      _PassoWeb.investidorForm =>
        _investidorEdicao == null ? 'Novo investidor' : 'Editar investidor',
      _PassoWeb.contratos => 'Contratos',
      _PassoWeb.contratoForm => 'Novo contrato',
      _PassoWeb.contratoDetalhe => 'Detalhe do contrato',
      _PassoWeb.entradaForm => 'Entrada de animais',
      _PassoWeb.despesasLista => 'Despesas da parceria',
      _PassoWeb.despesaDetalhe => 'Detalhe da despesa',
      _PassoWeb.despesaForm => 'Nova despesa',
      _PassoWeb.vendasLista => 'Vendas da parceria',
      _PassoWeb.vendaForm => 'Registrar venda',
      _PassoWeb.acerto => 'Acerto da parceria',
      _PassoWeb.financeiroVenda => 'Financeiro da venda',
      _PassoWeb.baixaTitulo => 'Baixa de título',
      _PassoWeb.abas => 'Financeiro',
    };
  }

  Future<void> _abrirDialogSecundario() async {
    if (_dialogAberto || !mounted) return;
    _dialogAberto = true;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return FinanceiroEscopo(
          loja: _loja,
          child: AnimatedBuilder(
            animation: _passoTick,
            builder: (context, _) {
              if (_passo == _PassoWeb.abas) {
                return const SizedBox.shrink();
              }
              final pagina = _subfluxo();
              if (pagina == null) return const SizedBox.shrink();
              if (_passo == _PassoWeb.relatorio) {
                return WebDialogFrame(
                  title: _tituloPasso(),
                  width: 860,
                  maxHeight: 840,
                  sizeMode: WebDialogSizeMode.constrained,
                  preferredHeight: 760,
                  child: pagina,
                );
              }
              return WebPageDialog(
                title: _tituloPasso(),
                width: 820,
                maxHeight: 860,
                child: pagina,
              );
            },
          ),
        );
      },
    );
    _dialogAberto = false;
    if (mounted && _passo != _PassoWeb.abas) {
      setState(() => _passo = _PassoWeb.abas);
      _passoTick.value++;
    }
  }

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
    try {
      await _loja.inativar(
        conta.id,
        texto.trim().isEmpty ? 'Inativação da conta' : texto.trim(),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      AppSnackBar.show(context: context, message: error.message);
      return;
    }
    if (!mounted) return;
    _setPasso(_PassoWeb.abas);
  }

  @override
  Widget build(BuildContext context) {
    final menus = Modular.get<AppMenusController>();
    if (!podeVerFinanceiro(menus)) {
      return ColoredBox(
        color: financeiroWebFundo,
        child: Center(
          child: FinanceiroWebEmpty(
            message: 'Você não tem permissão para acessar o Financeiro.',
            actionLabel: 'Voltar ao Dashboard',
            onAction: widget.onExit,
          ),
        ),
      );
    }

    return FinanceiroEscopo(
      loja: _loja,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final useRail = constraints.maxWidth >= 760;
          return Scaffold(
            key: _scaffoldKey,
            backgroundColor: financeiroWebFundo,
            drawer: useRail
                ? null
                : Drawer(child: SafeArea(child: _rail(closeDrawer: true))),
            body: Row(
              children: [
                if (useRail) ...[
                  SizedBox(
                    width: constraints.maxWidth >= 1120 ? 264 : 232,
                    child: _rail(),
                  ),
                  const VerticalDivider(width: 1, color: financeiroWebBorda),
                ],
                Expanded(
                  child: Column(
                    children: [
                      _topBar(showMenu: !useRail),
                      const Divider(height: 1, color: financeiroWebBorda),
                      Expanded(child: _conteudo()),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _topBar({required bool showMenu}) {
    return ColoredBox(
      color: const Color(0xFFFAF9F5),
      child: SizedBox(
        height: 64,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final showControls = constraints.maxWidth >= 980;
            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: constraints.maxWidth < 760 ? 12 : 28,
              ),
              child: Row(
                children: [
                  if (showMenu)
                    IconButton(
                      tooltip: 'Menu',
                      onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                      icon: const Icon(LucideIcons.menu, size: 18),
                    ),
                  const Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Financeiro',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF252A27),
                          ),
                        ),
                        Text(
                          'Ambiente financeiro',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF7B827D),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (showControls)
                    SizedBox(width: 720, height: 46, child: _topControls())
                  else
                    AnimatedBuilder(
                      animation: _loja,
                      builder: (context, _) => Text(
                        '${_loja.fazendaNome} · ${_loja.anoAgricolaLabel}',
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6B6B6B),
                        ),
                      ),
                    ),
                  const SizedBox(width: 12),
                  SizedBox(
                    height: 46,
                    child: OutlinedButton.icon(
                      onPressed: widget.onExit,
                      icon: const Icon(LucideIcons.home, size: 16),
                      label: const Text('Voltar ao Dashboard'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: MyColors.colorPrimary,
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFFC9D4CB)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _topControls() {
    return AnimatedBuilder(
      animation: _loja,
      builder: (context, _) {
        final ano = _loja.anoAgricola?.label ?? '';
        return DashboardWebToolbar(
          data: DashboardWebToolbarData(
            farms: List.unmodifiable(_loja.fazendas),
            selectedFarmId: _loja.fazendaId,
            years: List.unmodifiable(_loja.anosAgricolas),
            selectedPeriod: ano,
            customPeriodLabel: 'Selecionar datas',
            loadingFarms: _loja.carregandoContexto,
            loadingDashboard: _loja.carregando,
            farmLabel: (farm) {
              final nome = farm.nome.trim().isNotEmpty
                  ? farm.nome.trim()
                  : farm.nomeFantasia.trim();
              return nome.isEmpty ? 'Fazenda ${farm.id}' : nome;
            },
            onFarmChanged: (id) async {
              if (id != null) await _loja.selecionarFazenda(id);
            },
            onPeriodChanged: (label) async {
              final selecionado = _loja.anosAgricolas
                  .where((item) => item.label == label)
                  .firstOrNull;
              if (selecionado != null) {
                await _loja.selecionarAnoAgricola(selecionado);
              }
            },
            onRefresh: _loja.carregar,
          ),
        );
      },
    );
  }

  Widget _rail({bool closeDrawer = false}) {
    const itens = [
      (FinanceiroWebAba.visao, 'Visão geral', LucideIcons.layoutDashboard),
      (FinanceiroWebAba.lancamentos, 'Lançamentos', LucideIcons.list),
      (FinanceiroWebAba.relatorios, 'Relatórios', LucideIcons.barChart3),
      (FinanceiroWebAba.contas, 'Contas', LucideIcons.landmark),
    ];
    return ColoredBox(
      color: const Color(0xFFF3F1E9),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(2, 0, 2, 12),
            child: SizedBox(
              height: 100,
              width: double.infinity,
              child: ClipRect(
                child: Transform.scale(
                  scale: 1.12,
                  child: Image.asset(
                    'images/logosplash.png',
                    width: double.infinity,
                    height: 100,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                  ),
                ),
              ),
            ),
          ),
          for (final item in itens)
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Material(
                color: _aba == item.$1
                    ? const Color(0xFFE1E9E0)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                child: ListTile(
                  selected: _aba == item.$1,
                  leading: Icon(
                    item.$3,
                    size: 18,
                    color: _aba == item.$1
                        ? MyColors.colorPrimary
                        : const Color(0xFF666666),
                  ),
                  title: Text(
                    item.$2,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  selectedColor: MyColors.colorPrimary,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  onTap: () {
                    if (closeDrawer) Navigator.of(context).pop();
                    _abaIr(item.$1);
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _conteudo() {
    return IndexedStack(
      index: _aba.index,
      children: [
        FinanceiroVisaoWeb(
          aoVerExtrato: () {
            setState(() {
              _aba = FinanceiroWebAba.relatorios;
              _relatorio = 'extrato';
            });
            _setPasso(_PassoWeb.relatorio);
          },
          aoAbrir: (item) {
            setState(() => _lancamento = item);
            _setPasso(_PassoWeb.detalhe);
          },
          aoNovoLancamento: () {
            setState(() {
              _editando = false;
              _lancamento = null;
            });
            _setPasso(_PassoWeb.form);
          },
        ),
        FinanceiroLancamentosWeb(
          aoAbrir: (item) {
            setState(() => _lancamento = item);
            _setPasso(_PassoWeb.detalhe);
          },
          aoNovo: () {
            setState(() {
              _editando = false;
              _lancamento = null;
            });
            _setPasso(_PassoWeb.form);
          },
        ),
        FinanceiroRelatoriosWeb(
          aoAbrir: (id) {
            if (id == 'investidor') {
              _setPasso(_PassoWeb.investidores);
              return;
            }
            setState(() => _relatorio = id);
            _setPasso(_PassoWeb.relatorio);
          },
        ),
        FinanceiroContasWeb(
          aoAbrir: (conta) {
            setState(() => _conta = conta);
            _setPasso(_PassoWeb.conta);
          },
          aoNova: () {
            setState(() {
              _contaNova = true;
              _conta = null;
            });
            _setPasso(_PassoWeb.contaForm);
          },
        ),
      ],
    );
  }

  Widget? _subfluxo() {
    if (_passo == _PassoWeb.form) {
      return LancamentoFormPage(
        item: _editando ? _lancamento : null,
        aoFechar: () {
          setState(() {
            _editando = false;
            _aba = FinanceiroWebAba.lancamentos;
          });
          _setPasso(_PassoWeb.abas);
        },
      );
    }
    if (_passo == _PassoWeb.detalhe && _lancamento != null) {
      return LancamentoDetalhePage(
        item: _lancamento!,
        aoVoltar: () => _setPasso(_PassoWeb.abas),
        aoBaixa: () {
          final id = _lancamento!.id;
          setState(() {
            _lancamento =
                _loja.lancamentos.where((e) => e.id == id).firstOrNull ??
                _lancamento;
          });
          _setPasso(_PassoWeb.baixa);
        },
        aoEditar: () {
          setState(() => _editando = true);
          _setPasso(_PassoWeb.form);
        },
        aoEstornar: ({required data, required motivo}) async {
          await _loja.estornar(_lancamento!.id, data: data, motivo: motivo);
          if (!mounted) return;
          setState(() {
            _lancamento = _loja.lancamentos
                .cast<LancamentoMock?>()
                .where((e) => e?.id == _lancamento!.id)
                .firstOrNull;
          });
          _setPasso(_PassoWeb.abas);
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
          final atualizado = _loja.lancamentos
              .where((e) => e.id == id)
              .firstOrNull;
          setState(() => _lancamento = atualizado);
          _setPasso(atualizado == null ? _PassoWeb.abas : _PassoWeb.detalhe);
          if (atualizado != null && mounted) {
            AppSnackBar.show(
              context: context,
              message: 'Baixa estornada.',
              isError: false,
            );
          }
        },
      );
    }
    if (_passo == _PassoWeb.baixa && _lancamento != null) {
      return RegistrarBaixaPage(
        item: _lancamento!,
        aoVoltar: () => _setPasso(_PassoWeb.detalhe),
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
            final atualizado = _loja.lancamentos
                .where((e) => e.id == id)
                .firstOrNull;
            setState(() => _lancamento = atualizado);
            _setPasso(
              atualizado == null || atualizado.pendente <= 0.001
                  ? _PassoWeb.abas
                  : _PassoWeb.detalhe,
            );
            AppSnackBar.show(
              context: context,
              message: 'Baixa registrada.',
              isError: false,
            );
          } on ApiException catch (error) {
            if (!mounted) return;
            AppSnackBar.show(context: context, message: error.message);
          }
        },
      );
    }
    if (_passo == _PassoWeb.conta && _conta != null) {
      return ContaDetalhePage(
        conta: _conta!,
        aoVoltar: () => _setPasso(_PassoWeb.abas),
        aoEditar: () {
          setState(() => _contaNova = false);
          _setPasso(_PassoWeb.contaForm);
        },
        aoInativar: _inativar,
        aoSaldo: (modo) {
          setState(() => _modoSaldo = modo);
          _setPasso(_PassoWeb.saldo);
        },
      );
    }
    if (_passo == _PassoWeb.contaForm) {
      return ContaFormPage(
        conta: _contaNova ? null : _conta,
        aoVoltar: () {
          if (!_contaNova && _conta != null) {
            setState(() {
              _conta =
                  _loja.contas.where((c) => c.id == _conta!.id).firstOrNull ??
                  _conta;
            });
          }
          _setPasso(_contaNova ? _PassoWeb.abas : _PassoWeb.conta);
        },
        aoSaldoInicial: (conta) {
          setState(() {
            _conta = conta;
            _modoSaldo = ModoAjusteSaldo.abertura;
          });
          _setPasso(_PassoWeb.saldo);
        },
      );
    }
    if (_passo == _PassoWeb.saldo && _conta != null) {
      return SaldoInicialPage(
        conta: _conta!,
        modo: _modoSaldo,
        aoVoltar: () {
          setState(() {
            _conta =
                _loja.contas.where((c) => c.id == _conta!.id).firstOrNull ??
                _conta;
          });
          _setPasso(_PassoWeb.conta);
        },
      );
    }
    if (_passo == _PassoWeb.relatorio && _relatorio != null) {
      return FinanceiroRelatorioDetalheWeb(
        id: _relatorio!,
        aoVoltar: () => _setPasso(_PassoWeb.abas),
        ocultarCabecalho: true,
      );
    }
    if (_passo == _PassoWeb.investidores) {
      return InvestidoresPage(
        aoVoltar: () {
          if (widget.abrirInvestidores) {
            _setPasso(_PassoWeb.abas);
            widget.onExit();
            return;
          }
          setState(() => _aba = FinanceiroWebAba.relatorios);
          _setPasso(_PassoWeb.abas);
        },
        aoAbrir: (item) {
          setState(() => _investidor = item);
          _setPasso(_PassoWeb.contratos);
        },
        aoAdicionar: () {
          setState(() => _investidorEdicao = null);
          _setPasso(_PassoWeb.investidorForm);
        },
      );
    }
    if (_passo == _PassoWeb.investidorForm) {
      final editando = _investidorEdicao != null;
      return InvestidorFormPage(
        investidor: _investidorEdicao,
        aoVoltar: () {
          setState(() => _investidorEdicao = null);
          _setPasso(editando ? _PassoWeb.contratos : _PassoWeb.investidores);
        },
        aoSalvo: (item) {
          setState(() {
            _investidor = item;
            _investidorEdicao = null;
          });
          _setPasso(_PassoWeb.contratos);
        },
      );
    }
    if (_passo == _PassoWeb.contratos && _investidor != null) {
      return ContratosInvestidorPage(
        investidor: _investidor!,
        aoVoltar: () => _setPasso(_PassoWeb.investidores),
        aoAbrir: (item) {
          setState(() => _parceria = item);
          _setPasso(_PassoWeb.contratoDetalhe);
        },
        aoAdicionar: () => _setPasso(_PassoWeb.contratoForm),
        aoEditar: () {
          setState(() => _investidorEdicao = _investidor);
          _setPasso(_PassoWeb.investidorForm);
        },
        aoExcluir: () async {
          if (!mounted) return;
          setState(() {
            _investidor = null;
            _parceria = null;
          });
          _setPasso(_PassoWeb.investidores);
        },
      );
    }
    if (_passo == _PassoWeb.contratoForm && _investidor != null) {
      return ContratoFormPage(
        investidor: _investidor!,
        aoVoltar: () => _setPasso(_PassoWeb.contratos),
        aoSalvo: (item) {
          setState(() => _parceria = item);
          _setPasso(_PassoWeb.contratoDetalhe);
        },
      );
    }
    if (_passo == _PassoWeb.contratoDetalhe && _parceria != null) {
      return ContratoDetalhePage(
        parceriaId: _parceria!.id,
        aoVoltar: () => _setPasso(_PassoWeb.contratos),
        aoRegistrarEntrada: () =>
            _setPasso(_PassoWeb.entradaForm),
        aoDespesas: () => _setPasso(_PassoWeb.despesasLista),
        aoVendas: () => _setPasso(_PassoWeb.vendasLista),
        aoBaixaTitulo: (titulo) {
          setState(() {
            _tituloParceria = titulo;
            _voltaBaixa = _VoltaBaixaWeb.contrato;
          });
          _setPasso(_PassoWeb.baixaTitulo);
        },
        aoInativar: () async {
          if (!mounted) return;
          _setPasso(_PassoWeb.contratos);
        },
      );
    }
    if (_passo == _PassoWeb.entradaForm && _parceria != null) {
      return EntradaParceriaPage(
        parceriaId: _parceria!.id,
        aoVoltar: () => _setPasso(_PassoWeb.contratoDetalhe),
        aoSalvo: () => _setPasso(_PassoWeb.contratoDetalhe),
      );
    }
    if (_passo == _PassoWeb.despesasLista && _parceria != null) {
      return DespesasParceriaPage(
        parceriaId: _parceria!.id,
        aoVoltar: () => _setPasso(_PassoWeb.contratoDetalhe),
        aoAdicionar: () {
          setState(() => _voltaDespesaForm = _PassoWeb.despesasLista);
          _setPasso(_PassoWeb.despesaForm);
        },
        aoAbrir: (titulo) {
          setState(() => _tituloParceria = titulo);
          _setPasso(_PassoWeb.despesaDetalhe);
        },
      );
    }
    if (_passo == _PassoWeb.despesaDetalhe &&
        _parceria != null &&
        _tituloParceria != null) {
      return DespesaParceriaDetalhePage(
        parceriaId: _parceria!.id,
        titulo: _tituloParceria!,
        aoVoltar: () => _setPasso(_PassoWeb.despesasLista),
        aoPagar: () {
          setState(() => _voltaBaixa = _VoltaBaixaWeb.despesaDetalhe);
          _setPasso(_PassoWeb.baixaTitulo);
        },
      );
    }
    if (_passo == _PassoWeb.despesaForm && _parceria != null) {
      return DespesaParceriaFormPage(
        parceriaId: _parceria!.id,
        aoVoltar: () => _setPasso(_voltaDespesaForm),
        aoSalvo: () => _setPasso(_PassoWeb.despesasLista),
      );
    }
    if (_passo == _PassoWeb.vendasLista && _parceria != null) {
      return VendasParceriaPage(
        parceriaId: _parceria!.id,
        aoVoltar: () => _setPasso(_PassoWeb.contratoDetalhe),
        aoRegistrar: () {
          setState(() => _voltaVendaForm = _PassoWeb.vendasLista);
          _setPasso(_PassoWeb.vendaForm);
        },
        aoAcerto: (venda) {
          setState(() => _vendaParceria = venda);
          _setPasso(
            venda.acertoConfirmado
                ? _PassoWeb.financeiroVenda
                : _PassoWeb.acerto,
          );
        },
        aoFinanceiro: (venda) {
          setState(() => _vendaParceria = venda);
          _setPasso(_PassoWeb.financeiroVenda);
        },
      );
    }
    if (_passo == _PassoWeb.vendaForm && _parceria != null) {
      return VendaParceriaFormPage(
        parceriaId: _parceria!.id,
        aoVoltar: () => _setPasso(_voltaVendaForm),
        aoSalvo: (vendaId) {
          setState(() {
            _vendaParceria =
                VendaParceriaFin(id: vendaId, data: '', precoKg: '');
          });
          _setPasso(_PassoWeb.acerto);
        },
      );
    }
    if (_passo == _PassoWeb.acerto &&
        _parceria != null &&
        _vendaParceria != null) {
      final vendaAtual = (_parceria?.vendas ?? const <VendaParceriaFin>[])
          .where((v) => v.id == _vendaParceria!.id)
          .firstOrNull;
      if (vendaAtual?.acertoConfirmado == true ||
          _vendaParceria!.acertoConfirmado) {
        return FinanceiroVendaParceriaPage(
          parceriaId: _parceria!.id,
          vendaId: _vendaParceria!.id,
          aoVoltar: () => _setPasso(_PassoWeb.vendasLista),
          aoBaixa: (titulo) {
            setState(() {
              _tituloParceria = titulo;
              _voltaBaixa = _VoltaBaixaWeb.financeiroVenda;
            });
            _setPasso(_PassoWeb.baixaTitulo);
          },
        );
      }
      return AcertoParceriaPage(
        parceriaId: _parceria!.id,
        vendaId: _vendaParceria!.id,
        aoVoltar: () => _setPasso(_PassoWeb.vendasLista),
        aoConfirmado: () {
          setState(() {
            _vendaParceria =
                (_vendaParceria ?? vendaAtual)?.copiar(acertoConfirmado: true) ??
                VendaParceriaFin(
                  id: _vendaParceria!.id,
                  data: '',
                  precoKg: '',
                  acertoConfirmado: true,
                );
          });
          _setPasso(_PassoWeb.financeiroVenda);
        },
      );
    }
    if (_passo == _PassoWeb.financeiroVenda &&
        _parceria != null &&
        _vendaParceria != null) {
      return FinanceiroVendaParceriaPage(
        parceriaId: _parceria!.id,
        vendaId: _vendaParceria!.id,
        aoVoltar: () => _setPasso(_PassoWeb.vendasLista),
        aoBaixa: (titulo) {
          setState(() {
            _tituloParceria = titulo;
            _voltaBaixa = _VoltaBaixaWeb.financeiroVenda;
          });
          _setPasso(_PassoWeb.baixaTitulo);
        },
      );
    }
    if (_passo == _PassoWeb.baixaTitulo &&
        _parceria != null &&
        _tituloParceria != null) {
      return BaixaTituloParceriaPage(
        parceriaId: _parceria!.id,
        titulo: _tituloParceria!,
        aoVoltar: () => _setPasso(switch (_voltaBaixa) {
          _VoltaBaixaWeb.contrato => _PassoWeb.contratoDetalhe,
          _VoltaBaixaWeb.despesas => _PassoWeb.despesasLista,
          _VoltaBaixaWeb.despesaDetalhe => _PassoWeb.despesaDetalhe,
          _VoltaBaixaWeb.financeiroVenda => _PassoWeb.financeiroVenda,
        }),
        aoSalvo: () => _setPasso(switch (_voltaBaixa) {
          _VoltaBaixaWeb.contrato => _PassoWeb.contratoDetalhe,
          _VoltaBaixaWeb.despesas => _PassoWeb.despesasLista,
          _VoltaBaixaWeb.despesaDetalhe => _PassoWeb.despesasLista,
          _VoltaBaixaWeb.financeiroVenda => _PassoWeb.financeiroVenda,
        }),
      );
    }
    return null;
  }
}
