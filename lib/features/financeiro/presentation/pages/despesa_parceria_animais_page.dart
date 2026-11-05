import 'package:costeira/core/input_formatters/brazilian_currency_input_formatter.dart';
import 'package:costeira/features/financeiro/domain/distribuicao_animais.dart';
import 'package:costeira/features/financeiro/domain/financeiro_mock.dart';
import 'package:costeira/features/financeiro/presentation/widgets/financeiro_ui.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';

enum ModoSelecaoAnimaisDespesa { brincos, distribuirTodos }

class DespesaAnimaisSelecaoResultado {
  const DespesaAnimaisSelecaoResultado({
    required this.modo,
    required this.itens,
  });

  final ModoSelecaoAnimaisDespesa modo;
  final List<({AnimalParceriaFin animal, double valor})> itens;
}

class DespesaParceriaAnimaisPage extends StatefulWidget {
  const DespesaParceriaAnimaisPage({
    super.key,
    required this.animais,
    required this.valorTotal,
    this.modoInicial,
    this.selecionadosIniciais = const {},
    this.embeddedInDialog = false,
  });

  final List<AnimalParceriaFin> animais;
  final double valorTotal;
  final ModoSelecaoAnimaisDespesa? modoInicial;
  final Map<int, double> selecionadosIniciais;
  final bool embeddedInDialog;

  @override
  State<DespesaParceriaAnimaisPage> createState() => _DespesaParceriaAnimaisPageState();
}

class _DespesaParceriaAnimaisPageState extends State<DespesaParceriaAnimaisPage> {
  ModoSelecaoAnimaisDespesa? _modo;
  final _busca = TextEditingController();
  final _marcados = <int>{};
  final _valores = <int, TextEditingController>{};

  @override
  void initState() {
    super.initState();
    _modo = widget.modoInicial;
    for (final animal in _comBrinco) {
      final id = animal.appAnimaisId!;
      final inicial = widget.selecionadosIniciais[id];
      if (inicial != null) {
        _marcados.add(id);
        _valores[id] = TextEditingController(text: BrazilianCurrency.format(inicial));
      } else {
        _valores[id] = TextEditingController(text: BrazilianCurrency.format(0));
      }
    }
    if (_modo == ModoSelecaoAnimaisDespesa.distribuirTodos) {
      _aplicarDistribuicaoTodos();
    } else if (_modo == ModoSelecaoAnimaisDespesa.brincos && _marcados.isNotEmpty) {
      _redistribuirMarcados();
    }
    _busca.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _busca.dispose();
    for (final c in _valores.values) {
      c.dispose();
    }
    super.dispose();
  }

  int get _totalCentavos => (widget.valorTotal * 100).round();

  List<AnimalParceriaFin> get _comBrinco => [
        for (final a in widget.animais)
          if (a.appAnimaisId != null && a.brinco.trim().isNotEmpty) a,
      ];

  List<AnimalParceriaFin> get _filtrados {
    final termo = _busca.text.trim().toLowerCase();
    return [
      for (final a in _comBrinco)
        if (termo.isEmpty || a.brinco.toLowerCase().contains(termo)) a,
    ];
  }

  void _escolherModo(ModoSelecaoAnimaisDespesa modo) {
    setState(() {
      _modo = modo;
      if (modo == ModoSelecaoAnimaisDespesa.distribuirTodos) {
        _marcados.clear();
        _aplicarDistribuicaoTodos();
      }
    });
  }

  void _aplicarDistribuicaoTodos() {
    final ids = [for (final a in _comBrinco) a.appAnimaisId!];
    if (ids.isEmpty) return;
    final partes = DistribuicaoAnimais.dividirCentavos(_totalCentavos, ids.length);
    for (var i = 0; i < ids.length; i++) {
      _valores[ids[i]]?.text = BrazilianCurrency.format(partes[i] / 100);
    }
  }

  void _redistribuirMarcados() {
    final ids = _marcados.toList();
    if (ids.isEmpty) return;
    final partes = DistribuicaoAnimais.dividirCentavos(_totalCentavos, ids.length);
    for (var i = 0; i < ids.length; i++) {
      _valores[ids[i]]?.text = BrazilianCurrency.format(partes[i] / 100);
    }
  }

  bool get _podeConfirmar {
    if (_modo == null || _comBrinco.isEmpty) return false;
    if (_modo == ModoSelecaoAnimaisDespesa.distribuirTodos) return true;
    if (_marcados.isEmpty) return false;
    for (final id in _marcados) {
      final v = BrazilianCurrency.parse(_valores[id]?.text ?? '') ?? 0;
      if (v <= 0) return false;
    }
    return true;
  }

