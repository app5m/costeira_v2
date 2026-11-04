import 'package:costeira/core/api/api_client.dart';
import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/components/adaptive_selection_modal.dart';
import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/features/financeiro/domain/financeiro_mock.dart';
import 'package:costeira/features/financeiro/infra/financeiro_api.dart';
import 'package:costeira/features/financeiro/presentation/pages/relatorio_detalhe_page.dart';
import 'package:costeira/features/financeiro/presentation/web/financeiro_web_export.dart';
import 'package:costeira/features/financeiro/presentation/web/widgets/financeiro_web_ui.dart';
import 'package:costeira/features/financeiro/presentation/widgets/financeiro_ui.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class FinanceiroRelatoriosWeb extends StatelessWidget {
  const FinanceiroRelatoriosWeb({super.key, required this.aoAbrir});

  final ValueChanged<String> aoAbrir;

  static const _itens = [
    (
      'extrato',
      'Extrato / Livro caixa',
      'Movimentos de caixa do ano',
      LucideIcons.bookOpen,
    ),
    (
      'fluxo',
      'Fluxo de caixa',
      'Saldo, entradas e meses',
      LucideIcons.lineChart,
    ),
    ('dre', 'DRE', 'Livro caixa, financeira e econômica', LucideIcons.pieChart),
    (
      'resultado',
      'Resultado por categoria',
      'Cabeças, custos e resultado',
      LucideIcons.barChart3,
    ),
    (
      'investidor',
      'Por investidor',
      'Contratos e entradas de parceria',
      LucideIcons.users,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.sizeOf(context).width < 760 ? 16.0 : 28.0;
    final wide = MediaQuery.sizeOf(context).width >= 900;

    return ListView(
      padding: EdgeInsets.fromLTRB(padding, 20, padding, 32),
      children: [
        const FinanceiroWebSectionTitle('Relatórios financeiros'),
        const SizedBox(height: 4),
        const Text(
          'Escolha um relatório para detalhar ou exportar',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 13,
            color: Color(0xFF8A8A8A),
          ),
        ),
        const SizedBox(height: 16),
        if (wide)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _itens.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              mainAxisExtent: 132,
            ),
            itemBuilder: (context, index) => _card(_itens[index]),
          )
        else
          for (final item in _itens) ...[
            _card(item),
            const SizedBox(height: 10),
          ],
      ],
    );
  }

  Widget _card((String, String, String, IconData) item) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: financeiroWebBorda),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A1F2A24),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => aoAbrir(item.$1),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0x1400823A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.$4, size: 19, color: MyColors.colorPrimary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item.$2,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF313131),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.$3,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 12,
                          color: Color(0xFF8A8A8A),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  LucideIcons.chevronRight,
                  size: 18,
                  color: Color(0xFF8A8A8A),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FinanceiroRelatorioDetalheWeb extends StatefulWidget {
  const FinanceiroRelatorioDetalheWeb({
    super.key,
    required this.id,
    required this.aoVoltar,
    this.ocultarCabecalho = false,
  });

  final String id;
  final VoidCallback aoVoltar;
  final bool ocultarCabecalho;

  @override
  State<FinanceiroRelatorioDetalheWeb> createState() =>
      _FinanceiroRelatorioDetalheWebState();
}

