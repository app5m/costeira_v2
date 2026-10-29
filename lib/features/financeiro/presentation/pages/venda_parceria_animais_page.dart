import 'package:costeira/features/financeiro/domain/financeiro_mock.dart';
import 'package:costeira/features/financeiro/presentation/widgets/financeiro_ui.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum ModoSelecaoAnimaisVenda { brincos, todos }

class VendaAnimaisSelecaoResultado {
  const VendaAnimaisSelecaoResultado({
    required this.modo,
    required this.itens,
  });

  final ModoSelecaoAnimaisVenda modo;
  final List<({AnimalParceriaFin animal, double peso})> itens;
}

class VendaParceriaAnimaisPage extends StatefulWidget {
  const VendaParceriaAnimaisPage({
    super.key,
    required this.animais,
    this.precoKg,
    this.modoInicial,
    this.selecionadosIniciais = const {},
  });

  final List<AnimalParceriaFin> animais;
  final double? precoKg;
  final ModoSelecaoAnimaisVenda? modoInicial;
  final Map<int, double> selecionadosIniciais;

  @override
  State<VendaParceriaAnimaisPage> createState() => _VendaParceriaAnimaisPageState();
}

class _VendaParceriaAnimaisPageState extends State<VendaParceriaAnimaisPage> {
  ModoSelecaoAnimaisVenda? _modo;
  final _busca = TextEditingController();
  final _marcados = <int>{};
  final _pesos = <int, TextEditingController>{};

  @override
  void initState() {
    super.initState();
    _modo = widget.modoInicial;
    for (final animal in _comBrinco) {
      final id = animal.appAnimaisId!;
      final inicial = widget.selecionadosIniciais[id];
      if (inicial != null && inicial > 0) {
        _marcados.add(id);
        _pesos[id] = TextEditingController(text: _fmtPeso(inicial));
      } else {
        _pesos[id] = TextEditingController(text: _pesoEntrada(animal));
      }
    }
    if (_modo == ModoSelecaoAnimaisVenda.todos) {
      _marcarTodos();
    }
    _busca.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _busca.dispose();
    for (final c in _pesos.values) {
      c.dispose();
    }
    super.dispose();
  }

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

  String _pesoEntrada(AnimalParceriaFin animal) {
    final n = double.tryParse(animal.pesoEntradaKg.replaceAll(',', '.'));
    if (n == null || n <= 0) return '';
    return _fmtPeso(n);
  }

  String _fmtPeso(double n) {
    return n == n.roundToDouble() ? n.toInt().toString() : n.toStringAsFixed(2);
  }

  double _lerPeso(int id) {
    return double.tryParse((_pesos[id]?.text ?? '').trim().replaceAll(',', '.')) ?? 0;
  }

  void _escolherModo(ModoSelecaoAnimaisVenda modo) {
    setState(() {
      _modo = modo;
      if (modo == ModoSelecaoAnimaisVenda.todos) {
        _marcarTodos();
      }
    });
  }

  void _marcarTodos() {
    _marcados
      ..clear()
      ..addAll([for (final a in _comBrinco) a.appAnimaisId!]);
  }

  bool get _podeConfirmar {
    if (_modo == null || _comBrinco.isEmpty) return false;
    final ids = _modo == ModoSelecaoAnimaisVenda.todos
        ? [for (final a in _comBrinco) a.appAnimaisId!]
        : _marcados.toList();
    if (ids.isEmpty) return false;
    for (final id in ids) {
      if (_lerPeso(id) <= 0) return false;
    }
    return true;
  }

  String get _rotuloConfirmar {
    final n = _modo == ModoSelecaoAnimaisVenda.todos ? _comBrinco.length : _marcados.length;
    if (n == 0) return 'Confirmar';
    return n == 1 ? 'Confirmar 1 animal' : 'Confirmar $n animais';
  }

  void _confirmar() {
    if (!_podeConfirmar) return;
    final ids = _modo == ModoSelecaoAnimaisVenda.todos
        ? {for (final a in _comBrinco) a.appAnimaisId!}
        : _marcados;
    final itens = <({AnimalParceriaFin animal, double peso})>[
      for (final a in _comBrinco)
        if (ids.contains(a.appAnimaisId)) (animal: a, peso: _lerPeso(a.appAnimaisId!)),
    ];
    Navigator.pop(
      context,
      VendaAnimaisSelecaoResultado(modo: _modo!, itens: itens),
    );
  }

