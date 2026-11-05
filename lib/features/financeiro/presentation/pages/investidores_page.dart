import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/features/financeiro/domain/financeiro_mock.dart';
import 'package:costeira/features/financeiro/presentation/widgets/financeiro_ui.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class InvestidoresPage extends StatefulWidget {
  const InvestidoresPage({
    super.key,
    required this.aoVoltar,
    required this.aoAbrir,
    required this.aoAdicionar,
    required this.aoEditar,
  });

  final VoidCallback aoVoltar;
  final ValueChanged<ParteFin> aoAbrir;
  final VoidCallback aoAdicionar;
  final ValueChanged<ParteFin> aoEditar;

  @override
  State<InvestidoresPage> createState() => _InvestidoresPageState();
}

class _InvestidoresPageState extends State<InvestidoresPage> {
  final _busca = TextEditingController();
  int? _excluindoId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final loja = FinanceiroEscopo.of(context);
      // Evita segundo fetch/notify se o shell já preparou a lista.
      if (loja.investidores.isEmpty && !loja.carregandoInvestidores) {
        loja.carregarInvestidores();
      }
    });
    _busca.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _busca.dispose();
    super.dispose();
  }

  Future<void> _excluir(ParteFin investidor) async {
    if (_excluindoId != null) return;
    final motivo = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir investidor?', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${investidor.nome} será removido desta fazenda.',
              style: const TextStyle(fontFamily: 'Montserrat', fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: motivo,
              decoration: const InputDecoration(labelText: 'Motivo da exclusão'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Voltar')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir', style: TextStyle(color: Color(0xFFC62828))),
          ),
        ],
      ),
    );
    final texto = motivo.text;
    motivo.dispose();
    if (ok != true || !mounted) return;
    setState(() => _excluindoId = investidor.id);
    try {
      await FinanceiroEscopo.of(context).excluirInvestidor(
        id: investidor.id,
        motivo: texto.trim().isEmpty ? null : texto.trim(),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      AppSnackBar.show(context: context, message: error.message);
    } finally {
      if (mounted) setState(() => _excluindoId = null);
    }
  }

  Future<void> _menuInvestidor(ParteFin item) async {
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
                  title: const Text('Editar investidor', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600)),
                  onTap: () => Navigator.pop(sheet, 'editar'),
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Color(0xFFC62828)),
                  title: const Text(
                    'Excluir investidor',
                    style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600, color: Color(0xFFC62828)),
                  ),
                  onTap: () => Navigator.pop(sheet, 'excluir'),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (!mounted || escolha == null) return;
    if (escolha == 'editar') {
      widget.aoEditar(item);
      return;
    }
    if (escolha == 'excluir') await _excluir(item);
  }

  Widget _menuDoCard(ParteFin item) {
    final ocupado = _excluindoId == item.id;
    if (kIsWeb) {
      return PopupMenuButton<String>(
        enabled: !ocupado && _excluindoId == null,
        tooltip: 'Mais opções',
        onSelected: (escolha) {
          if (escolha == 'editar') {
            widget.aoEditar(item);
          } else if (escolha == 'excluir') {
            _excluir(item);
          }
        },
        itemBuilder: (_) => const [
          PopupMenuItem(
            value: 'editar',
            child: Text('Editar investidor', style: TextStyle(fontFamily: 'Montserrat')),
          ),
          PopupMenuItem(
            value: 'excluir',
            child: Text(
              'Excluir investidor',
              style: TextStyle(fontFamily: 'Montserrat', color: Color(0xFFC62828)),
            ),
          ),
        ],
        icon: const Icon(Icons.more_vert, color: Color(0xFF8A8A8A)),
      );
    }
    return IconButton(
      onPressed: ocupado || _excluindoId != null ? null : () => _menuInvestidor(item),
      icon: const Icon(Icons.more_vert, color: Color(0xFF8A8A8A)),
      tooltip: 'Mais opções',
    );
  }

  @override
  Widget build(BuildContext context) {
    final loja = FinanceiroEscopo.of(context);
    final termo = _busca.text.trim().toLowerCase();
    final itens = [
      for (final item in loja.investidores)
        if (termo.isEmpty || item.nome.toLowerCase().contains(termo)) item,
    ];
    return Scaffold(
      backgroundColor: fundoFinanceiro,
      appBar: kIsWeb ? null : AppBar(
        backgroundColor: MyColors.colorPrimary,
        foregroundColor: Colors.white,
        title: const Text('Investidores', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.aoVoltar),
      ),
      floatingActionButton: kIsWeb
          ? null
          : FloatingActionButton(
              onPressed: widget.aoAdicionar,
              backgroundColor: MyColors.colorPrimary,
              tooltip: 'Adicionar investidor',
              child: const Icon(Icons.add),
            ),
      body: ListView(
        primary: false,
        padding: EdgeInsets.fromLTRB(16, 12, 16, kIsWeb ? 24 : 96),
        children: [
          TextField(
            controller: _busca,
            decoration: decoracaoCampo('Buscar investidor'),
          ),
          const SizedBox(height: 12),
          if (loja.carregandoInvestidores && loja.investidores.isEmpty)
            const LoadingFinanceiro(altura: 180, rotulo: 'Carregando investidores…')
          else if (itens.isEmpty)
            const EstadoVazioFinanceiro(
              icone: Icons.handshake_outlined,
              mensagem: 'Nenhum investidor cadastrado.',
            )
          else
            for (final item in itens) ...[
              CartaoBranco(
                aoToque: () => widget.aoAbrir(item),
                child: Row(
                  children: [
                    const Icon(Icons.handshake_outlined, color: MyColors.colorPrimary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item.nome,
                        style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700),
                      ),
                    ),
                    _menuDoCard(item),
                    const Icon(Icons.chevron_right, color: Color(0xFF8A8A8A)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
        ],
      ),
    );
  }
}

class InvestidorFormPage extends StatefulWidget {
  const InvestidorFormPage({
    super.key,
    required this.aoVoltar,
    required this.aoSalvo,
    this.investidor,
  });

  final VoidCallback aoVoltar;
  final ValueChanged<ParteFin> aoSalvo;
  final ParteFin? investidor;

  @override
  State<InvestidorFormPage> createState() => _InvestidorFormPageState();
}

class _InvestidorFormPageState extends State<InvestidorFormPage> {
  final _nome = TextEditingController();
  final _codigo = TextEditingController();
  final _inicio = TextEditingController();
  final _fim = TextEditingController();
  final _custo = TextEditingController(text: '40');
  final _ganho = TextEditingController(text: '40');
  final _maskInicio = MaskTextInputFormatter(mask: '##/##/####', filter: {'#': RegExp(r'[0-9]')});
  final _maskFim = MaskTextInputFormatter(mask: '##/##/####', filter: {'#': RegExp(r'[0-9]')});
  bool _salvando = false;

  bool get _editando => widget.investidor != null;

  @override
  void initState() {
    super.initState();
    final atual = widget.investidor;
    if (atual != null) {
      _nome.text = atual.nome;
    } else {
      _inicio.text = _fmtBr(DateTime.now());
    }
    for (final c in [_nome, _codigo, _inicio, _fim, _custo, _ganho]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _nome.dispose();
    _codigo.dispose();
    _inicio.dispose();
    _fim.dispose();
    _custo.dispose();
    _ganho.dispose();
    super.dispose();
  }

  String _fmtBr(DateTime data) {
    final d = data.day.toString().padLeft(2, '0');
    final m = data.month.toString().padLeft(2, '0');
    return '$d/$m/${data.year}';
  }

  DateTime? _parseBr(String texto) {
    final m = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$').firstMatch(texto.trim());
    if (m == null) return null;
    final dia = int.tryParse(m.group(1)!);
    final mes = int.tryParse(m.group(2)!);
    final ano = int.tryParse(m.group(3)!);
    if (dia == null || mes == null || ano == null) return null;
    final data = DateTime(ano, mes, dia);
    if (data.year != ano || data.month != mes || data.day != dia) return null;
    return data;
  }

  double? _parsePct(String texto) {
    final limpo = texto.trim().replaceAll(',', '.');
    if (limpo.isEmpty) return null;
    return double.tryParse(limpo);
  }

  String? _validarContrato() {
    if (_codigo.text.trim().isEmpty) return 'Informe o código do contrato.';
    if (_codigo.text.trim().length > 40) return 'Código com no máximo 40 caracteres.';
    final inicioTxt = _inicio.text.trim();
    if (inicioTxt.isEmpty) return 'Informe a data de início.';
    if (inicioTxt.length < 10) return 'Data de início incompleta. Use dd/mm/aaaa.';
    final inicio = _parseBr(inicioTxt);
    if (inicio == null) return 'Data de início inválida.';
    final fimTxt = _fim.text.trim();
    if (fimTxt.isNotEmpty) {
      if (fimTxt.length < 10) return 'Data fim incompleta. Use dd/mm/aaaa.';
      final fim = _parseBr(fimTxt);
      if (fim == null) return 'Data fim inválida.';
      if (fim.isBefore(inicio)) return 'Fim anterior ao início.';
    }
    final custo = _parsePct(_custo.text);
    final ganho = _parsePct(_ganho.text);
    if (custo == null) return 'Informe o percentual de custo.';
    if (ganho == null) return 'Informe o percentual de ganho.';
    if (custo < 0 || custo > 100) return 'Percentual de custo deve ficar entre 0 e 100.';
    if (ganho < 0 || ganho > 100) return 'Percentual de ganho deve ficar entre 0 e 100.';
    return null;
  }

  bool get _podeSalvar {
    if (_salvando) return false;
    final texto = _nome.text.trim();
    if (texto.isEmpty) return false;
    if (_editando) return texto != widget.investidor!.nome.trim();
    return _validarContrato() == null;
  }

  Future<void> _escolherData({required bool inicio}) async {
    final controller = inicio ? _inicio : _fim;
    final atual = _parseBr(controller.text) ?? DateTime.now();
    final escolhida = await showDatePicker(
      context: context,
      initialDate: atual,
      firstDate: DateTime(atual.year - 10),
      lastDate: DateTime(atual.year + 20),
      helpText: inicio ? 'Data início' : 'Data fim',
    );
    if (escolhida == null || !mounted) return;
    setState(() => controller.text = _fmtBr(escolhida));
  }

  Future<void> _salvar() async {
    if (!_podeSalvar) return;
    setState(() => _salvando = true);
    try {
      final loja = FinanceiroEscopo.of(context);
      final nome = _nome.text.trim();
      if (_editando) {
        final id = widget.investidor!.id;
        await loja.atualizarInvestidor(id: id, nome: nome);
        final atualizado = loja.investidores.where((e) => e.id == id).firstOrNull ??
            ParteFin(id: id, nome: nome, papel: widget.investidor!.papel);
        if (!mounted) return;
        widget.aoSalvo(atualizado);
        return;
      }
      final erroContrato = _validarContrato();
      if (erroContrato != null) {
        AppSnackBar.show(context: context, message: erroContrato);
        return;
      }
      final id = await loja.adicionarInvestidor(nome: nome, motivo: 'Cadastro de investidor');
      final criado = loja.investidores.where((e) => e.id == id).firstOrNull ??
          ParteFin(id: id, nome: nome, papel: 'investidor');
      try {
        await loja.adicionarContrato(
          investidorId: id,
          codigo: _codigo.text,
          dataInicio: _inicio.text,
          dataFim: _fim.text.trim().isEmpty ? null : _fim.text,
          percentualCusto: _custo.text,
          percentualGanho: _ganho.text,
          motivo: 'Cadastro de contrato',
        );
      } on ApiException catch (error) {
        if (!mounted) return;
        AppSnackBar.show(
          context: context,
          message: 'Investidor criado, mas o contrato falhou: ${error.message}',
        );
        widget.aoSalvo(criado);
        return;
      }
      if (!mounted) return;
      widget.aoSalvo(criado);
    } on ApiException catch (error) {
      if (!mounted) return;
      AppSnackBar.show(context: context, message: error.message);
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final horizontal = kIsWeb ? 24.0 : 16.0;
    final campos = <Widget>[
      CampoFinanceiro(
        rotulo: 'NOME',
        child: TextField(
          controller: _nome,
          textCapitalization: TextCapitalization.words,
          decoration: decoracaoCampo('Nome do investidor'),
          inputFormatters: [LengthLimitingTextInputFormatter(100)],
        ),
      ),
      if (!_editando) ...[
        const SizedBox(height: 16),
        const Text(
          'Primeiro contrato',
          style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700, fontSize: 15),
        ),
        const SizedBox(height: 12),
        CampoFinanceiro(
          rotulo: 'CÓDIGO',
          child: TextField(
            controller: _codigo,
            textCapitalization: TextCapitalization.characters,
            decoration: decoracaoCampo('PAR-001'),
          ),
        ),
        const SizedBox(height: 12),
        CampoFinanceiro(
          rotulo: 'DATA INÍCIO',
          child: TextField(
            controller: _inicio,
            keyboardType: TextInputType.number,
            inputFormatters: [_maskInicio],
            decoration: decoracaoCampo('dd/mm/aaaa').copyWith(
              suffixIcon: IconButton(
                onPressed: () => _escolherData(inicio: true),
                icon: const Icon(Icons.calendar_today_outlined, size: 18),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        CampoFinanceiro(
          rotulo: 'DATA FIM (OPCIONAL)',
          child: TextField(
            controller: _fim,
            keyboardType: TextInputType.number,
            inputFormatters: [_maskFim],
            decoration: decoracaoCampo('dd/mm/aaaa').copyWith(
              suffixIcon: IconButton(
                onPressed: () => _escolherData(inicio: false),
                icon: const Icon(Icons.calendar_today_outlined, size: 18),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: CampoFinanceiro(
                rotulo: '% CUSTO',
                child: TextField(
                  controller: _custo,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [mascaraPercentual],
                  decoration: decoracaoCampo('40'),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CampoFinanceiro(
                rotulo: '% GANHO',
                child: TextField(
                  controller: _ganho,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [mascaraPercentual],
                  decoration: decoracaoCampo('40'),
                ),
              ),
            ),
          ],
        ),
      ],
    ];

    return Scaffold(
      backgroundColor: kIsWeb ? Colors.white : fundoFinanceiro,
      appBar: kIsWeb
          ? null
          : AppBar(
              backgroundColor: MyColors.colorPrimary,
              foregroundColor: Colors.white,
              title: Text(
                _editando ? 'Editar investidor' : 'Adicionar investidor',
                style: estiloTituloAppBarPilha(),
              ),
              leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.aoVoltar),
            ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              primary: false,
              padding: EdgeInsets.fromLTRB(horizontal, 16, horizontal, 16),
              children: campos,
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: kIsWeb ? Colors.white : fundoFinanceiro,
              border: const Border(top: BorderSide(color: Color(0xFFE8E8E8))),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(horizontal, 12, horizontal, kIsWeb ? 16 : 12),
                child: BotaoPrimarioFinanceiro(
                  rotulo: _editando ? 'Salvar alterações' : 'Salvar investidor e contrato',
                  carregando: _salvando,
                  habilitado: _podeSalvar,
                  onPressed: _salvar,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ContratosInvestidorPage extends StatefulWidget {
  const ContratosInvestidorPage({
    super.key,
    required this.investidor,
    required this.aoVoltar,
    required this.aoAbrir,
    required this.aoAdicionar,
    required this.aoEditar,
    required this.aoExcluir,
  });

  final ParteFin investidor;
  final VoidCallback aoVoltar;
  final ValueChanged<ParceriaFin> aoAbrir;
  final VoidCallback aoAdicionar;
  final VoidCallback aoEditar;
  final Future<void> Function() aoExcluir;

  @override
  State<ContratosInvestidorPage> createState() => _ContratosInvestidorPageState();
}

class _ContratosInvestidorPageState extends State<ContratosInvestidorPage> {
  bool _excluindo = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FinanceiroEscopo.of(context).carregarParcerias(investidorId: widget.investidor.id);
    });
  }

  String _pct(String raw) {
    final n = double.tryParse(raw.replaceAll(',', '.'));
    if (n == null) return raw;
    return n == n.roundToDouble() ? '${n.toInt()}%' : '${n.toStringAsFixed(2)}%';
  }

  Future<void> _aoEscolherMenu(String? escolha) async {
    if (!mounted || escolha == null) return;
    if (escolha == 'editar') {
      widget.aoEditar();
      return;
    }
    if (escolha == 'excluir') await _excluir();
  }

  Future<void> _menuInvestidor() async {
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
                  title: const Text('Editar investidor', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600)),
                  onTap: () => Navigator.pop(sheet, 'editar'),
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Color(0xFFC62828)),
                  title: const Text(
                    'Excluir investidor',
                    style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600, color: Color(0xFFC62828)),
                  ),
                  onTap: () => Navigator.pop(sheet, 'excluir'),
                ),
              ],
            ),
          ),
        );
      },
    );
    await _aoEscolherMenu(escolha);
  }

  Future<void> _excluir() async {
    if (_excluindo) return;
    final motivo = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir investidor?', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.investidor.nome} será removido desta fazenda.',
              style: const TextStyle(fontFamily: 'Montserrat', fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: motivo,
              decoration: const InputDecoration(labelText: 'Motivo da exclusão'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Voltar')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir', style: TextStyle(color: Color(0xFFC62828))),
          ),
        ],
      ),
    );
    final texto = motivo.text;
    motivo.dispose();
    if (ok != true || !mounted) return;
    setState(() => _excluindo = true);
    try {
      await FinanceiroEscopo.of(context).excluirInvestidor(
        id: widget.investidor.id,
        motivo: texto.trim().isEmpty ? null : texto.trim(),
      );
      if (!mounted) return;
      await widget.aoExcluir();
    } on ApiException catch (error) {
      if (!mounted) return;
      AppSnackBar.show(context: context, message: error.message);
    } finally {
      if (mounted) setState(() => _excluindo = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loja = FinanceiroEscopo.of(context);
    final itens = loja.parcerias;
    final nome = loja.investidores.where((e) => e.id == widget.investidor.id).firstOrNull?.nome ??
        widget.investidor.nome;
    return Scaffold(
      backgroundColor: fundoFinanceiro,
      appBar: kIsWeb ? null : AppBar(
        backgroundColor: MyColors.colorPrimary,
        foregroundColor: Colors.white,
        title: Text(
          nome,
          style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600),
        ),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.aoVoltar),
        actions: [
          IconButton(
            onPressed: _excluindo ? null : _menuInvestidor,
            icon: const Icon(Icons.more_vert),
            tooltip: 'Mais opções',
          ),
        ],
      ),
      floatingActionButton: kIsWeb
          ? null
          : FloatingActionButton(
              onPressed: widget.aoAdicionar,
              backgroundColor: MyColors.colorPrimary,
              tooltip: 'Adicionar contrato',
              child: const Icon(Icons.add),
            ),
      body: ListView(
        primary: false,
        padding: EdgeInsets.fromLTRB(16, 12, 16, kIsWeb ? 24 : 96),
        children: [
          Text(
            kIsWeb ? 'Contratos de $nome' : 'Contratos',
            style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700, fontSize: 15),
          ),
          const SizedBox(height: 12),
          if (loja.carregandoParcerias && itens.isEmpty)
            const LoadingFinanceiro(altura: 180, rotulo: 'Carregando contratos…')
          else if (loja.erroParcerias != null && itens.isEmpty)
            CartaoBranco(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loja.erroParcerias!,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      color: Color(0xFFC62828),
                      fontSize: 13,
                    ),
                  ),
                  TextButton(
                    onPressed: () => loja.carregarParcerias(investidorId: widget.investidor.id),
                    child: const Text('Tentar de novo', style: TextStyle(fontFamily: 'Montserrat')),
                  ),
                ],
              ),
            )
          else if (itens.isEmpty)
            const EstadoVazioFinanceiro(
              icone: Icons.description_outlined,
              mensagem: 'Nenhum contrato neste investidor.',
            )
          else
            for (final item in itens) ...[
              CartaoBranco(
                aoToque: () => widget.aoAbrir(item),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.codigo.isEmpty ? 'Contrato #${item.id}' : item.codigo,
                            style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w800, fontSize: 16),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: item.ativo ? const Color(0x1400823A) : const Color(0x14C62828),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item.ativo ? 'Ativo' : 'Inativo',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: item.ativo ? MyColors.colorPrimary : const Color(0xFFC62828),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Início ${item.dataInicio}${item.dataFim == null || item.dataFim!.isEmpty ? '' : ' · Fim ${item.dataFim}'}',
                      style: const TextStyle(fontFamily: 'Montserrat', fontSize: 12, color: Color(0xFF8A8A8A)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Custo ${_pct(item.percentualCusto)} · Ganho ${_pct(item.percentualGanho)}',
                      style: const TextStyle(fontFamily: 'Montserrat', fontSize: 12, color: Color(0xFF8A8A8A)),
                    ),
                    if (item.periodoVencido) ...[
                      const SizedBox(height: 10),
                      AvisoPeriodoVencido(dataFim: item.dataFim),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
        ],
      ),
    );
  }
}