class _FinanceiroRelatorioDetalheWebState
    extends State<FinanceiroRelatorioDetalheWeb> {
  Map<String, dynamic> _dados = const {};
  bool _carregando = true;
  bool _exportando = false;
  String? _erro;
  String _dre = 'livro_caixa';
  String _origem = 'Todas';
  String _tipoExtrato = 'Todos';
  late final TextEditingController _dataIn;
  late final TextEditingController _dataOut;
  late final MaskTextInputFormatter _mascaraIn;
  late final MaskTextInputFormatter _mascaraOut;
  int? _fazendaOuvida;
  String? _anoOuvido;
  bool _iniciou = false;

  bool get _podeExportar =>
      widget.id == 'extrato' || widget.id == 'fluxo' || widget.id == 'dre';

  String get _titulo => switch (widget.id) {
    'extrato' => 'Extrato / Livro caixa',
    'fluxo' => 'Fluxo de caixa',
    'dre' => 'DRE',
    'resultado' => 'Resultado por categoria',
    _ => 'Relatório',
  };

  bool _filtroAtivo(FinanceiroLoja loja) {
    final ano = loja.anoAgricola;
    final dataIn = _dataIn.text.trim();
    final dataOut = _dataOut.text.trim();
    final periodoCustom =
        ano == null || dataIn != _fmt(ano.dataIn) || dataOut != _fmt(ano.dataOut);
    return _origem != 'Todas' ||
        _tipoExtrato != 'Todos' ||
        periodoCustom;
  }

  String get _resumoFiltro {
    final partes = <String>[
      if (_dataIn.text.trim().isNotEmpty && _dataOut.text.trim().isNotEmpty)
        '${_dataIn.text.trim()} a ${_dataOut.text.trim()}',
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
    final mesmoAno =
        ano != null && dataIn == _fmt(ano.dataIn) && dataOut == _fmt(ano.dataOut);
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

  String _fmt(DateTime data) {
    final d = data.day.toString().padLeft(2, '0');
    final m = data.month.toString().padLeft(2, '0');
    return '$d/$m/${data.year}';
  }

  void _sincronizarDatasDoAno(FinanceiroLoja loja) {
    final ano = loja.anoAgricola;
    if (ano != null) {
      _dataIn.text = _fmt(ano.dataIn);
      _dataOut.text = _fmt(ano.dataOut);
    } else if (_dataIn.text.trim().isEmpty || _dataOut.text.trim().isEmpty) {
      final y = DateTime.now().year;
      _dataIn.text = '01/01/$y';
      _dataOut.text = '31/12/$y';
    }
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
      _sincronizarDatasDoAno(loja);
      _fazendaOuvida = loja.fazendaId;
      _anoOuvido = loja.anoAgricola?.label;
      _iniciou = true;
      _carregar();
    });
  }

  @override
  void dispose() {
    _dataIn.dispose();
    _dataOut.dispose();
    super.dispose();
  }

  Future<void> _carregar() async {
    final loja = FinanceiroEscopo.of(context);
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final dados = await loja.carregarRelatorio(widget.id, _filtroDe(loja));
      if (!mounted) return;
      setState(() {
        _dados = dados;
        _carregando = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _erro = error.message;
        _carregando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _erro = 'Não foi possível carregar o relatório.';
        _carregando = false;
      });
    }
  }

  Future<void> _exportar() async {
    if (!_podeExportar) return;
    setState(() => _exportando = true);
    try {
      final loja = FinanceiroEscopo.of(context);
      await FinanceiroWebExport(
        ApiClient.instance,
      ).exportar(widget.id, filtro: _filtroDe(loja));
      if (!mounted) return;
      AppSnackBar.show(
        context: context,
        message: 'Download iniciado.',
        isError: false,
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      AppSnackBar.show(context: context, message: error.message);
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.show(
        context: context,
        message: 'Falha ao exportar o relatório.',
      );
    } finally {
      if (mounted) setState(() => _exportando = false);
    }
  }

  Future<void> _abrirFiltros() async {
    final loja = FinanceiroEscopo.of(context);
    var origem = _origem;
    var tipo = _tipoExtrato;
    final dataIn = TextEditingController(text: _dataIn.text);
    final dataOut = TextEditingController(text: _dataOut.text);
    final mascaraIn = mascaraData();
    final mascaraOut = mascaraData();

    try {
      final aplicou = await showAdaptiveSelectionModal<bool>(
        context: context,
        title: 'Filtros',
        builder: (embeddedInDialog) {
          return StatefulBuilder(
            builder: (modal, setSheet) {
              return Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  embeddedInDialog ? 8 : 12,
                  16,
                  16 + MediaQuery.of(modal).viewInsets.bottom,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!embeddedInDialog) ...[
                        const Text(
                          'Filtros',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],
                      const Text(
                        'Período',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
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
                              style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      const Text(
                        'Origem',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 12,
                          color: Color(0xFF8A8A8A),
                        ),
                      ),
                      const SizedBox(height: 6),
                      GrupoChips(
                        opcoes: const ['Todas', 'Manual', 'Sistema'],
                        selecionado: origem,
                        aoEscolher: (v) => setSheet(() => origem = v),
                      ),
                      if (widget.id == 'extrato') ...[
                        const SizedBox(height: 10),
                        const Text(
                          'Tipo',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 12,
                            color: Color(0xFF8A8A8A),
                          ),
                        ),
                        const SizedBox(height: 6),
                        GrupoChips(
                          opcoes: const ['Todos', 'Recebimento', 'Pagamento'],
                          selecionado: tipo,
                          aoEscolher: (v) => setSheet(() => tipo = v),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(modal, false),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(48),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Cancelar',
                                style: TextStyle(fontFamily: 'Montserrat'),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: BotaoPrimarioFinanceiro(
                              rotulo: 'Aplicar',
                              onPressed: () => Navigator.pop(modal, true),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
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
      await _carregar();
    } finally {
      dataIn.dispose();
      dataOut.dispose();
    }
  }

  static const _acaoAltura = 42.0;
  static const _acaoRaio = 9.0;
  static const _acaoBorda = Color(0xFFC9D4CB);

  ButtonStyle _estiloAcao({bool destaque = false}) {
    return OutlinedButton.styleFrom(
      foregroundColor: destaque ? MyColors.colorPrimary : const Color(0xFF313131),
      backgroundColor: destaque ? const Color(0x1400823A) : Colors.white,
      minimumSize: const Size(0, _acaoAltura),
      fixedSize: const Size.fromHeight(_acaoAltura),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      side: BorderSide(
        color: destaque ? MyColors.colorPrimary : _acaoBorda,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_acaoRaio),
      ),
      textStyle: const TextStyle(
        fontFamily: 'Montserrat',
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _botaoFiltro({required bool ativo}) {
    return SizedBox(
      height: _acaoAltura,
      child: OutlinedButton.icon(
        onPressed: _carregando ? null : _abrirFiltros,
        icon: Icon(
          LucideIcons.slidersHorizontal,
          size: 16,
          color: ativo ? MyColors.colorPrimary : const Color(0xFF6B6B6B),
        ),
        label: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 280),
          child: Text(
            _resumoFiltro,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        style: _estiloAcao(destaque: ativo),
      ),
    );
  }

  Widget _botaoExportar() {
    return SizedBox(
      height: _acaoAltura,
      child: OutlinedButton.icon(
        onPressed: (_exportando || _carregando) ? null : _exportar,
        icon: _exportando
            ? const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(LucideIcons.download, size: 16),
        label: const Text('Exportar CSV'),
        style: _estiloAcao(),
      ),
    );
  }

  Widget _botaoAtualizar() {
    return SizedBox(
      width: _acaoAltura,
      height: _acaoAltura,
      child: OutlinedButton(
        onPressed: _carregando ? null : _carregar,
        style: _estiloAcao().copyWith(
          padding: const WidgetStatePropertyAll(EdgeInsets.zero),
        ),
        child: const Icon(LucideIcons.refreshCw, size: 16),
      ),
    );
  }

  Widget _acoesTopo({required bool filtroAtivo}) {
    return Row(
      children: [
        if (_podeExportar) ...[
          _botaoExportar(),
          const SizedBox(width: 8),
        ],
        Flexible(child: _botaoFiltro(ativo: filtroAtivo)),
        const SizedBox(width: 8),
        _botaoAtualizar(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final loja = FinanceiroEscopo.of(context);
    if (_iniciou) {
      final fazendaMudou = loja.fazendaId != _fazendaOuvida;
      final anoMudou = loja.anoAgricola?.label != _anoOuvido;
      if (fazendaMudou || anoMudou) {
        _fazendaOuvida = loja.fazendaId;
        _anoOuvido = loja.anoAgricola?.label;
        if (anoMudou) _sincronizarDatasDoAno(loja);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _carregar();
        });
      }
    }

    final padding = MediaQuery.sizeOf(context).width < 760 ? 16.0 : 28.0;
    final filtroAtivo = _filtroAtivo(loja);

    final corpo = ListView(
      padding: EdgeInsets.fromLTRB(padding, 20, padding, 32),
      children: [
        if (widget.ocultarCabecalho) ...[
          _acoesTopo(filtroAtivo: filtroAtivo),
          const SizedBox(height: 16),
        ],
        if (_carregando)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(child: LoadingFinanceiro(altura: 160)),
          )
        else if (_erro != null)
          FinanceiroWebEmpty(
            message: _erro!,
            actionLabel: 'Tentar novamente',
            onAction: _carregar,
          )
        else if (_dados.isEmpty)
          const FinanceiroWebEmpty(message: 'Sem dados para o período.')
        else
          FinanceiroRelatorioConteudo(
            id: widget.id,
            mapa: _dados,
            dreBloco: _dre,
            aoEscolherDre: (valor) => setState(() => _dre = valor),
          ),
      ],
    );

    if (widget.ocultarCabecalho) {
      return ColoredBox(color: financeiroWebFundo, child: corpo);
    }

    return Column(
      children: [
        FinanceiroWebToolbar(
          title: _titulo,
          leading: FinanceiroWebBackButton(onPressed: widget.aoVoltar),
          actions: [
            if (_podeExportar) ...[
              _botaoExportar(),
              const SizedBox(width: 8),
            ],
            _botaoFiltro(ativo: filtroAtivo),
            const SizedBox(width: 8),
            _botaoAtualizar(),
          ],
        ),
        const Divider(height: 1, color: financeiroWebBorda),
        Expanded(child: corpo),
      ],
    );
  }
}
