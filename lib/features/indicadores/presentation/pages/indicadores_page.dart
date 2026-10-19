import 'package:costeira/core/api/api_client.dart';
import 'package:costeira/core/common/get_list/domain/usecases/get_list_usecase.dart';
import 'package:costeira/features/animals/domain/usecases/get_animal_lots_usecase.dart';
import 'package:costeira/features/fazendas/domain/usecases/resolve_current_farm_id.dart';
import 'package:costeira/features/indicadores/domain/indicador_valor.dart';
import 'package:costeira/features/indicadores/domain/indicadores_lista.dart';
import 'package:costeira/features/indicadores/infra/data/indicadores_datasource.dart';
import 'package:costeira/features/indicadores/presentation/indicadores_controller.dart';
import 'package:costeira/features/indicadores/presentation/widgets/indicador_ui.dart';
import 'package:costeira/features/potreiros/domain/usecases/get_potreiros_usecase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

enum IndicadorId {
  gmdGlobal,
  gmdLote,
  kgProduzido,
  lotacaoUa,
  lotacaoCab,
  rebanhoMedio,
  areaMedia,
}

class IndicadoresPage extends StatefulWidget {
  const IndicadoresPage({super.key});

  @override
  State<IndicadoresPage> createState() => _IndicadoresPageState();
}

class _IndicadoresPageState extends State<IndicadoresPage> {
  late final IndicadoresController controller;
  _Modulo? modulo;
  IndicadorId? indicador;

  @override
  void initState() {
    super.initState();
    controller = IndicadoresController(
      datasource: IndicadoresDatasource(Modular.get<ApiClient>()),
      getList: Modular.get<GetListUsecase>(),
      lotesUsecase: Modular.get<GetAnimalLotsUsecase>(),
      potreirosUsecase: Modular.get<GetPotreirosUsecase>(),
      fazenda: Modular.get<ResolveCurrentFarmId>(),
    );
    controller.addListener(_atualizar);
    controller.preparar();
  }

  void _atualizar() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    controller.removeListener(_atualizar);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final titulo = indicador != null
        ? _titulo(indicador!)
        : modulo?.titulo ?? 'Indicadores';
    return Scaffold(
      backgroundColor: IndicadorCores.fundo,
      appBar: AppBar(
        backgroundColor: IndicadorCores.fundo,
        foregroundColor: IndicadorCores.texto,
        elevation: 0,
        title: Text(titulo, style: tituloPagina),
        actions: [
          if (indicador != null) FiltrosIndicador(controller: controller),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (indicador != null) {
              setState(() => indicador = null);
              return;
            }
            if (modulo != null) {
              setState(() => modulo = null);
              return;
            }
            Modular.to.pop();
          },
        ),
      ),
      body: indicador != null
          ? _Detalhe(id: indicador!, controller: controller)
          : modulo != null
          ? _ListaModulo(
              modulo: modulo!,
              aoAbrir: (id) => setState(() => indicador = id),
            )
          : _ListaModulos(aoAbrir: (item) => setState(() => modulo = item)),
    );
  }
}

class _Modulo {
  const _Modulo({
    required this.titulo,
    required this.subtitulo,
    required this.aberto,
    required this.itens,
  });

  final String titulo;
  final String subtitulo;
  final bool aberto;
  final List<(IndicadorId, String)> itens;
}

const _modulos = [
  _Modulo(
    titulo: 'Produção e rebanho',
    subtitulo: 'GMD, quilos, lotação, rebanho e área',
    aberto: true,
    itens: [
      (IndicadorId.gmdGlobal, 'GMD global'),
      (IndicadorId.gmdLote, 'GMD por lote'),
      (IndicadorId.kgProduzido, 'Kg produzido'),
      (IndicadorId.lotacaoUa, 'Lotação UA/ha'),
      (IndicadorId.lotacaoCab, 'Lotação cab/ha'),
      (IndicadorId.rebanhoMedio, 'Rebanho médio'),
      (IndicadorId.areaMedia, 'Área média utilizada'),
    ],
  ),
  _Modulo(
    titulo: 'Reprodução',
    subtitulo: 'Em desenvolvimento',
    aberto: false,
    itens: [],
  ),
  _Modulo(
    titulo: 'Desfrute e saídas',
    subtitulo: 'Em desenvolvimento',
    aberto: false,
    itens: [],
  ),
  _Modulo(
    titulo: 'Financeiro',
    subtitulo: 'Em desenvolvimento',
    aberto: false,
    itens: [],
  ),
];

