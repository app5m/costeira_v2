import 'package:costeira/core/api/api_client.dart';
import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/common/get_list/domain/usecases/get_list_usecase.dart';
import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/features/fazendas/domain/usecases/resolve_current_farm_id.dart';
import 'package:costeira/features/relatorios/domain/relatorio_models.dart';
import 'package:costeira/features/relatorios/infra/data/relatorios_datasource.dart';
import 'package:costeira/features/relatorios/presentation/relatorios_controller.dart';
import 'package:costeira/features/relatorios/presentation/widgets/relatorio_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:share_plus/share_plus.dart';

class RelatoriosPage extends StatefulWidget {
  const RelatoriosPage({super.key});

  @override
  State<RelatoriosPage> createState() => _RelatoriosPageState();
}

class _RelatoriosPageState extends State<RelatoriosPage> {
  late final RelatoriosController controller;

  @override
  void initState() {
    super.initState();
    controller = RelatoriosController(
      datasource: RelatoriosDatasource(Modular.get<ApiClient>()),
      getList: Modular.get<GetListUsecase>(),
      fazenda: Modular.get<ResolveCurrentFarmId>(),
    );
    controller.addListener(_atualizar);
    controller.preparar();
  }

  void _atualizar() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    controller.removeListener(_atualizar);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final aberta = controller.aberta;
    final bloco = controller.blocoAberto;
    return Scaffold(
      backgroundColor: RelatorioCores.fundo,
      appBar: AppBar(
        backgroundColor: RelatorioCores.fundo,
        foregroundColor: RelatorioCores.texto,
        elevation: 0,
        title: Text(
          bloco?.titulo ?? 'Relatórios',
          style: tituloRelatorio,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (aberta != null) {
              controller.fecharDetalhe();
              return;
            }
            Modular.to.pop();
          },
        ),
      ),
      body: aberta == null
          ? _Hub(controller: controller)
          : _Detalhe(
              controller: controller,
              chave: aberta,
              onExportar: () => _exportar(aberta, bloco?.titulo ?? aberta),
            ),
    );
  }

  Future<void> _exportar(String chave, String titulo) async {
    try {
      final arquivo = await controller.exportarPdf(chave);
      if (!mounted) return;
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(arquivo.path, mimeType: 'application/pdf')],
          subject: 'Relatório $titulo',
          text: 'Relatório $titulo — ${controller.rotuloPeriodo}',
        ),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      AppSnackBar.show(context: context, message: error.message);
    } catch (error) {
      if (!mounted) return;
      AppSnackBar.show(context: context, message: error.toString());
    }
  }
}

class _Hub extends StatelessWidget {
  const _Hub({required this.controller});

  final RelatoriosController controller;

  @override
  Widget build(BuildContext context) {
    final chaves = controller.lista.chavesVisiveis;
    return Column(
      children: [
        _BarraPeriodo(controller: controller),
        if (controller.erro != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              controller.erro!,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 12,
                color: Color(0xFFC62828),
              ),
            ),
          ),
        Expanded(
          child: controller.carregando && chaves.isEmpty
              ? const Center(child: CircularProgressIndicator(color: RelatorioCores.verde))
              : RefreshIndicator(
                  color: RelatorioCores.verde,
                  onRefresh: () => controller.carregar(),
                  child: chaves.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(24),
                          children: const [
                            SizedBox(height: 80),
                            Text(
                              'Nenhum relatório disponível neste período.',
                              textAlign: TextAlign.center,
                              style: subtituloRelatorio,
                            ),
                          ],
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          itemCount: chaves.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final chave = chaves[index];
                            final bloco = controller.lista.bloco(chave)!;
                            final nInd = bloco.indicadoresVisiveis.length;
                            final nGraf = bloco.graficosVisiveis.length;
                            final nList = bloco.listasVisiveis.length;
                            final partes = <String>[
                              if (nInd > 0) '$nInd indicadores',
                              if (nGraf > 0) '$nGraf gráficos',
                              if (nList > 0) '$nList listas',
                            ];
                            return Material(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 6,
                                ),
                                title: Text(bloco.titulo, style: tituloRelatorio),
                                subtitle: Text(
                                  [
                                    bloco.subtitulo,
                                    if (partes.isNotEmpty) partes.join(' · '),
                                  ].join('\n'),
                                  style: subtituloRelatorio,
                                ),
                                isThreeLine: true,
                                trailing: const Icon(
                                  Icons.chevron_right,
                                  color: RelatorioCores.verde,
                                ),
                                onTap: () => controller.abrir(chave),
                              ),
                            );
                          },
                        ),
                ),
        ),
      ],
    );
  }
}

class _BarraPeriodo extends StatelessWidget {
  const _BarraPeriodo({required this.controller});

