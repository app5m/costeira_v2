import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/features/financeiro/domain/financeiro_mock.dart';
import 'package:costeira/features/financeiro/infra/financeiro_api.dart';
import 'package:costeira/features/financeiro/presentation/widgets/financeiro_ui.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:share_plus/share_plus.dart';

class RelatorioDetalhePage extends StatefulWidget {
  const RelatorioDetalhePage({super.key, required this.id, required this.aoVoltar});

  final String id;
  final VoidCallback aoVoltar;

  @override
  State<RelatorioDetalhePage> createState() => _RelatorioDetalhePageState();
}

class _RelatorioDetalhePageState extends State<RelatorioDetalhePage> {
  String _dre = 'livro_caixa';
  bool _exportando = false;
  bool _carregando = false;
  String _origem = 'Todas';
  String _tipoExtrato = 'Todos';
  late final TextEditingController _dataIn;
  late final TextEditingController _dataOut;
  late final MaskTextInputFormatter _mascaraIn;
  late final MaskTextInputFormatter _mascaraOut;
  Map<String, dynamic> _mapa = const {};

  static const _dreOpcoes = [
    ('livro_caixa', 'Livro caixa'),
    ('analise_financeira', 'Financeira'),
    ('analise_economica', 'Econômica'),
  ];

  bool get _temCsv => widget.id != 'resultado';

  String get _titulo => switch (widget.id) {
        'extrato' => 'Extrato',
        'fluxo' => 'Fluxo de caixa',
        'dre' => 'DRE',
        _ => 'Resultado',
      };

  bool _filtroAtivo(FinanceiroLoja loja) {
    final ano = loja.anoAgricola;
    final dataIn = _dataIn.text.trim();
    final dataOut = _dataOut.text.trim();
    final periodoCustom = ano == null || dataIn != _fmt(ano.dataIn) || dataOut != _fmt(ano.dataOut);
    return _origem != 'Todas' || _tipoExtrato != 'Todos' || periodoCustom;
  }

  String get _resumoFiltro {
    final partes = <String>[
      if (_dataIn.text.trim().isNotEmpty && _dataOut.text.trim().isNotEmpty)
        '${_dataIn.text.trim()} → ${_dataOut.text.trim()}',
      if (_origem != 'Todas') _origem,
      if (widget.id == 'extrato' && _tipoExtrato != 'Todos') _tipoExtrato,
    ];
    return partes.isEmpty ? 'Filtrar' : partes.join(' · ');
  }

  FiltroFinanceiro _filtroDe(FinanceiroLoja loja) {
    final origem = switch (_origem) {
      'Manual' => 'manual',
      'Sistema' => 'sistema',
      _ => null,
    };
    final tipos = switch (_tipoExtrato) {
      'Recebimento' => const ['recebimento'],
      'Pagamento' => const ['pagamento'],
      _ => const <String>[],
    };
    final dataIn = _dataIn.text.trim();
    final dataOut = _dataOut.text.trim();
    final ano = loja.anoAgricola;
    final mesmoAno = ano != null && dataIn == _fmt(ano.dataIn) && dataOut == _fmt(ano.dataOut);
    if (mesmoAno && ano.id != null && ano.id! > 0) {
      return FiltroFinanceiro(
        idAnoAgricola: ano.id,
        tipos: widget.id == 'extrato' ? tipos : const [],
        origem: origem,
      );
    }
    return FiltroFinanceiro(
      dataIn: dataIn.length >= 10 ? dataIn : null,
      dataOut: dataOut.length >= 10 ? dataOut : null,
      tipos: widget.id == 'extrato' ? tipos : const [],
      origem: origem,
    );
  }