class ContratoFormPage extends StatefulWidget {
  const ContratoFormPage({
    super.key,
    required this.investidor,
    required this.aoVoltar,
    required this.aoSalvo,
  });

  final ParteFin investidor;
  final VoidCallback aoVoltar;
  final ValueChanged<ParceriaFin> aoSalvo;

  @override
  State<ContratoFormPage> createState() => _ContratoFormPageState();
}

class _ContratoFormPageState extends State<ContratoFormPage> {
  final _codigo = TextEditingController();
  final _inicio = TextEditingController();
  final _fim = TextEditingController();
  final _custo = TextEditingController(text: '40');
  final _ganho = TextEditingController(text: '40');
  final _maskInicio = MaskTextInputFormatter(mask: '##/##/####', filter: {'#': RegExp(r'[0-9]')});
  final _maskFim = MaskTextInputFormatter(mask: '##/##/####', filter: {'#': RegExp(r'[0-9]')});
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _inicio.text = _fmtBr(DateTime.now());
    for (final c in [_codigo, _inicio, _fim, _custo, _ganho]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _codigo.dispose();
    _inicio.dispose();
    _fim.dispose();
    _custo.dispose();
    _ganho.dispose();
    super.dispose();
  }

  bool get _podeSalvar => !_salvando && _validar() == null;

