import 'package:costeira/core/api/api_client.dart';
import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/features/financeiro/domain/financeiro_mock.dart';
import 'package:costeira/features/financeiro/presentation/pages/relatorio_detalhe_page.dart';
import 'package:costeira/features/financeiro/presentation/web/financeiro_web_export.dart';
import 'package:costeira/features/financeiro/presentation/web/widgets/financeiro_web_ui.dart';
import 'package:costeira/features/financeiro/presentation/widgets/financeiro_ui.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _carregar());
  }

  Future<void> _carregar() async {
    final loja = FinanceiroEscopo.of(context);
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final dados = await loja.carregarRelatorio(widget.id, loja.filtroPeriodo);
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
    if (widget.id == 'resultado') return;
    setState(() => _exportando = true);
    try {
      final loja = FinanceiroEscopo.of(context);
      await FinanceiroWebExport(
        ApiClient.instance,
      ).exportar(widget.id, filtro: loja.filtroPeriodo);
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

  String get _titulo => switch (widget.id) {
    'extrato' => 'Extrato / Livro caixa',
    'fluxo' => 'Fluxo de caixa',
    'dre' => 'DRE',
    'resultado' => 'Resultado por categoria',
    _ => 'Relatório',
  };

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.sizeOf(context).width < 760 ? 16.0 : 28.0;
    final podeExportar =
        widget.id == 'extrato' || widget.id == 'fluxo' || widget.id == 'dre';

    final corpo = _carregando
        ? const Center(child: LoadingFinanceiro(altura: 200))
        : _erro != null
        ? FinanceiroWebEmpty(
            message: _erro!,
            actionLabel: 'Tentar novamente',
            onAction: _carregar,
          )
        : ListView(
            padding: EdgeInsets.fromLTRB(padding, 20, padding, 32),
            children: [
              if (widget.ocultarCabecalho) ...[
                Row(
                  children: [
                    if (podeExportar)
                      SizedBox(
                        height: 42,
                        child: OutlinedButton.icon(
                          onPressed: _exportando ? null : _exportar,
                          icon: _exportando
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(LucideIcons.download, size: 16),
                          label: const Text('Exportar CSV'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: MyColors.colorPrimary,
                          ),
                        ),
                      ),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Atualizar',
                      onPressed: _carregar,
                      icon: const Icon(LucideIcons.refreshCw, size: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              const ContextoFinanceiroFiltros(),
              const SizedBox(height: 16),
              if (_dados.isEmpty)
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
            if (podeExportar)
              SizedBox(
                height: 42,
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
                  style: OutlinedButton.styleFrom(
                    foregroundColor: MyColors.colorPrimary,
                  ),
                ),
              ),
            IconButton(
              tooltip: 'Atualizar',
              onPressed: _carregando ? null : _carregar,
              icon: const Icon(LucideIcons.refreshCw, size: 16),
            ),
          ],
        ),
        const Divider(height: 1, color: financeiroWebBorda),
        Expanded(child: corpo),
      ],
    );
  }
}