class _ListaModulos extends StatelessWidget {
  const _ListaModulos({required this.aoAbrir});

  final ValueChanged<_Modulo> aoAbrir;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: paddingIndicadores(context),
      itemCount: _modulos.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final modulo = _modulos[index];
        return Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          child: ListTile(
            title: Text(modulo.titulo, style: tituloLista),
            subtitle: Text(modulo.subtitulo, style: subtituloLista),
            trailing: Icon(
              modulo.aberto ? Icons.chevron_right : Icons.lock_outline,
              color: IndicadorCores.verde,
            ),
            onTap: modulo.aberto
                ? () => aoAbrir(modulo)
                : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Em desenvolvimento')),
                    );
                  },
          ),
        );
      },
    );
  }
}

class _ListaModulo extends StatelessWidget {
  const _ListaModulo({required this.modulo, required this.aoAbrir});

  final _Modulo modulo;
  final ValueChanged<IndicadorId> aoAbrir;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: paddingIndicadores(context),
      itemCount: modulo.itens.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = modulo.itens[index];
        return Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          child: ListTile(
            title: Text(item.$2, style: tituloLista),
            trailing: const Icon(Icons.chevron_right, color: IndicadorCores.verde),
            onTap: () => aoAbrir(item.$1),
          ),
        );
      },
    );
  }
}

String _titulo(IndicadorId id) {
  switch (id) {
    case IndicadorId.gmdGlobal:
      return 'GMD global';
    case IndicadorId.gmdLote:
      return 'Ganho médio diário por lote';
    case IndicadorId.kgProduzido:
      return 'Kg produzido';
    case IndicadorId.lotacaoUa:
      return 'Lotação UA/ha';
    case IndicadorId.lotacaoCab:
      return 'Lotação cab/ha';
    case IndicadorId.rebanhoMedio:
      return 'Rebanho médio';
    case IndicadorId.areaMedia:
      return 'Área média utilizada';
  }
}

class _Detalhe extends StatelessWidget {
  const _Detalhe({required this.id, required this.controller});

  final IndicadorId id;
  final IndicadoresController controller;

  @override
  Widget build(BuildContext context) {
    final lista = controller.lista;
    return ListView(
      padding: paddingIndicadores(context),
      children: [
        if (controller.carregando)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (controller.erro != null)
          CaixaNota(texto: controller.erro!)
        else
          ..._conteudo(id, lista),
      ],
    );
  }

  List<Widget> _conteudo(IndicadorId id, IndicadoresLista lista) {
    switch (id) {
      case IndicadorId.gmdGlobal:
        return _gmdGlobal(lista);
      case IndicadorId.gmdLote:
        return _gmdLote(lista);
      case IndicadorId.kgProduzido:
        return _kg(lista);
      case IndicadorId.lotacaoUa:
        return _ua(lista);
      case IndicadorId.lotacaoCab:
        return _cab(lista);
      case IndicadorId.rebanhoMedio:
        return _rebanho(lista);
      case IndicadorId.areaMedia:
        return _area(lista);
    }
  }
}

List<Widget> _gmdGlobal(IndicadoresLista lista) {
  final bloco = lista.gmdGlobal;
  final kg = lista.kgProduzido.valor('kg_produzido').qtd;
  final cabecas = lista.rebanhoMedio.valor('estoque_medio').qtd;
  final dias = lista.periodo.dias;
  final gmd = bloco.valor('gmd_global').qtd;
  final equacao = kg != null && cabecas != null && dias != null && gmd != null
      ? '${formatarNumero(kg)} kg ÷ ${formatarNumero(cabecas)} cab ÷ $dias dias = ${formatarNumero(gmd, casas: 3, fixo: true)} kg/dia'
      : null;
  return [
    GradeCartoes(
      cartoes: [
        CartaoIndicador(
          medicao: bloco.valor('gmd_global'),
          unidadePadrao: 'kg/dia',
          titulo: 'GMD global',
          legenda: 'Kg produzidos ÷ rebanho médio ÷ dias',
        ),
        CartaoIndicador(
          medicao: bloco.valor('gmd_pesagens'),
          unidadePadrao: 'kg/dia',
          titulo: 'GMD das pesagens',
          legenda: 'Apoio — média do ganho só dos lotes pesados',
        ),
        CartaoIndicador(
          medicao: bloco.valor('qtd_pesagens'),
          inteiro: true,
          titulo: 'Pesagens no período',
        ),
      ],
    ),
    const SizedBox(height: 12),
    CaixaNota(
      titulo: 'Como foi calculado',
      texto:
          'No sistema de cria, o peso dos terneiros entra no ganho.\n'
          'O GMD das pesagens é a soma do GMD dos lotes pesados dividida pelo número de pesagens, sem os nascimentos.'
          '${equacao == null ? '' : '\n$equacao'}',
    ),
    const SizedBox(height: 12),
    GraficoIndicador(
      titulo: 'GMD global — linha do tempo (acumulado no ano-safra)',
      pontos: [
        for (final item in bloco.serie('gmd_global'))
          PontoSerie('${item['nome_mes'] ?? ''}', numeroIndicador(item['gmd_global'])),
      ],
    ),
  ];
}