  String get _rotuloConfirmar {
    if (_modo == ModoSelecaoAnimaisDespesa.distribuirTodos) {
      final n = _comBrinco.length;
      return n == 1 ? 'Confirmar 1 animal' : 'Confirmar $n animais';
    }
    if (_modo == ModoSelecaoAnimaisDespesa.brincos) {
      final n = _marcados.length;
      if (n == 0) return 'Confirmar';
      return n == 1 ? 'Confirmar 1 animal' : 'Confirmar $n animais';
    }
    return 'Confirmar';
  }

  void _confirmar() {
    if (!_podeConfirmar) return;
    if (_modo == ModoSelecaoAnimaisDespesa.distribuirTodos) {
      _aplicarDistribuicaoTodos();
      final itens = <({AnimalParceriaFin animal, double valor})>[
        for (final a in _comBrinco)
          (
            animal: a,
            valor: BrazilianCurrency.parse(_valores[a.appAnimaisId!]?.text ?? '') ?? 0,
          ),
      ];
      Navigator.pop(
        context,
        DespesaAnimaisSelecaoResultado(modo: _modo!, itens: itens),
      );
      return;
    }
    final itens = <({AnimalParceriaFin animal, double valor})>[
      for (final a in _comBrinco)
        if (_marcados.contains(a.appAnimaisId))
          (
            animal: a,
            valor: BrazilianCurrency.parse(_valores[a.appAnimaisId!]?.text ?? '') ?? 0,
          ),
    ];
    Navigator.pop(
      context,
      DespesaAnimaisSelecaoResultado(modo: _modo!, itens: itens),
    );
  }