  @override
  void initState() {
    super.initState();
    _mascaraIn = mascaraData();
    _mascaraOut = mascaraData();
    _dataIn = TextEditingController();
    _dataOut = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final loja = FinanceiroEscopo.of(context);
      final ano = loja.anoAgricola;
      if (ano != null) {
        _dataIn.text = _fmt(ano.dataIn);
        _dataOut.text = _fmt(ano.dataOut);
      } else {
        final y = DateTime.now().year;
        _dataIn.text = '01/01/$y';
        _dataOut.text = '31/12/$y';
      }
      _aplicarFiltro();
    });
  }

  String _fmt(DateTime data) {
    final d = data.day.toString().padLeft(2, '0');
    final m = data.month.toString().padLeft(2, '0');
    return '$d/$m/${data.year}';
  }

  @override
  void dispose() {
    _dataIn.dispose();
    _dataOut.dispose();
    super.dispose();
  }

  Future<void> _aplicarFiltro() async {
    final loja = FinanceiroEscopo.of(context);
    setState(() => _carregando = true);
    try {
      final mapa = await loja.carregarRelatorio(widget.id, _filtroDe(loja));
      if (!mounted) return;
      setState(() {
        _mapa = mapa;
        _carregando = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _carregando = false);
      AppSnackBar.show(context: context, message: error.message);
    } catch (error) {
      if (!mounted) return;
      setState(() => _carregando = false);
      AppSnackBar.show(context: context, message: error.toString());
    }
  }

  Future<void> _exportar() async {
    final loja = FinanceiroEscopo.of(context);
    setState(() => _exportando = true);
    try {
      final arquivo = await loja.exportarCsv(widget.id, filtro: _filtroDe(loja));
      if (!mounted) return;
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(arquivo.path, mimeType: 'text/csv')],
          subject: _titulo,
          text: 'Exportação $_titulo',
        ),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      AppSnackBar.show(context: context, message: error.message);
    } catch (error) {
      if (!mounted) return;
      AppSnackBar.show(context: context, message: error.toString());
    } finally {
      if (mounted) setState(() => _exportando = false);
    }
  }

  List<double> get _barrasFluxo => barrasFluxoRelatorio(_mapa);

  Future<void> _abrirFiltros() async {
    final loja = FinanceiroEscopo.of(context);
    var origem = _origem;
    var tipo = _tipoExtrato;
    final dataIn = TextEditingController(text: _dataIn.text);
    final dataOut = TextEditingController(text: _dataOut.text);
    final mascaraIn = mascaraData();
    final mascaraOut = mascaraData();
    try {
      final aplicou = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (sheet) {
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + MediaQuery.viewInsetsOf(sheet).bottom),
              child: StatefulBuilder(
                builder: (context, setSheet) {
                  return SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                        const Text(
                          'Filtros',
                          style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700, fontSize: 16),
                        ),
                        const SizedBox(height: 14),
                        const Text('Período', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700)),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: CampoFinanceiro(
                                rotulo: 'DE',
                                child: TextField(
                                  controller: dataIn,
                                  keyboardType: tecladoData,
                                  inputFormatters: [mascaraIn],
                                  decoration: decoracaoCampo('dd/MM/aaaa'),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: CampoFinanceiro(
                                rotulo: 'ATÉ',
                                child: TextField(
                                  controller: dataOut,
                                  keyboardType: tecladoData,
                                  inputFormatters: [mascaraOut],
                                  decoration: decoracaoCampo('dd/MM/aaaa'),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (loja.anoAgricola != null) ...[
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton(
                              onPressed: () {
                                final ano = loja.anoAgricola!;
                                setSheet(() {
                                  dataIn.text = _fmt(ano.dataIn);
                                  dataOut.text = _fmt(ano.dataOut);
                                });
                              },
                              child: Text(
                                'Usar ano agrícola (${loja.anoAgricolaLabel})',
                                style: const TextStyle(fontFamily: 'Montserrat', fontSize: 12),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        const Text('Origem', style: TextStyle(fontFamily: 'Montserrat', fontSize: 12, color: Color(0xFF8A8A8A))),
                        const SizedBox(height: 6),
                        GrupoChips(
                          opcoes: const ['Todas', 'Manual', 'Sistema'],
                          selecionado: origem,
                          aoEscolher: (v) => setSheet(() => origem = v),
                        ),
                        if (widget.id == 'extrato') ...[
                          const SizedBox(height: 10),
                          const Text('Tipo', style: TextStyle(fontFamily: 'Montserrat', fontSize: 12, color: Color(0xFF8A8A8A))),
                          const SizedBox(height: 6),
                          GrupoChips(
                            opcoes: const ['Todos', 'Recebimento', 'Pagamento'],
                            selecionado: tipo,
                            aoEscolher: (v) => setSheet(() => tipo = v),
                          ),
                        ],
                        const SizedBox(height: 16),
                        BotaoPrimarioFinanceiro(
                          rotulo: 'Aplicar',
                          onPressed: () => Navigator.pop(sheet, true),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(sheet, false),
                          child: const Text('Cancelar', style: TextStyle(fontFamily: 'Montserrat')),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        },
      );
      if (aplicou != true || !mounted) return;
      setState(() {
        _dataIn.text = dataIn.text.trim();
        _dataOut.text = dataOut.text.trim();
        _origem = origem;
        _tipoExtrato = tipo;
      });
      await _aplicarFiltro();
    } finally {
      dataIn.dispose();
      dataOut.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final loja = FinanceiroEscopo.of(context);
    final filtroAtivo = _filtroAtivo(loja);
    return Scaffold(
      backgroundColor: fundoFinanceiro,
      appBar: AppBar(
        backgroundColor: MyColors.colorPrimary,
        foregroundColor: Colors.white,
        title: Text(_titulo, style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600, fontSize: 17)),
        leading: IconButton(onPressed: widget.aoVoltar, icon: const Icon(Icons.arrow_back)),
        actions: [
          IconButton(
            onPressed: _carregando ? null : _abrirFiltros,
            icon: const Icon(Icons.tune_rounded),
            tooltip: 'Filtros',
          ),
          if (_temCsv)
            IconButton(
              onPressed: (_exportando || _carregando) ? null : _exportar,
              icon: _exportando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.ios_share_outlined),
              tooltip: 'Exportar CSV',
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: _carregando ? null : _abrirFiltros,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: filtroAtivo ? const Color(0x14128977) : Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: filtroAtivo ? MyColors.colorPrimary : const Color(0xFFE6E6E6),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.tune_rounded,
                      size: 16,
                      color: filtroAtivo ? MyColors.colorPrimary : const Color(0xFF8C8C8C),
                    ),
                    const SizedBox(width: 6),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 260),
                      child: Text(
                        _resumoFiltro,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: filtroAtivo ? MyColors.colorPrimary : const Color(0xFF8C8C8C),
                          fontSize: 12,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (_carregando)
            const LoadingFinanceiro(altura: 160, rotulo: 'Carregando relatório…')
          else
            FinanceiroRelatorioConteudo(
              id: widget.id,
              mapa: _mapa,
              dreBloco: _dre,
              aoEscolherDre: (valor) => setState(() => _dre = valor),
            ),
        ],
      ),
    );
  }
}

/// Conteúdo formatado do relatório (reutilizado na web).
class FinanceiroRelatorioConteudo extends StatelessWidget {
  const FinanceiroRelatorioConteudo({
    super.key,
    required this.id,
    required this.mapa,
    this.dreBloco = 'livro_caixa',
    this.aoEscolherDre,
  });

  final String id;
  final Map<String, dynamic> mapa;
  final String dreBloco;
  final ValueChanged<String>? aoEscolherDre;

  @override
  Widget build(BuildContext context) {
    return switch (id) {
      'extrato' => _Extrato(mapa: mapa),
      'fluxo' => _Fluxo(mapa: mapa, barras: barrasFluxoRelatorio(mapa)),
      'dre' => _Dre(
          mapa: mapa,
          bloco: dreBloco,
          aoEscolher: aoEscolherDre ?? (_) {},
        ),
      _ => _Resultado(mapa: mapa),
    };
  }
}

List<double> barrasFluxoRelatorio(Map<String, dynamic> mapa) {
  final series = (mapa['grafico']?['series'] as List?) ?? const [];
  final entradas =
      series.cast<Map?>().whereType<Map>().where((s) => s['chave'] == 'entradas');
  if (entradas.isEmpty) return const [];
  final dados = (entradas.first['dados'] as List?) ?? const [];
  return [
    for (final item in dados) double.tryParse(item.toString()) ?? 0,
  ];
}

class _Extrato extends StatelessWidget {
  const _Extrato({required this.mapa});

  final Map<String, dynamic> mapa;

  @override
  Widget build(BuildContext context) {
    final indicadores = _mapa(mapa['indicadores']);
    final linhas = _linhas(mapa['lista']);
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _Mini('Recebimentos', _dinheiro(indicadores, 'total_recebimentos'), MyColors.colorPrimary)),
            const SizedBox(width: 8),
            Expanded(child: _Mini('Saídas', _dinheiro(indicadores, 'total_saidas'), const Color(0xFFC62828))),
            const SizedBox(width: 8),
            Expanded(child: _Mini('Saldo do período', _dinheiro(indicadores, 'saldo_periodo'), const Color(0xFF1C1C1C))),
          ],
        ),
        const SizedBox(height: 12),
        if (linhas.isEmpty)
          const _Vazio('Nenhum movimento neste período.')
        else
          for (final linha in linhas) ...[
            CartaoBranco(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _texto(linha, 'descricao').isEmpty ? 'Movimento' : _texto(linha, 'descricao'),
                          style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          [
                            _texto(linha, 'data'),
                            _texto(linha, 'conta_nome'),
                            _texto(linha, 'tipo_nome'),
                          ].where((parte) => parte.isNotEmpty).join(' · '),
                          style: const TextStyle(fontFamily: 'Montserrat', fontSize: 12, color: Color(0xFF8A8A8A)),
                        ),
                        if (_natureza(linha).isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            _natureza(linha),
                            style: const TextStyle(fontFamily: 'Montserrat', fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF3D5346)),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _dinheiro(linha, 'valor_assinado').isEmpty ? _dinheiro(linha, 'valor') : _dinheiro(linha, 'valor_assinado'),
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w800,
                      color: _texto(linha, 'direcao') == 'saida' ? const Color(0xFFC62828) : MyColors.colorPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
      ],
    );
  }
}