  String _fmtBr(DateTime data) {
    final d = data.day.toString().padLeft(2, '0');
    final m = data.month.toString().padLeft(2, '0');
    return '$d/$m/${data.year}';
  }

  DateTime? _parseBr(String texto) {
    final m = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$').firstMatch(texto.trim());
    if (m == null) return null;
    final dia = int.tryParse(m.group(1)!);
    final mes = int.tryParse(m.group(2)!);
    final ano = int.tryParse(m.group(3)!);
    if (dia == null || mes == null || ano == null) return null;
    if (mes < 1 || mes > 12 || dia < 1 || dia > 31) return null;
    final data = DateTime(ano, mes, dia);
    if (data.year != ano || data.month != mes || data.day != dia) return null;
    return data;
  }

  double? _parsePct(String texto) {
    final limpo = texto.trim().replaceAll(',', '.');
    if (limpo.isEmpty) return null;
    return double.tryParse(limpo);
  }

  String? _validar() {
    if (_codigo.text.trim().isEmpty) return 'Informe o código do contrato.';
    if (_codigo.text.trim().length > 40) return 'Código com no máximo 40 caracteres.';

    final inicioTxt = _inicio.text.trim();
    if (inicioTxt.isEmpty) return 'Informe a data de início.';
    if (inicioTxt.length < 10) return 'Data de início incompleta. Use dd/mm/aaaa.';
    final inicio = _parseBr(inicioTxt);
    if (inicio == null) return 'Data de início inválida.';

    final fimTxt = _fim.text.trim();
    if (fimTxt.isNotEmpty) {
      if (fimTxt.length < 10) return 'Data fim incompleta. Use dd/mm/aaaa.';
      final fim = _parseBr(fimTxt);
      if (fim == null) return 'Data fim inválida.';
      if (fim.isBefore(inicio)) return 'Fim anterior ao início.';
    }

    final custo = _parsePct(_custo.text);
    final ganho = _parsePct(_ganho.text);
    if (custo == null) return 'Informe o percentual de custo.';
    if (ganho == null) return 'Informe o percentual de ganho.';
    if (custo < 0 || custo > 100) return 'Percentual de custo deve ficar entre 0 e 100.';
    if (ganho < 0 || ganho > 100) return 'Percentual de ganho deve ficar entre 0 e 100.';
    return null;
  }