List<Widget> _gmdLote(IndicadoresLista lista) {
    final bloco = lista.gmdLote;
    final linhas = bloco.detalhamento;
    final serie = bloco.serie('gmd_lote').isNotEmpty
        ? bloco.serie('gmd_lote')
        : linhas;
  return [
    GradeCartoes(
      cartoes: [
        CartaoIndicador(
          medicao: bloco.valor('gmd_medio'),
          unidadePadrao: 'kg/d',
          titulo: 'GMD médio (kg/d)',
          legenda: 'Fazenda no período',
        ),
        CartaoIndicador(
          medicao: bloco.valor('lotes_com_gmd'),
          inteiro: true,
          titulo: 'Lotes com GMD',
          legenda: 'Calculados no período',
        ),
        CartaoIndicador(
          medicao: bloco.valor('pesagens'),
          inteiro: true,
          titulo: 'Pesagens',
          legenda: 'Registros utilizados',
        ),
      ],
    ),
    const SizedBox(height: 12),
    GraficoIndicador(
      titulo: 'GMD por lote',
      barras: true,
      pontos: [
        for (final item in serie)
          PontoSerie('${item['nome'] ?? ''}', numeroIndicador(item['gmd'])),
      ],
    ),
    const SizedBox(height: 12),
    TabelaIndicador(
      colunas: const ['Lote', 'Peso início', 'Peso fim', 'Dias', 'GMD'],
      linhas: [
        for (final item in linhas)
          [
            celula('${item['nome'] ?? '—'}'),
            celula(textoOuTraco(numeroIndicador(item['peso_inicio']), unidade: 'kg', casas: 1, fixo: true)),
            celula(textoOuTraco(numeroIndicador(item['peso_fim']), unidade: 'kg', casas: 1, fixo: true)),
            celula(textoOuTraco(numeroIndicador(item['dias']), casas: 0)),
            celula(textoOuTraco(numeroIndicador(item['gmd']), casas: 3, fixo: true)),
          ],
      ],
    ),
  ];
}

List<Widget> _kg(IndicadoresLista lista) {
  final bloco = lista.kgProduzido;
  final calculo = bloco.calculo;
  final estoque = numeroIndicador(calculo['estoque_atual']);
  final saidas = numeroIndicador(calculo['saidas']);
  final inventario = numeroIndicador(calculo['inventario_inicial']);
  final compras = numeroIndicador(calculo['compras_entradas']);
  final resultado = bloco.valor('kg_produzido').qtd;
  return [
    GradeCartoes(
      cartoes: [
        CartaoIndicador(
          medicao: bloco.valor('kg_produzido'),
          unidadePadrao: 'kg',
          titulo: 'Kg produzido',
        ),
        CartaoIndicador(
          medicao: bloco.valor('kg_hectare'),
          unidadePadrao: 'kg/ha',
          titulo: 'Kg por hectare',
        ),
        CartaoIndicador(
          medicao: bloco.valor('lotes_vencidos'),
          inteiro: true,
          titulo: 'Lotes vendidos',
        ),
        CartaoIndicador(
          medicao: bloco.valor('area_ativa'),
          unidadePadrao: 'ha',
          titulo: 'Área ativa',
        ),
      ],
    ),
    const SizedBox(height: 12),
    CaixaNota(
      titulo: 'Como foi calculado',
      texto:
          '${textoOuTraco(estoque)} + ${textoOuTraco(saidas)} − ${textoOuTraco(inventario)} − ${textoOuTraco(compras)} = ${textoOuTraco(resultado)} kg\n'
          'Nascimentos entram como quilo produzido, não como compra.',
    ),
    const SizedBox(height: 12),
    GraficoIndicador(
      titulo: 'Kg produzido acumulado',
      pontos: [
        for (final item in bloco.serie('kg_produzido'))
          PontoSerie('${item['nome_mes'] ?? ''}', numeroIndicador(item['kg_produzido'])),
      ],
    ),
    const SizedBox(height: 12),
    GraficoIndicador(
      titulo: 'Kg nascido no mês',
      barras: true,
      pontos: [
        for (final item in bloco.serie('kg_nascido_mes'))
          PontoSerie('${item['nome_mes'] ?? ''}', numeroIndicador(item['kg'])),
      ],
    ),
  ];
}

