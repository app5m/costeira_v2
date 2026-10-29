import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/core/input_formatters/brazilian_currency_input_formatter.dart';
import 'package:costeira/features/financeiro/domain/distribuicao_animais.dart';
import 'package:costeira/features/financeiro/domain/financeiro_mock.dart';
import 'package:costeira/features/financeiro/presentation/pages/despesa_parceria_animais_page.dart';
import 'package:costeira/features/financeiro/presentation/widgets/financeiro_ui.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class DespesaParceriaFormPage extends StatefulWidget {
  const DespesaParceriaFormPage({
    super.key,
    required this.parceriaId,
    required this.aoVoltar,
    required this.aoSalvo,
  });

  final int parceriaId;
  final VoidCallback aoVoltar;
  final VoidCallback aoSalvo;

  @override
  State<DespesaParceriaFormPage> createState() => _DespesaParceriaFormPageState();
}

class _DespesaParceriaFormPageState extends State<DespesaParceriaFormPage> {
  int? _classificacaoId;
  int? _rubricaId;
  int? _parteId;
  int? _contaId;
  bool _pago = false;
  bool _salvando = false;
  ModoSelecaoAnimaisDespesa? _modoAnimais;
  final _competencia = TextEditingController();
  final _vencimento = TextEditingController();
  final _descricao = TextEditingController();
  final _documento = TextEditingController();
  final _valor = TextEditingController(text: BrazilianCurrency.format(0));
  late final MaskTextInputFormatter _maskComp = mascaraData();
  late final MaskTextInputFormatter _maskVenc = mascaraData();
  final _animaisEscolhidos = <({AnimalParceriaFin animal, double valor})>[];
  List<AnimalParceriaFin> _disponiveis = const [];