  Future<void> _escolherData({required bool inicio}) async {
    final controller = inicio ? _inicio : _fim;
    final atual = _parseBr(controller.text) ?? DateTime.now();
    final escolhida = await showDatePicker(
      context: context,
      initialDate: atual,
      firstDate: DateTime(atual.year - 10),
      lastDate: DateTime(atual.year + 20),
      helpText: inicio ? 'Data início' : 'Data fim',
    );
    if (escolhida == null || !mounted) return;
    setState(() => controller.text = _fmtBr(escolhida));
  }

  Future<void> _salvar() async {
    if (_salvando) return;
    final erro = _validar();
    if (erro != null) {
      AppSnackBar.show(context: context, message: erro);
      return;
    }
    setState(() => _salvando = true);
    try {
      final loja = FinanceiroEscopo.of(context);
      final id = await loja.adicionarContrato(
        investidorId: widget.investidor.id,
        codigo: _codigo.text,
        dataInicio: _inicio.text,
        dataFim: _fim.text.trim().isEmpty ? null : _fim.text,
        percentualCusto: _custo.text,
        percentualGanho: _ganho.text,
      );
      final criado = loja.parcerias.where((e) => e.id == id).firstOrNull ??
          ParceriaFin(
            id: id,
            codigo: _codigo.text.trim(),
            investidorId: widget.investidor.id,
            investidorNome: widget.investidor.nome,
            dataInicio: _inicio.text.trim(),
            dataFim: _fim.text.trim().isEmpty ? null : _fim.text.trim(),
            percentualCusto: _custo.text,
            percentualGanho: _ganho.text,
            ativo: true,
            entradas: const [],
          );
      if (!mounted) return;
      widget.aoSalvo(criado);
    } on ApiException catch (error) {
      if (!mounted) return;
      AppSnackBar.show(context: context, message: error.message);
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final horizontal = kIsWeb ? 24.0 : 16.0;
    return Scaffold(
      backgroundColor: kIsWeb ? Colors.white : fundoFinanceiro,
      appBar: kIsWeb
          ? null
          : AppBar(
              backgroundColor: MyColors.colorPrimary,
              foregroundColor: Colors.white,
              title: const Text(
                'Adicionar contrato',
                style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600),
              ),
              leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.aoVoltar),
            ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              primary: false,
              padding: EdgeInsets.fromLTRB(horizontal, 16, horizontal, 16),
              children: [
                Text(
                  'Investidor: ${widget.investidor.nome}',
                  style: const TextStyle(fontFamily: 'Montserrat', fontSize: 13, color: Color(0xFF8A8A8A)),
                ),
                const SizedBox(height: 16),
                CampoFinanceiro(
                  rotulo: 'CÓDIGO',
                  child: TextField(
                    controller: _codigo,
                    textCapitalization: TextCapitalization.characters,
                    decoration: decoracaoCampo('PAR-001'),
                  ),
                ),
                const SizedBox(height: 12),
                CampoFinanceiro(
                  rotulo: 'DATA INÍCIO',
                  child: TextField(
                    controller: _inicio,
                    keyboardType: TextInputType.number,
                    inputFormatters: [_maskInicio],
                    decoration: decoracaoCampo('dd/mm/aaaa').copyWith(
                      suffixIcon: IconButton(
                        onPressed: () => _escolherData(inicio: true),
                        icon: const Icon(Icons.calendar_today_outlined, size: 18),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                CampoFinanceiro(
                  rotulo: 'DATA FIM (OPCIONAL)',
                  child: TextField(
                    controller: _fim,
                    keyboardType: TextInputType.number,
                    inputFormatters: [_maskFim],
                    decoration: decoracaoCampo('dd/mm/aaaa').copyWith(
                      suffixIcon: IconButton(
                        onPressed: () => _escolherData(inicio: false),
                        icon: const Icon(Icons.calendar_today_outlined, size: 18),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: CampoFinanceiro(
                        rotulo: '% CUSTO',
                        child: TextField(
                          controller: _custo,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [mascaraPercentual],
                          decoration: decoracaoCampo('40'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CampoFinanceiro(
                        rotulo: '% GANHO',
                        child: TextField(
                          controller: _ganho,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [mascaraPercentual],
                          decoration: decoracaoCampo('40'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: kIsWeb ? Colors.white : fundoFinanceiro,
              border: const Border(top: BorderSide(color: Color(0xFFE8E8E8))),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(horizontal, 12, horizontal, kIsWeb ? 16 : 12),
                child: BotaoPrimarioFinanceiro(
                  habilitado: _podeSalvar,
                  rotulo: 'Salvar contrato',
                  carregando: _salvando,
                  onPressed: _salvar,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