List<Widget> _ua(IndicadoresLista lista) {
  final bloco = lista.lotacao;
  final linhas = bloco.detalhamento;
  final serie = bloco.serie('lotacao_piquete').isNotEmpty
      ? bloco.serie('lotacao_piquete')
      : linhas;
  return [
    GradeCartoes(
      cartoes: [
        CartaoIndicador(
          medicao: bloco.valor('ua_ha_total'),
          unidadePadrao: 'UA/ha',
          titulo: 'UA/ha total',
          legenda: 'Só piquetes ativos',
        ),
        CartaoIndicador(
          medicao: bloco.valor('cabecas'),
          unidadePadrao: 'cab',
          inteiro: true,
          titulo: 'Cabeças',
        ),
        CartaoIndicador(
          medicao: bloco.valor('ua_total'),
          unidadePadrao: 'UA',
          titulo: 'UA total',
        ),
        CartaoIndicador(
          medicao: bloco.valor('area_total'),
          unidadePadrao: 'ha',
          titulo: 'Área total',
        ),
      ],
    ),
    const SizedBox(height: 12),
    GraficoIndicador(
      titulo: 'UA/ha por piquete',
      barras: true,
      pontos: [
        for (final item in serie)
          PontoSerie('${item['nome'] ?? ''}', numeroIndicador(item['ua_ha'])),
      ],
    ),
    const SizedBox(height: 12),
    CaixaNota(
      texto: 'Piquetes inativos ficam esmaecidos e não entram nos totais.',
    ),
    const SizedBox(height: 12),
    TabelaIndicador(
      colunas: const ['Piquete', 'Área', 'Cabeças', 'UA', 'UA/ha', 'Status'],
      esmaecer: (i) => !_ativo(linhas[i]['status']),
      linhas: [
        for (final item in linhas)
          [
            celula('${item['nome'] ?? '—'}'),
            celula(textoOuTraco(numeroIndicador(item['area']), unidade: 'ha')),
            celula(textoOuTraco(numeroIndicador(item['cabecas']), casas: 0)),
            celula(textoOuTraco(numeroIndicador(item['ua']))),
            celula(textoOuTraco(numeroIndicador(item['ua_ha']))),
            celula('${item['status'] ?? '—'}'),
          ],
      ],
    ),
  ];
}

List<Widget> _cab(IndicadoresLista lista) {
  final rebanho = lista.rebanhoMedio.valor('estoque_medio').qtd;
  final area = lista.areaMedia.valor('area_media').qtd;
  final resultado = rebanho != null && area != null && area != 0
      ? rebanho / area
      : null;
  final equacao = rebanho != null && area != null && resultado != null
      ? '${formatarNumero(rebanho)} cab ÷ ${formatarNumero(area)} ha = ${formatarNumero(resultado)} cab/ha'
      : null;
  return [
    GradeCartoes(
      cartoes: [
        CartaoIndicador(
          valor: resultado == null ? '—' : formatarNumero(resultado),
          unidade: resultado == null ? null : 'cab/ha',
          titulo: 'Lotação',
          legenda: 'Rebanho médio ÷ área média utilizada',
        ),
        CartaoIndicador(
          medicao: lista.rebanhoMedio.valor('estoque_medio'),
          unidadePadrao: 'cab',
          titulo: 'Rebanho médio',
        ),
        CartaoIndicador(
          medicao: lista.areaMedia.valor('area_media'),
          unidadePadrao: 'ha',
          titulo: 'Área média utilizada',
        ),
      ],
    ),
    if (equacao != null) ...[
      const SizedBox(height: 12),
      CaixaNota(texto: equacao),
    ],
  ];
}