class _Fluxo extends StatelessWidget {
  const _Fluxo({required this.mapa, required this.barras});

  final Map<String, dynamic> mapa;
  final List<double> barras;

  @override
  Widget build(BuildContext context) {
    final indicadores = _mapa(mapa['indicadores']);
    final meses = _linhas(mapa['lista']);
    final grafico = barras.isEmpty ? const [0.0] : barras;
    final topo = grafico.reduce((a, b) => a > b ? a : b);
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _Mini('Saldo disponível', _dinheiro(indicadores, 'saldo_disponivel'), MyColors.colorPrimary)),
            const SizedBox(width: 8),
            Expanded(child: _Mini('Entradas', _dinheiro(indicadores, 'total_entradas'), MyColors.colorPrimary)),
            const SizedBox(width: 8),
            Expanded(child: _Mini('Saídas', _dinheiro(indicadores, 'total_saidas'), const Color(0xFFC62828))),
          ],
        ),
        const SizedBox(height: 12),
        CartaoBranco(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Entradas no ano', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              SizedBox(
                height: 88,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (final valor in grafico)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              height: topo == 0 ? 4 : (valor / topo) * 88,
                              decoration: BoxDecoration(
                                color: MyColors.colorPrimary.withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (meses.isEmpty)
          const _Vazio('Nenhum mês neste período.')
        else
          for (final mes in meses) ...[
            CartaoBranco(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _texto(mes, 'mes_nome').isEmpty ? _mesLegivel(_texto(mes, 'mes')) : _texto(mes, 'mes_nome'),
                    style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  _Par('Entradas', _dinheiro(mes, 'entradas'), MyColors.colorPrimary),
                  _Par('Saídas', _dinheiro(mes, 'saidas'), const Color(0xFFC62828)),
                  _Par('Saldo acumulado', _dinheiro(mes, 'saldo_acumulado'), const Color(0xFF1C1C1C)),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
      ],
    );
  }
}