  @override
  void initState() {
    super.initState();
    final agora = DateTime.now();
    _competencia.text =
        '${agora.day.toString().padLeft(2, '0')}/${agora.month.toString().padLeft(2, '0')}/${agora.year}';
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final loja = FinanceiroEscopo.of(context);
      await loja.carregarParceria(widget.parceriaId);
      if (!mounted) return;
      setState(() {
        _disponiveis = [
          for (final a in loja.parceriaDetalhe?.animaisAtivos ?? const <AnimalParceriaFin>[])
            if (a.appAnimaisId != null) a,
        ];
        final pagamentos = loja.classificacoes.where((c) => c.tipo == 'pagamento' && c.manual);
        _classificacaoId ??= pagamentos.isEmpty ? null : pagamentos.first.id;
      });
    });
    _valor.addListener(_aoMudarCampo);
    _descricao.addListener(_aoMudarCampo);
    _competencia.addListener(_aoMudarCampo);
  }

  void _aoMudarCampo() {
    if (_modoAnimais == ModoSelecaoAnimaisDespesa.distribuirTodos && _animaisEscolhidos.isNotEmpty) {
      _redistribuirEscolhidos();
    }
    if (mounted) setState(() {});
  }

  void _redistribuirEscolhidos() {
    if (_animaisEscolhidos.isEmpty) return;
    final atuais = List.of(_animaisEscolhidos);
    final partes = DistribuicaoAnimais.dividirCentavos(_totalCentavos, atuais.length);
    _animaisEscolhidos
      ..clear()
      ..addAll([
        for (var i = 0; i < atuais.length; i++) (animal: atuais[i].animal, valor: partes[i] / 100),
      ]);
  }

  @override
  void dispose() {
    _valor.removeListener(_aoMudarCampo);
    _descricao.removeListener(_aoMudarCampo);
    _competencia.removeListener(_aoMudarCampo);
    _competencia.dispose();
    _vencimento.dispose();
    _descricao.dispose();
    _documento.dispose();
    _valor.dispose();
    super.dispose();
  }

  double get _valorNumero => BrazilianCurrency.parse(_valor.text) ?? 0;

  int get _totalCentavos => (_valorNumero * 100).round();

  bool get _podeSalvar {
    if (_salvando) return false;
    if (_classificacaoId == null || _rubricaId == null) return false;
    if (_descricao.text.trim().isEmpty) return false;
    if (_competencia.text.trim().length < 10) return false;
    if (_valorNumero <= 0) return false;
    if (_animaisEscolhidos.isEmpty) return false;
    if (_pago && _contaId == null) return false;
    return _erroAnimais() == null;
  }

  String? _erroAnimais() {
    if (_animaisEscolhidos.isEmpty) return 'Selecione os animais da despesa.';
    final valores = [
      for (final item in _animaisEscolhidos) (item.valor * 100).round(),
    ];
    return DistribuicaoAnimais.validar(
      totalCentavos: _totalCentavos,
      valores: valores,
      centros: List.filled(_animaisEscolhidos.length, FinanceiroLoja.centroParceria),
      porCentro: false,
      totaisPorCentro: const {},
    );
  }

  Future<void> _abrirSelecaoAnimais() async {
    if (_disponiveis.isEmpty) {
      AppSnackBar.show(context: context, message: 'Nenhum animal ativo neste contrato.');
      return;
    }
    final iniciais = <int, double>{
      for (final item in _animaisEscolhidos)
        if (item.animal.appAnimaisId != null) item.animal.appAnimaisId!: item.valor,
    };
    final resultado = await Navigator.of(context).push<DespesaAnimaisSelecaoResultado>(
      MaterialPageRoute(
        builder: (_) => DespesaParceriaAnimaisPage(
          animais: _disponiveis,
          valorTotal: _valorNumero,
          modoInicial: _modoAnimais,
          selecionadosIniciais: iniciais,
        ),
      ),
    );
    if (resultado == null || !mounted) return;
    setState(() {
      _modoAnimais = resultado.modo;
      _animaisEscolhidos
        ..clear()
        ..addAll(resultado.itens);
    });
  }

  Future<void> _salvar() async {
    if (!_podeSalvar) return;
    final loja = FinanceiroEscopo.of(context);
    ContaMock? conta;
    if (_pago) {
      for (final item in loja.contas) {
        if (item.id == _contaId) conta = item;
      }
      if (conta == null) {
        AppSnackBar.show(context: context, message: 'Selecione a conta do pagamento.');
        return;
      }
      if (conta.saldo + 0.001 < _valorNumero) {
        AppSnackBar.show(context: context, message: 'Saldo da conta insuficiente.');
        return;
      }
    }
    if (_salvando) return;
    setState(() => _salvando = true);
    try {
      await loja.adicionarDespesaParceria(
        parceriaId: widget.parceriaId,
        classificacaoId: _classificacaoId!,
        categoriaId: _rubricaId!,
        parteId: _parteId,
        competencia: _competencia.text.trim(),
        vencimento: _vencimento.text.trim().isEmpty ? null : _vencimento.text.trim(),
        descricao: _descricao.text.trim(),
        documento: _documento.text.trim().isEmpty ? null : _documento.text.trim(),
        valor: _valorNumero.toStringAsFixed(2),
        animais: [
          for (final item in _animaisEscolhidos)
            {
              'app_animais_id': item.animal.appAnimaisId,
              'centro_id': FinanceiroLoja.centroParceria,
              'valor': item.valor.toStringAsFixed(2),
            },
        ],
        pago: _pago,
        contaId: conta?.id,
        dataBaixa: _competencia.text.trim(),
      );
      if (!mounted) return;
      AppSnackBar.show(context: context, message: 'Despesa registrada.', isError: false);
      widget.aoSalvo();
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _salvando = false);
      AppSnackBar.show(context: context, message: error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _salvando = false);
      AppSnackBar.show(context: context, message: 'Não foi possível salvar a despesa.');
    }
  }

  String get _resumoAnimais {
    if (_animaisEscolhidos.isEmpty) return '';
    if (_modoAnimais == ModoSelecaoAnimaisDespesa.distribuirTodos) {
      return 'Distribuído em ${_animaisEscolhidos.length} animais';
    }
    return '${_animaisEscolhidos.length} ${_animaisEscolhidos.length == 1 ? 'selecionado' : 'selecionados'}';
  }

  @override
  Widget build(BuildContext context) {
    final loja = FinanceiroEscopo.of(context);
    final classificacoes = [
      for (final c in loja.classificacoes)
        if (c.tipo == 'pagamento' && c.manual) c,
    ];
    final rubricas = [
      for (final r in loja.rubricas)
        if (r.classificacaoId == _classificacaoId) r,
    ];
    final contas = loja.contas.where((c) => c.ativa).toList();
    final fornecedores = [for (final p in loja.partes) if (p.papel == 'fornecedor') p];

    return Scaffold(
      backgroundColor: fundoFinanceiro,
      appBar: AppBar(
        backgroundColor: MyColors.colorPrimary,
        foregroundColor: Colors.white,
        title: const Text('Adicionar despesa', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: _salvando ? null : widget.aoVoltar),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          CampoFinanceiro(
            rotulo: 'CLASSIFICAÇÃO',
            child: CampoEscolhaFinanceiro(
              valor: classificacoes.where((c) => c.id == _classificacaoId).map((c) => c.nome).firstOrNull ?? '',
              placeholder: classificacoes.isEmpty ? 'Sem classificações' : 'Selecione',
              habilitado: classificacoes.isNotEmpty,
              onTap: () async {
                final escolhido = await abrirOpcoesFinanceiro<int>(
                  context: context,
                  titulo: 'Classificação',
                  atual: _classificacaoId,
                  opcoes: [
                    for (final item in classificacoes) (value: item.id, label: item.nome),
                  ],
                );
                if (escolhido == null || !mounted) return;
                setState(() {
                  _classificacaoId = escolhido;
                  _rubricaId = null;
                });
              },
            ),
          ),
          const SizedBox(height: 12),
          CampoFinanceiro(
            rotulo: 'RUBRICA',
            child: CampoEscolhaFinanceiro(
              valor: rubricas.where((r) => r.id == _rubricaId).map((r) => r.nome).firstOrNull ?? '',
              placeholder: _classificacaoId == null
                  ? 'Selecione a classificação'
                  : (rubricas.isEmpty ? 'Sem rubricas' : 'Selecione'),
              habilitado: rubricas.isNotEmpty,
              onTap: () async {
                final escolhido = await abrirOpcoesFinanceiro<int>(
                  context: context,
                  titulo: 'Rubrica',
                  atual: _rubricaId,
                  opcoes: [
                    for (final item in rubricas) (value: item.id, label: item.nome),
                  ],
                );
                if (escolhido == null || !mounted) return;
                setState(() => _rubricaId = escolhido);
              },
            ),
          ),
          const SizedBox(height: 12),
          CampoFinanceiro(
            rotulo: 'FORNECEDOR (OPCIONAL)',
            child: CampoEscolhaFinanceiro(
              valor: _parteId == null
                  ? 'Sem fornecedor'
                  : (fornecedores.where((p) => p.id == _parteId).map((p) => p.nome).firstOrNull ?? ''),
              placeholder: 'Sem fornecedor',
              onTap: () async {
                const semFornecedor = -1;
                final escolhido = await abrirOpcoesFinanceiro<int>(
                  context: context,
                  titulo: 'Fornecedor',
                  atual: _parteId ?? semFornecedor,
                  opcoes: [
                    (value: semFornecedor, label: 'Sem fornecedor'),
                    for (final item in fornecedores) (value: item.id, label: item.nome),
                  ],
                );
                if (escolhido == null || !mounted) return;
                setState(() => _parteId = escolhido == semFornecedor ? null : escolhido);
              },
            ),
          ),
          const SizedBox(height: 12),
          CampoFinanceiro(
            rotulo: 'COMPETÊNCIA',
            child: TextField(
              controller: _competencia,
              inputFormatters: [_maskComp],
              keyboardType: tecladoData,
              decoration: decoracaoCampo('DD/MM/AAAA'),
            ),
          ),
          const SizedBox(height: 12),
          CampoFinanceiro(
            rotulo: 'VENCIMENTO (OPCIONAL)',
            child: TextField(
              controller: _vencimento,
              inputFormatters: [_maskVenc],
              keyboardType: tecladoData,
              decoration: decoracaoCampo('DD/MM/AAAA'),
            ),
          ),
          const SizedBox(height: 12),
          CampoFinanceiro(
            rotulo: 'DESCRIÇÃO',
            child: TextField(controller: _descricao, decoration: decoracaoCampo('Ex.: Sanitário')),
          ),
          const SizedBox(height: 12),
          CampoFinanceiro(
            rotulo: 'DOCUMENTO (OPCIONAL)',
            child: TextField(controller: _documento, decoration: decoracaoCampo('NF')),
          ),
          const SizedBox(height: 12),
          CampoFinanceiro(
            rotulo: 'VALOR',
            child: TextField(
              controller: _valor,
              keyboardType: tecladoMoeda,
              inputFormatters: [mascaraMoeda],
              decoration: decoracaoCampo('R\$ 0,00'),
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Já pago', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600)),
            value: _pago,
            onChanged: (v) => setState(() => _pago = v),
          ),
          if (_pago) ...[
            CampoFinanceiro(
              rotulo: 'CONTA',
              child: CampoEscolhaFinanceiro(
                valor: contas
                        .where((c) => c.id == _contaId)
                        .map((c) => '${c.nome} · ${reais(c.saldo)}')
                        .firstOrNull ??
                    '',
                placeholder: contas.isEmpty ? 'Sem contas' : 'Selecione a conta',
                habilitado: contas.isNotEmpty,
                onTap: () async {
                  final escolhido = await abrirOpcoesFinanceiro<int>(
                    context: context,
                    titulo: 'Conta',
                    atual: _contaId,
                    opcoes: [
                      for (final conta in contas)
                        (value: conta.id, label: '${conta.nome} · ${reais(conta.saldo)}'),
                    ],
                  );
                  if (escolhido == null || !mounted) return;
                  setState(() => _contaId = escolhido);
                },
              ),
            ),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 8),
          const Text(
            'Animais',
            style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700, fontSize: 15),
          ),
          const SizedBox(height: 8),
          CampoEscolhaFinanceiro(
            valor: _resumoAnimais,
            placeholder: _disponiveis.isEmpty ? 'Sem animais no contrato' : 'Selecionar animais',
            habilitado: _disponiveis.isNotEmpty,
            onTap: _abrirSelecaoAnimais,
          ),
          const SizedBox(height: 16),
          BotaoPrimarioFinanceiro(
            rotulo: 'Salvar despesa',
            carregando: _salvando,
            habilitado: _podeSalvar,
            onPressed: _salvar,
          ),
        ],
      ),
    );
  }
}