  @override
  Widget build(BuildContext context) {
    final body = _buildBody(context);
    if (widget.embeddedInDialog) return body;

    return Scaffold(
      backgroundColor: fundoFinanceiro,
      appBar: AppBar(
        backgroundColor: MyColors.colorPrimary,
        foregroundColor: Colors.white,
        title: const Text(
          'Selecionar animais',
          style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600),
        ),
      ),
      body: body,
    );
  }

  Widget _buildBody(BuildContext context) {
    final n = _comBrinco.length;
    final unitario = n > 0 ? widget.valorTotal / n : 0.0;
    final embedded = widget.embeddedInDialog;
    final horizontal = embedded ? 24.0 : 16.0;

    final lista = ListView(
      shrinkWrap: embedded,
      physics: embedded ? const AlwaysScrollableScrollPhysics() : null,
      padding: EdgeInsets.fromLTRB(horizontal, embedded ? 8 : 12, horizontal, 16),
      children: [
        CartaoBranco(
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFE7F6EC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.pets_outlined, color: MyColors.colorPrimary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      n == 0
                          ? 'Nenhum animal com brinco'
                          : '$n ${n == 1 ? 'animal' : 'animais'} no contrato',
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Despesa ${reais(widget.valorTotal)}',
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 12,
                        color: Color(0xFF8A8A8A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Como vincular os animais?',
          style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700, fontSize: 15),
        ),
        const SizedBox(height: 4),
        const Text(
          'Escolha uma forma de ratear o valor da despesa.',
          style: TextStyle(fontFamily: 'Montserrat', fontSize: 12, color: Color(0xFF8A8A8A)),
        ),
        const SizedBox(height: 10),
        OpcaoCartaoFinanceiro(
          titulo: 'Selecionar brincos',
          subtitulo: 'Marque os animais e rateie o valor entre eles',
          icone: Icons.tag_outlined,
          selecionado: _modo == ModoSelecaoAnimaisDespesa.brincos,
          travado: n == 0,
          aoToque: () => _escolherModo(ModoSelecaoAnimaisDespesa.brincos),
        ),
        OpcaoCartaoFinanceiro(
          titulo: 'Distribuir entre todos',
          subtitulo: n == 0
              ? 'Sem animais elegíveis neste contrato'
              : 'Divide ${reais(widget.valorTotal)} igualmente ($n ${n == 1 ? 'animal' : 'animais'})',
          icone: Icons.grid_view_rounded,
          selecionado: _modo == ModoSelecaoAnimaisDespesa.distribuirTodos,
          travado: n == 0,
          aoToque: () => _escolherModo(ModoSelecaoAnimaisDespesa.distribuirTodos),
        ),
        const SizedBox(height: 8),
        if (n == 0)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text(
              'Cadastre entrada com brinco neste contrato para vincular a despesa.',
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Montserrat', color: Color(0xFF8A8A8A), fontSize: 13),
            ),
          )
        else if (_modo == null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: CartaoBranco(
              child: Column(
                children: [
                  Icon(Icons.touch_app_outlined, size: 28, color: MyColors.colorPrimary.withValues(alpha: 0.7)),
                  const SizedBox(height: 8),
                  const Text(
                    'Toque em uma opção acima para continuar',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 13,
                      color: Color(0xFF6B6B6B),
                    ),
                  ),
                ],
              ),
            ),
          )
        else if (_modo == ModoSelecaoAnimaisDespesa.distribuirTodos) ...[
          IndicadorFaixaFinanceiro(
            rotulo: 'Valor por animal',
            valor: reais(unitario),
            fundo: const Color(0xFFE7F6EC),
            letra: const Color(0xFF2E7D32),
          ),
          const SizedBox(height: 10),
          CartaoBranco(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rateio automático',
                  style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  '${reais(widget.valorTotal)} ÷ $n ${n == 1 ? 'animal' : 'animais'} = ${reais(unitario)} cada',
                  style: const TextStyle(fontFamily: 'Montserrat', fontSize: 13, color: Color(0xFF8A8A8A)),
                ),
                const SizedBox(height: 10),
                for (final animal in _comBrinco.take(6)) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            animal.brinco,
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          reais(unitario),
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF313131),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (_comBrinco.length > 6)
                  Text(
                    '+${_comBrinco.length - 6} ${_comBrinco.length - 6 == 1 ? 'animal' : 'animais'}…',
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 12,
                      color: Color(0xFF8A8A8A),
                    ),
                  ),
              ],
            ),
          ),
        ] else if (_modo == ModoSelecaoAnimaisDespesa.brincos) ...[
          TextField(
            controller: _busca,
            decoration: decoracaoCampo('Filtrar por brinco'),
          ),
          const SizedBox(height: 8),
          Text(
            _marcados.isEmpty
                ? 'Nenhum selecionado'
                : (_marcados.length == 1
                    ? '1 selecionado'
                    : '${_marcados.length} selecionados'),
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w700,
              color: MyColors.colorPrimary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          if (_filtrados.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'Nenhum animal encontrado.',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Montserrat', color: Color(0xFF8A8A8A)),
              ),
            )
          else
            for (final animal in _filtrados) ...[
              _LinhaBrinco(
                animal: animal,
                marcado: _marcados.contains(animal.appAnimaisId),
                controller: _valores[animal.appAnimaisId!]!,
                onToggle: (v) => setState(() {
                  final id = animal.appAnimaisId!;
                  if (v) {
                    _marcados.add(id);
                    _redistribuirMarcados();
                  } else {
                    _marcados.remove(id);
                    _valores[id]?.text = BrazilianCurrency.format(0);
                    _redistribuirMarcados();
                  }
                }),
                onValor: (_) => setState(() {}),
              ),
              const SizedBox(height: 6),
            ],
        ],
      ],
    );

    return Column(
      mainAxisSize: embedded ? MainAxisSize.min : MainAxisSize.max,
      children: [
        if (embedded)
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 480),
            child: SizedBox(width: double.infinity, child: lista),
          )
        else
          Expanded(child: lista),
        SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(horizontal, 8, horizontal, embedded ? 20 : 12),
            child: BotaoPrimarioFinanceiro(
              rotulo: _rotuloConfirmar,
              habilitado: _podeConfirmar,
              onPressed: _confirmar,
            ),
          ),
        ),
      ],
    );
  }
}

class _LinhaBrinco extends StatelessWidget {
  const _LinhaBrinco({
    required this.animal,
    required this.marcado,
    required this.controller,
    required this.onToggle,
    required this.onValor,
  });

  final AnimalParceriaFin animal;
  final bool marcado;
  final TextEditingController controller;
  final ValueChanged<bool> onToggle;
  final ValueChanged<String> onValor;

  @override
  Widget build(BuildContext context) {
    final brinco = animal.brinco.isEmpty ? '#${animal.appAnimaisId}' : animal.brinco;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: marcado ? MyColors.colorPrimary.withValues(alpha: 0.35) : const Color(0xFFE6E6E6),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 36,
              height: 36,
              child: Checkbox(
                value: marcado,
                onChanged: (v) => onToggle(v ?? false),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                brinco,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: SizedBox(
                height: 36,
                child: TextField(
                  controller: controller,
                  enabled: marcado,
                  keyboardType: tecladoMoeda,
                  inputFormatters: [mascaraMoeda],
                  style: const TextStyle(fontFamily: 'Montserrat', fontSize: 13),
                  decoration: decoracaoCampo('R\$ 0,00').copyWith(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    isDense: true,
                  ),
                  onChanged: onValor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