class _Dre extends StatelessWidget {
  const _Dre({required this.mapa, required this.bloco, required this.aoEscolher});

  final Map<String, dynamic> mapa;
  final String bloco;
  final ValueChanged<String> aoEscolher;

  @override
  Widget build(BuildContext context) {
    final grupos = _linhas(mapa[bloco]);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GrupoChips(
          opcoes: [for (final opcao in _RelatorioDetalhePageState._dreOpcoes) opcao.$2],
          selecionado: _RelatorioDetalhePageState._dreOpcoes.firstWhere((opcao) => opcao.$1 == bloco).$2,
          aoEscolher: (rotulo) {
            final escolhido = _RelatorioDetalhePageState._dreOpcoes.firstWhere((opcao) => opcao.$2 == rotulo);
            aoEscolher(escolhido.$1);
          },
        ),
        const SizedBox(height: 12),
        if (grupos.isEmpty)
          const _Vazio('Nenhum grupo neste recorte.')
        else
          for (final grupo in grupos) ...[
            _GrupoDre(grupo: grupo),
            const SizedBox(height: 8),
          ],
      ],
    );
  }
}

class _GrupoDre extends StatelessWidget {
  const _GrupoDre({required this.grupo});

  final Map<String, dynamic> grupo;

  @override
  Widget build(BuildContext context) {
    final tipo = _texto(grupo, 'tipo');
    final itens = _linhas(grupo['itens']);
    final destaque = tipo == 'resultado' || tipo == 'subtotal';
    final titulo = Text(
      _texto(grupo, 'nome'),
      style: TextStyle(
        fontFamily: 'Montserrat',
        fontWeight: destaque ? FontWeight.w800 : FontWeight.w600,
        color: tipo == 'informativo' ? const Color(0xFF8A8A8A) : const Color(0xFF1C1C1C),
      ),
    );
    final valor = Text(
      _dinheiro(grupo, 'valor'),
      style: TextStyle(
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.w800,
        color: _negativo(_dinheiro(grupo, 'valor')) ? const Color(0xFFC62828) : const Color(0xFF1C1C1C),
      ),
    );
    if (itens.isEmpty) {
      return CartaoBranco(
        child: Row(
          children: [
            Expanded(child: titulo),
            const SizedBox(width: 8),
            valor,
          ],
        ),
      );
    }
    return CartaoBranco(
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.only(top: 4),
          title: Row(
            children: [
              Expanded(child: titulo),
              const SizedBox(width: 8),
              valor,
            ],
          ),
          children: [
            for (final item in itens)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _texto(item, 'descricao'),
                        style: const TextStyle(fontFamily: 'Montserrat', fontSize: 13, color: Color(0xFF3D5346)),
                      ),
                    ),
                    Text(
                      _dinheiro(item, 'valor'),
                      style: const TextStyle(fontFamily: 'Montserrat', fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Resultado extends StatelessWidget {
  const _Resultado({required this.mapa});

  final Map<String, dynamic> mapa;

  @override
  Widget build(BuildContext context) {
    final linhas = _linhas(mapa['lista']);
    if (linhas.isEmpty) return const _Vazio('Nenhum resultado por categoria neste período.');
    return Column(
      children: [
        for (final linha in linhas) ...[
          CartaoBranco(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  [
                    _texto(linha, 'categoria').isEmpty ? 'Geral' : _texto(linha, 'categoria'),
                    _texto(linha, 'fase'),
                  ].where((parte) => parte.isNotEmpty).join(' · '),
                  style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_texto(linha, 'cabecas').isEmpty ? '0' : _texto(linha, 'cabecas')} cabeças',
                  style: const TextStyle(fontFamily: 'Montserrat', fontSize: 12, color: Color(0xFF8A8A8A)),
                ),
                const SizedBox(height: 8),
                _Par('Investimento', _dinheiro(linha, 'investimento'), const Color(0xFF1C1C1C)),
                _Par('Custo variável', _dinheiro(linha, 'custo_variavel'), const Color(0xFF1C1C1C)),
                _Par('Custo fixo', _dinheiro(linha, 'custo_fixo_rateado'), const Color(0xFF1C1C1C)),
                _Par('Receita', _dinheiro(linha, 'receita'), MyColors.colorPrimary),
                _Par('Resultado', _dinheiro(linha, 'resultado'), _negativo(_dinheiro(linha, 'resultado')) ? const Color(0xFFC62828) : MyColors.colorPrimary),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _Mini extends StatelessWidget {
  const _Mini(this.rotulo, this.valor, this.cor);

  final String rotulo;
  final String valor;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE6E6E6)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              rotulo,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontFamily: 'Montserrat', fontSize: 10, height: 1.25, fontWeight: FontWeight.w600, color: Color(0xFF8A8A8A)),
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                valor.isEmpty ? r'R$ 0,00' : valor,
                maxLines: 1,
                style: TextStyle(fontFamily: 'Montserrat', fontSize: 13, fontWeight: FontWeight.w800, color: cor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Par extends StatelessWidget {
  const _Par(this.rotulo, this.valor, this.cor);

  final String rotulo;
  final String valor;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Expanded(child: Text(rotulo, style: const TextStyle(fontFamily: 'Montserrat', fontSize: 12, color: Color(0xFF8A8A8A)))),
          Text(valor.isEmpty ? r'R$ 0,00' : valor, style: TextStyle(fontFamily: 'Montserrat', fontSize: 12, fontWeight: FontWeight.w700, color: cor)),
        ],
      ),
    );
  }
}

class _Vazio extends StatelessWidget {
  const _Vazio(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    return CartaoBranco(
      child: Text(texto, style: const TextStyle(fontFamily: 'Montserrat', color: Color(0xFF8A8A8A))),
    );
  }
}

Map<String, dynamic> _mapa(dynamic valor) {
  if (valor is Map) return Map<String, dynamic>.from(valor);
  return const {};
}

List<Map<String, dynamic>> _linhas(dynamic lista) {
  if (lista is! List) return const [];
  final saida = <Map<String, dynamic>>[];
  for (final item in lista) {
    if (item is! Map) continue;
    final mapa = Map<String, dynamic>.from(item);
    if (mapa.containsKey('rows')) continue;
    final util = mapa['id'] != null ||
        mapa['nome'] != null ||
        mapa['mes'] != null ||
        mapa['categoria'] != null ||
        mapa['descricao'] != null ||
        mapa['chave'] != null;
    if (util) saida.add(mapa);
  }
  return saida;
}

String _texto(Map<String, dynamic> item, String chave) => item[chave]?.toString().trim() ?? '';

String _dinheiro(Map<String, dynamic> item, String chave) {
  final pronto = _texto(item, '${chave}_string');
  if (pronto.isNotEmpty) return pronto.trim();
  final numero = double.tryParse(_texto(item, chave));
  if (numero == null) return '';
  return reais(numero);
}

String _natureza(Map<String, dynamic> linha) {
  return switch (_texto(linha, 'natureza')) {
    'liquidacao' => 'Baixa',
    'estorno' => 'Estorno',
    'saldo_inicial' => 'Abertura',
    _ => '',
  };
}

String _mesLegivel(String chave) {
  const nomes = ['jan.', 'fev.', 'mar.', 'abr.', 'mai.', 'jun.', 'jul.', 'ago.', 'set.', 'out.', 'nov.', 'dez.'];
  final partes = chave.split('-');
  if (partes.length != 2) return chave;
  final mes = int.tryParse(partes[1]) ?? 0;
  if (mes < 1 || mes > 12) return chave;
  return '${nomes[mes - 1]} de ${partes[0]}';
}

bool _negativo(String valor) => valor.contains('-');