  final RelatoriosController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Período: ${controller.rotuloPeriodo}', style: subtituloRelatorio),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ChipPeriodoRelatorio(
                  rotulo: 'Mês atual',
                  ativo: controller.periodo == TipoPeriodoRelatorio.mesAtual,
                  onTap: () => controller.setPeriodo(TipoPeriodoRelatorio.mesAtual),
                ),
                const SizedBox(width: 8),
                ChipPeriodoRelatorio(
                  rotulo: 'Mês anterior',
                  ativo: controller.periodo == TipoPeriodoRelatorio.mesAnterior,
                  onTap: () => controller.setPeriodo(TipoPeriodoRelatorio.mesAnterior),
                ),
                const SizedBox(width: 8),
                ChipPeriodoRelatorio(
                  rotulo: 'Ano-safra',
                  ativo: controller.periodo == TipoPeriodoRelatorio.anoAgricola,
                  onTap: () => controller.setPeriodo(TipoPeriodoRelatorio.anoAgricola),
                ),
                const SizedBox(width: 8),
                ChipPeriodoRelatorio(
                  rotulo: 'Personalizado',
                  ativo: controller.periodo == TipoPeriodoRelatorio.personalizado,
                  onTap: () => _escolherDatas(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _escolherDatas(BuildContext context) async {
    final hoje = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final minimo = DateTime(hoje.year - 10);
    final maximo = DateTime(hoje.year + 2, 12, 31);

    DateTime _clamp(DateTime valor, DateTime ini, DateTime fim) {
      if (valor.isBefore(ini)) return ini;
      if (valor.isAfter(fim)) return fim;
      return valor;
    }

    final deInicial = _clamp(
      controller.dataDe ?? DateTime(hoje.year, hoje.month, 1),
      minimo,
      maximo,
    );
    final de = await showDatePicker(
      context: context,
      initialDate: deInicial,
      firstDate: minimo,
      lastDate: maximo,
      helpText: 'Data início',
    );
    if (de == null || !context.mounted) return;

    final ateInicial = _clamp(
      controller.dataAte ?? (hoje.isBefore(de) ? de : hoje),
      de,
      maximo,
    );
    final ate = await showDatePicker(
      context: context,
      initialDate: ateInicial,
      firstDate: de,
      lastDate: maximo,
      helpText: 'Data fim',
    );
    if (ate == null) return;
    controller.setDatas(de, ate);
    await controller.aplicarPeriodoPersonalizado();
  }
}

class _Detalhe extends StatelessWidget {
  const _Detalhe({
    required this.controller,
    required this.chave,
    required this.onExportar,
  });

  final RelatoriosController controller;
  final String chave;
  final VoidCallback onExportar;

  @override
  Widget build(BuildContext context) {
    final bloco = controller.lista.bloco(chave);
    final periodoApi = controller.lista.periodo;
    final inds = bloco?.indicadoresVisiveis ?? const {};
    final grafs = bloco?.graficosVisiveis ?? const {};
    final listas = bloco?.listasVisiveis ?? const {};

    return Column(
      children: [
        _BarraPeriodo(controller: controller),
        Expanded(
          child: controller.carregando && bloco == null
              ? const Center(child: CircularProgressIndicator(color: RelatorioCores.verde))
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  children: [
                    Text(bloco?.titulo ?? chave, style: tituloRelatorio),
                    const SizedBox(height: 2),
                    Text(bloco?.subtitulo ?? '', style: subtituloRelatorio),
                    if (periodoApi.rotulo.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(periodoApi.rotulo, style: subtituloRelatorio),
                    ],
                    if (controller.erro != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        controller.erro!,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 12,
                          color: Color(0xFFC62828),
                        ),
                      ),
                    ],
                    if (bloco == null) ...[
                      const SizedBox(height: 14),
                      const Text(
                        'Sem dados para este relatório.',
                        style: subtituloRelatorio,
                      ),
                    ] else ...[
                      if (inds.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        const Text('Resumo', style: tituloSecaoRelatorio),
                        const SizedBox(height: 8),
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          childAspectRatio: 1.35,
                          children: [
                            for (final entry in inds.entries)
                              CartaoKpiRelatorio(
                                titulo: rotuloIndicadorRelatorio(entry.key),
                                valor: entry.value,
                              ),
                          ],
                        ),
                      ],
                      for (final entry in grafs.entries) ...[
                        const SizedBox(height: 14),
                        SecaoCartoesRelatorio(
                          titulo: rotuloGraficoRelatorio(entry.key),
                          linhas: entry.value,
                        ),
                      ],
                      for (final entry in listas.entries) ...[
                        const SizedBox(height: 14),
                        SecaoCartoesRelatorio(
                          titulo: rotuloListaRelatorio(entry.key),
                          linhas: entry.value,
                        ),
                      ],
                      if (inds.isEmpty && grafs.isEmpty && listas.isEmpty) ...[
                        const SizedBox(height: 14),
                        const Text(
                          'API não retornou indicadores, gráficos nem listas neste período.',
                          style: subtituloRelatorio,
                        ),
                      ],
                      if (controller.lista.limitacoes.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        LimitacoesRelatorio(itens: controller.lista.limitacoes),
                      ],
                    ],
                  ],
                ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: BotaoExportarPdf(
              carregando: controller.exportando,
              onPressed: onExportar,
            ),
          ),
        ),
      ],
    );
  }
}