List<Widget> _rebanho(IndicadoresLista lista) {
  final bloco = lista.rebanhoMedio;
  final linhas = bloco.detalhamento;
  return [
    GradeCartoes(
      cartoes: [
        CartaoIndicador(
          medicao: bloco.valor('estoque_medio'),
          unidadePadrao: 'cab',
          titulo: 'Estoque médio',
          legenda: 'Média no fim de cada mês',
        ),
        CartaoIndicador(
          medicao: bloco.valor('total_entradas'),
          inteiro: true,
          titulo: 'Entradas',
        ),
        CartaoIndicador(
          medicao: bloco.valor('total_saidas'),
          inteiro: true,
          titulo: 'Saídas',
        ),
        CartaoIndicador(
          medicao: bloco.valor('saldo'),
          inteiro: true,
          titulo: 'Saldo',
        ),
      ],
    ),
    const SizedBox(height: 12),
    GraficoIndicador(
      titulo: 'Evolução do estoque',
      pontos: [
        for (final item in bloco.serie('evolucao_estoque'))
          PontoSerie('${item['nome_mes'] ?? ''}', numeroIndicador(item['estoque'])),
      ],
    ),
    const SizedBox(height: 12),
    TabelaIndicador(
      colunas: const ['Mês', 'Entradas', 'Saídas', 'Estoque'],
      linhas: [
        for (final item in linhas)
          [
            celula('${item['nome_mes'] ?? '—'}'),
            celula(
              _comSinal(numeroIndicador(item['entradas']), positivo: true),
              cor: const Color(0xFF1E7A42),
            ),
            celula(
              _comSinal(numeroIndicador(item['saidas']), positivo: false),
              cor: const Color(0xFFB42318),
            ),
            celula(textoOuTraco(numeroIndicador(item['estoque']), casas: 0)),
          ],
      ],
    ),
  ];
}

List<Widget> _area(IndicadoresLista lista) {
  final bloco = lista.areaMedia;
  final safra = lista.periodo.safra;
  final linhas = bloco.detalhamento;
  return [
    GradeCartoes(
      cartoes: [
        CartaoIndicador(
          medicao: bloco.valor('area_media'),
          unidadePadrao: 'ha',
          titulo: 'Área média utilizada${safra.isEmpty ? '' : ' (ano agrícola)'}',
          legenda: safra.isEmpty
              ? 'Ponderada pelos dias ativo/inativo de cada piquete'
              : 'Ponderada pelos dias ativo/inativo de cada piquete no ano $safra',
        ),
        CartaoIndicador(
          medicao: bloco.valor('area_ativa'),
          unidadePadrao: 'ha',
          titulo: 'Área ativa agora',
          legenda: 'Soma dos piquetes marcados como ativo neste momento',
        ),
        CartaoIndicador(
          medicao: bloco.valor('area_ocupada'),
          unidadePadrao: 'ha',
          titulo: 'Área ocupada atual',
        ),
        CartaoIndicador(
          medicao: bloco.valor('area_total_cadastrada'),
          unidadePadrao: 'ha',
          titulo: 'Área total cadastrada',
        ),
        CartaoIndicador(
          medicao: bloco.valor('porcentagem_ocupacao'),
          unidadePadrao: '%',
          titulo: '% de ocupação',
        ),
      ],
    ),
    const SizedBox(height: 12),
    const CaixaNota(
      texto:
          'Em fazendas com integração lavoura-pecuária, marque um piquete como inativo quando ele sai de uso da pecuária. A área ativa agora passa a considerar só os piquetes ativos. A área média do ano agrícola pondera do dia 1º de julho até hoje, ou até o fim do ano, se ele já tiver terminado.',
    ),
    const SizedBox(height: 12),
    TabelaIndicador(
      colunas: const ['Piquete', 'Área', 'Lotes', 'Ocupação', 'Status'],
      esmaecer: (i) => !_ativo(linhas[i]['status']),
      linhas: [
        for (final item in linhas)
          [
            celula('${item['nome'] ?? '—'}'),
            celula(textoOuTraco(numeroIndicador(item['area']), unidade: 'ha')),
            celula(textoOuTraco(numeroIndicador(item['lotes']), casas: 0)),
            celula('${item['ocupacao'] ?? '—'}'),
            celula('${item['status'] ?? '—'}'),
          ],
      ],
    ),
  ];
}

bool _ativo(dynamic status) {
  return status?.toString().trim().toLowerCase() == 'ativo';
}

String _comSinal(num? valor, {required bool positivo}) {
  if (valor == null) {
    return '—';
  }
  final numero = formatarNumero(valor);
  if (valor == 0) {
    return '0';
  }
  return positivo ? '+$numero' : '−$numero';
}