  @override
  Widget build(BuildContext context) {
    final n = _comBrinco.length;
    final preco = widget.precoKg;

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
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
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
                              preco != null && preco > 0
                                  ? 'Preço ${reais(preco)}/kg'
                                  : 'Informe o peso de saída de cada animal',
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
                  'Como escolher os animais?',
                  style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700, fontSize: 15),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Selecione brincos específicos ou inclua todos do contrato.',
                  style: TextStyle(fontFamily: 'Montserrat', fontSize: 12, color: Color(0xFF8A8A8A)),
                ),
                const SizedBox(height: 10),
                OpcaoCartaoFinanceiro(
                  titulo: 'Selecionar brincos',
                  subtitulo: 'Marque os animais e informe o peso de saída',
                  icone: Icons.tag_outlined,
                  selecionado: _modo == ModoSelecaoAnimaisVenda.brincos,
                  travado: n == 0,
                  aoToque: () => _escolherModo(ModoSelecaoAnimaisVenda.brincos),
                ),
                OpcaoCartaoFinanceiro(
                  titulo: 'Incluir todos',
                  subtitulo: n == 0
                      ? 'Sem animais elegíveis neste contrato'
                      : 'Inclui $n ${n == 1 ? 'animal' : 'animais'} do contrato',
                  icone: Icons.grid_view_rounded,
                  selecionado: _modo == ModoSelecaoAnimaisVenda.todos,
                  travado: n == 0,
                  aoToque: () => _escolherModo(ModoSelecaoAnimaisVenda.todos),
                ),
                const SizedBox(height: 8),
                if (n == 0)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      'Cadastre entrada com brinco neste contrato para vender.',
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
                else if (_modo == ModoSelecaoAnimaisVenda.todos) ...[
                  IndicadorFaixaFinanceiro(
                    rotulo: 'Animais na venda',
                    valor: '$n',
                    fundo: const Color(0xFFE7F6EC),
                    letra: const Color(0xFF2E7D32),
                  ),
                  const SizedBox(height: 10),
                  for (final animal in _comBrinco) ...[
                    _LinhaPesoVenda(
                      animal: animal,
                      marcado: true,
                      controller: _pesos[animal.appAnimaisId!]!,
                      mostrarCheckbox: false,
                      onToggle: (_) {},
                      onPeso: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 6),
                  ],
                ] else if (_modo == ModoSelecaoAnimaisVenda.brincos) ...[
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
                      _LinhaPesoVenda(
                        animal: animal,
                        marcado: _marcados.contains(animal.appAnimaisId),
                        controller: _pesos[animal.appAnimaisId!]!,
                        mostrarCheckbox: true,
                        onToggle: (v) => setState(() {
                          final id = animal.appAnimaisId!;
                          if (v) {
                            _marcados.add(id);
                          } else {
                            _marcados.remove(id);
                          }
                        }),
                        onPeso: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 6),
                    ],
                ],
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: BotaoPrimarioFinanceiro(
                rotulo: _rotuloConfirmar,
                habilitado: _podeConfirmar,
                onPressed: _confirmar,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LinhaPesoVenda extends StatelessWidget {
  const _LinhaPesoVenda({
    required this.animal,
    required this.marcado,
    required this.controller,
    required this.mostrarCheckbox,
    required this.onToggle,
    required this.onPeso,
  });

  final AnimalParceriaFin animal;
  final bool marcado;
  final TextEditingController controller;
  final bool mostrarCheckbox;
  final ValueChanged<bool> onToggle;
  final ValueChanged<String> onPeso;

  @override
  Widget build(BuildContext context) {
    final brinco = animal.brinco.isEmpty ? '#${animal.appAnimaisId}' : animal.brinco;
    final entrada = animal.pesoEntradaKg.trim();
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: marcado ? MyColors.colorPrimary.withValues(alpha: 0.35) : const Color(0xFFE6E6E6),
          ),
        ),
        child: Row(
          children: [
            if (mostrarCheckbox)
              SizedBox(
                width: 36,
                height: 36,
                child: Checkbox(
                  value: marcado,
                  onChanged: (v) => onToggle(v ?? false),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              )
            else
              const SizedBox(width: 4),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    brinco,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  if (entrada.isNotEmpty)
                    Text(
                      'Entrada $entrada kg',
                      style: const TextStyle(fontFamily: 'Montserrat', fontSize: 11, color: Color(0xFF8A8A8A)),
                    ),
                ],
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
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                  style: const TextStyle(fontFamily: 'Montserrat', fontSize: 13),
                  decoration: decoracaoCampo('Peso saída kg').copyWith(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    isDense: true,
                  ),
                  onChanged: onPeso,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
