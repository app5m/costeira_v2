import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/core/input_formatters/brazilian_currency_input_formatter.dart';
import 'package:costeira/features/financeiro/domain/financeiro_mock.dart';
import 'package:costeira/features/financeiro/presentation/widgets/financeiro_ui.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

/// Ajuste de saldo via `/financeiro/registrarSaldoInicial`.
enum ModoAjusteSaldo { abertura, entrada, saida }

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
    if (loja.carregando && loja.contas.isEmpty) {
      return const LoadingFinanceiro(altura: 320, rotulo: 'Carregando contas…');
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
      children: [
        const ContextoFinanceiroFiltros(mostrarAno: false),
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
              Text(
                'Fazenda: ${loja.fazendaNome}',
                style: const TextStyle(fontFamily: 'Montserrat', fontSize: 12, color: Color(0xFF8A8A8A)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (loja.carregando)
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: LoadingFinanceiro(altura: 48, rotulo: 'Atualizando…'),
          ),
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

class ContaDetalhePage extends StatefulWidget {
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
  final Future<void> Function() aoInativar;
  final ValueChanged<ModoAjusteSaldo> aoSaldo;

  @override
  State<ContaDetalhePage> createState() => _ContaDetalhePageState();
}

class _ContaDetalhePageState extends State<ContaDetalhePage> {
  bool _inativando = false;

  Future<void> _inativar() async {
    if (_inativando) return;
    setState(() => _inativando = true);
    try {
      await widget.aoInativar();
    } finally {
      if (mounted) setState(() => _inativando = false);
    }
  }

  Future<void> _menuConta() async {
    final atual = FinanceiroEscopo.of(context).contas.firstWhere((c) => c.id == widget.conta.id);
    final escolha = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheet) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9D9D9),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                ListTile(
                  leading: const Icon(Icons.edit_outlined, color: MyColors.colorPrimary),
                  title: const Text('Editar conta', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600)),
                  onTap: () => Navigator.pop(sheet, 'editar'),
                ),
                if (atual.ativa)
                  ListTile(
                    leading: const Icon(Icons.block, color: Color(0xFFC62828)),
                    title: const Text('Inativar conta', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600, color: Color(0xFFC62828))),
                    onTap: () => Navigator.pop(sheet, 'inativar'),
                  ),
              ],
            ),
          ),
        );
      },
    );
    if (!mounted || escolha == null) return;
    if (escolha == 'editar') {
      widget.aoEditar();
      return;
    }
    if (escolha == 'inativar') await _inativar();
  }

  @override
  Widget build(BuildContext context) {
    final atual = FinanceiroEscopo.of(context).contas.firstWhere((c) => c.id == widget.conta.id);
    return Scaffold(
      backgroundColor: fundoFinanceiro,
      appBar: AppBar(
        backgroundColor: MyColors.colorPrimary,
        foregroundColor: Colors.white,
        title: Text(atual.nome, style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.aoVoltar),
        actions: [
          IconButton(
            onPressed: _inativando ? null : _menuConta,
            icon: const Icon(Icons.more_vert),
            tooltip: 'Mais opções',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Text('${atual.tipo} · ${atual.ativa ? 'Ativa' : 'Inativa'}', style: const TextStyle(fontFamily: 'Montserrat', color: Color(0xFF8A8A8A))),
          const SizedBox(height: 4),
          Text(reais(atual.saldo), style: const TextStyle(fontFamily: 'Montserrat', fontSize: 28, fontWeight: FontWeight.w800)),
          const Text('Saldo disponível', style: TextStyle(fontFamily: 'Montserrat', color: Color(0xFF8A8A8A))),
          if (!atual.saldoInicialRegistrado && atual.ativa) ...[
            const SizedBox(height: 12),
            Material(
              color: const Color(0xFFFFF4E5),
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: _inativando ? null : () => widget.aoSaldo(ModoAjusteSaldo.abertura),
                borderRadius: BorderRadius.circular(12),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Color(0xFFB86E00), size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Informar saldo inicial',
                          style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600, color: Color(0xFFB86E00)),
                        ),
                      ),
                      Icon(Icons.chevron_right, color: Color(0xFFB86E00)),
                    ],
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
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
        ],
      ),
      bottomNavigationBar: !atual.ativa
          ? null
          : RodapeAcoesFinanceiro(
              filhos: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _inativando ? null : () => widget.aoSaldo(ModoAjusteSaldo.saida),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          foregroundColor: const Color(0xFFC62828),
                          side: const BorderSide(color: Color(0xFFE0B4B4)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.remove_circle_outline, size: 18),
                        label: const Text('Remover', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _inativando ? null : () => widget.aoSaldo(ModoAjusteSaldo.entrada),
                        style: FilledButton.styleFrom(
                          backgroundColor: MyColors.colorPrimary,
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.add_circle_outline, size: 18),
                        label: const Text('Adicionar', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}

class ContaPosCriacao extends StatelessWidget {
  const ContaPosCriacao({
    super.key,
    required this.nome,
    required this.aoInformarSaldo,
    required this.aoSaldoZero,
  });

  final String nome;
  final VoidCallback aoInformarSaldo;
  final VoidCallback aoSaldoZero;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFE7F6EC),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: MyColors.colorPrimary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Conta criada · $nome',
                  style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700, color: MyColors.colorPrimary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Já havia saldo no início do controle?',
          style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700, fontSize: 16),
        ),
        const SizedBox(height: 12),
        CartaoBranco(
          aoToque: aoInformarSaldo,
          child: const Row(
            children: [
              Icon(Icons.description_outlined, color: MyColors.colorPrimary),
              SizedBox(width: 10),
              Expanded(
                child: Text('Informar saldo inicial', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600)),
              ),
              Icon(Icons.chevron_right, color: Color(0xFF8A8A8A)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        CartaoBranco(
          aoToque: aoSaldoZero,
          child: const Row(
            children: [
              Icon(Icons.radio_button_unchecked, color: MyColors.colorPrimary),
              SizedBox(width: 10),
              Expanded(
                child: Text('Começar com saldo zero', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600)),
              ),
              Icon(Icons.chevron_right, color: Color(0xFF8A8A8A)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Saldo zero não gera movimentação.',
          style: TextStyle(fontFamily: 'Montserrat', fontSize: 12, color: Color(0xFF8A8A8A)),
        ),
      ],
    );
  }
}

class ContaFormPage extends StatefulWidget {
  const ContaFormPage({
    super.key,
    required this.aoVoltar,
    this.aoSaldoInicial,
    this.conta,
  });

  final VoidCallback aoVoltar;
  final ValueChanged<ContaMock>? aoSaldoInicial;
  final ContaMock? conta;

  @override
  State<ContaFormPage> createState() => _ContaFormPageState();
}

class _ContaFormPageState extends State<ContaFormPage> {
  late final TextEditingController _nome;
  late final TextEditingController _motivo;
  late String _tipo;
  ContaMock? _criada;
  bool _salvando = false;

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

  Future<void> _salvar() async {
    if (_salvando || _nome.text.trim().isEmpty) {
      if (_nome.text.trim().isEmpty) {
        AppSnackBar.show(context: context, message: 'Informe o nome da conta.');
      }
      return;
    }
    setState(() => _salvando = true);
    final loja = FinanceiroEscopo.of(context);
    try {
      final id = await loja.salvarConta(
        id: widget.conta?.id,
        nome: _nome.text.trim(),
        tipo: _tipo,
        motivo: _motivo.text.trim().isEmpty ? 'Cadastro da conta' : _motivo.text.trim(),
      );
      if (!mounted) return;
      if (widget.conta != null) {
        widget.aoVoltar();
        return;
      }
      final conta = loja.contas.where((c) => c.id == id).firstOrNull ??
          loja.contas.where((c) => c.nome == _nome.text.trim()).firstOrNull;
      if (conta == null) {
        widget.aoVoltar();
        return;
      }
      setState(() {
        _criada = conta;
        _salvando = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _salvando = false);
      AppSnackBar.show(context: context, message: error.message);
    } catch (error) {
      if (!mounted) return;
      setState(() => _salvando = false);
      AppSnackBar.show(context: context, message: error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final criada = _criada;
    return Scaffold(
      backgroundColor: fundoFinanceiro,
      appBar: AppBar(
        backgroundColor: MyColors.colorPrimary,
        foregroundColor: Colors.white,
        title: Text(
          criada != null ? 'Conta criada' : (widget.conta == null ? 'Adicionar conta' : 'Editar conta'),
          style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _salvando ? null : widget.aoVoltar,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          if (criada != null)
            ContaPosCriacao(
              nome: criada.nome,
              aoInformarSaldo: () {
                final destino = widget.aoSaldoInicial;
                if (destino != null) {
                  destino(criada);
                } else {
                  widget.aoVoltar();
                }
              },
              aoSaldoZero: widget.aoVoltar,
            )
          else ...[
            CampoFinanceiro(
              rotulo: 'NOME DA CONTA',
              child: TextField(controller: _nome, enabled: !_salvando, decoration: decoracaoCampo('Banco principal')),
            ),
            const SizedBox(height: 12),
            const SecaoRotulo('TIPO'),
            const SizedBox(height: 8),
            GrupoChips(
              opcoes: const ['Caixa', 'Banco'],
              selecionado: _tipo,
              aoEscolher: _salvando ? (_) {} : (v) => setState(() => _tipo = v),
            ),
            const SizedBox(height: 8),
            const Text(
              'Escolha um nome para identificar onde o dinheiro entra e sai.',
              style: TextStyle(fontFamily: 'Montserrat', fontSize: 12, color: Color(0xFF8A8A8A)),
            ),
            const SizedBox(height: 12),
            CampoFinanceiro(
              rotulo: 'MOTIVO',
              child: TextField(controller: _motivo, enabled: !_salvando, decoration: decoracaoCampo('')),
            ),
          ],
        ],
      ),
      bottomNavigationBar: criada != null
          ? null
          : RodapeAcoesFinanceiro(
              filhos: [
                BotaoPrimarioFinanceiro(
                  rotulo: widget.conta == null ? 'Salvar conta' : 'Salvar alterações',
                  carregando: _salvando,
                  onPressed: _salvar,
                ),
                TextButton(
                  onPressed: _salvando ? null : widget.aoVoltar,
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
  const SaldoInicialPage({
    super.key,
    required this.conta,
    required this.aoVoltar,
    this.modo = ModoAjusteSaldo.abertura,
  });

  final ContaMock conta;
  final VoidCallback aoVoltar;
  final ModoAjusteSaldo modo;

  @override
  State<SaldoInicialPage> createState() => _SaldoInicialPageState();
}

class _SaldoInicialPageState extends State<SaldoInicialPage> {
  late final TextEditingController _data;
  final _valor = TextEditingController(text: BrazilianCurrency.format(0));
  late final TextEditingController _doc;
  late final TextEditingController _motivo;
  late bool _positivo;
  bool _salvando = false;
  late final MaskTextInputFormatter _mascaraData = mascaraData();

  bool get _abertura => widget.modo == ModoAjusteSaldo.abertura;
  bool get _bloqueadoAbertura => _abertura && widget.conta.saldoInicialRegistrado;

  String get _titulo => switch (widget.modo) {
        ModoAjusteSaldo.abertura => 'Saldo inicial',
        ModoAjusteSaldo.entrada => 'Adicionar dinheiro',
        ModoAjusteSaldo.saida => 'Remover dinheiro',
      };

  String get _rotuloBotao => switch (widget.modo) {
        ModoAjusteSaldo.abertura => 'Registrar saldo inicial',
        ModoAjusteSaldo.entrada => 'Confirmar entrada',
        ModoAjusteSaldo.saida => 'Confirmar saída',
      };

  String get _ajuda => switch (widget.modo) {
        ModoAjusteSaldo.abertura =>
          'Informe o saldo existente na data de início do controle. Não é uma receita.',
        ModoAjusteSaldo.entrada =>
          'Registra entrada na conta (direção entrada). Documento padrão: AJUSTE-ENTRADA.',
        ModoAjusteSaldo.saida =>
          'Registra saída na conta (direção saída). Documento padrão: AJUSTE-SAIDA.',
      };

  @override
  void initState() {
    super.initState();
    final agora = DateTime.now();
    final d = agora.day.toString().padLeft(2, '0');
    final m = agora.month.toString().padLeft(2, '0');
    _data = TextEditingController(text: '$d/$m/${agora.year}');
    _positivo = widget.modo != ModoAjusteSaldo.saida;
    _doc = TextEditingController(
      text: switch (widget.modo) {
        ModoAjusteSaldo.abertura => 'ABERTURA',
        ModoAjusteSaldo.entrada => 'AJUSTE-ENTRADA',
        ModoAjusteSaldo.saida => 'AJUSTE-SAIDA',
      },
    );
    _motivo = TextEditingController(
      text: switch (widget.modo) {
        ModoAjusteSaldo.abertura => 'Saldo inicial conciliado',
        ModoAjusteSaldo.entrada => 'Adicionar saldo na conta',
        ModoAjusteSaldo.saida => 'Remover saldo da conta',
      },
    );
  }

  @override
  void dispose() {
    _data.dispose();
    _valor.dispose();
    _doc.dispose();
    _motivo.dispose();
    super.dispose();
  }

  Future<void> _registrar() async {
    if (_salvando || _bloqueadoAbertura) return;
    if (_data.text.trim().isEmpty) {
      AppSnackBar.show(context: context, message: 'Informe a data.');
      return;
    }
    final valor = BrazilianCurrency.parse(_valor.text) ?? 0;
    if (valor <= 0) {
      AppSnackBar.show(context: context, message: 'Informe um valor maior que zero.');
      return;
    }
    setState(() => _salvando = true);
    final loja = FinanceiroEscopo.of(context);
    final positivo = switch (widget.modo) {
      ModoAjusteSaldo.abertura => _positivo,
      ModoAjusteSaldo.entrada => true,
      ModoAjusteSaldo.saida => false,
    };
    try {
      await loja.registrarSaldoInicial(
        contaId: widget.conta.id,
        data: _data.text.trim(),
        positivo: positivo,
        valor: valor.toStringAsFixed(2),
        documento: _doc.text.trim().isEmpty ? null : _doc.text.trim(),
        motivo: _motivo.text.trim().isEmpty ? _titulo : _motivo.text.trim(),
      );
      if (!mounted) return;
      AppSnackBar.show(context: context, message: 'Saldo registrado com sucesso.', isError: false);
      widget.aoVoltar();
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _salvando = false);
      AppSnackBar.show(context: context, message: error.message);
    } catch (error) {
      if (!mounted) return;
      setState(() => _salvando = false);
      AppSnackBar.show(context: context, message: error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final atual = FinanceiroEscopo.of(context).contas.where((c) => c.id == widget.conta.id).firstOrNull ?? widget.conta;
    return Scaffold(
      backgroundColor: fundoFinanceiro,
      appBar: AppBar(
        backgroundColor: MyColors.colorPrimary,
        foregroundColor: Colors.white,
        title: Text(_titulo, style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: _salvando ? null : widget.aoVoltar),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Text(atual.nome, style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700, fontSize: 16)),
          Text(
            '${atual.tipo} · Saldo ${reais(atual.saldo)}',
            style: const TextStyle(fontFamily: 'Montserrat', color: Color(0xFF8A8A8A)),
          ),
          const SizedBox(height: 12),
          CampoFinanceiro(
            rotulo: _abertura ? 'DATA DE ABERTURA' : 'DATA',
            child: TextField(
              controller: _data,
              enabled: !_salvando && !_bloqueadoAbertura,
              keyboardType: tecladoData,
              inputFormatters: [_mascaraData],
              decoration: decoracaoCampo('dd/MM/aaaa'),
            ),
          ),
          if (_abertura) ...[
            const SizedBox(height: 12),
            const SecaoRotulo('SITUAÇÃO DO SALDO'),
            const SizedBox(height: 8),
            GrupoChips(
              opcoes: const ['Positivo', 'Negativo'],
              selecionado: _positivo ? 'Positivo' : 'Negativo',
              aoEscolher: (_salvando || _bloqueadoAbertura) ? (_) {} : (v) => setState(() => _positivo = v == 'Positivo'),
            ),
          ],
          const SizedBox(height: 12),
          CampoFinanceiro(
            rotulo: 'VALOR',
            child: TextField(
              controller: _valor,
              enabled: !_salvando && !_bloqueadoAbertura,
              keyboardType: tecladoMoeda,
              inputFormatters: const [mascaraMoeda],
              decoration: decoracaoCampo(r'R$ 0,00'),
            ),
          ),
          const SizedBox(height: 12),
          CampoFinanceiro(
            rotulo: 'DOCUMENTO',
            child: TextField(
              controller: _doc,
              enabled: !_salvando && !_bloqueadoAbertura,
              decoration: decoracaoCampo(_doc.text),
            ),
          ),
          const SizedBox(height: 12),
          CampoFinanceiro(
            rotulo: 'MOTIVO',
            child: TextField(
              controller: _motivo,
              enabled: !_salvando && !_bloqueadoAbertura,
              decoration: decoracaoCampo(''),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _ajuda,
            style: const TextStyle(fontFamily: 'Montserrat', fontSize: 12, color: Color(0xFF8A8A8A)),
          ),
        ],
      ),
      bottomNavigationBar: RodapeAcoesFinanceiro(
        filhos: [
          BotaoPrimarioFinanceiro(
            rotulo: _bloqueadoAbertura ? 'Saldo inicial já registrado' : _rotuloBotao,
            carregando: _salvando,
            habilitado: !_bloqueadoAbertura,
            onPressed: _registrar,
          ),
        ],
      ),
    );
  }
}
