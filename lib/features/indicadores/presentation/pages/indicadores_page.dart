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
  taxaDesfrute,
  taxaAbate,
  taxaGiro,
  mortalidade,
  taxaPrenhez,
  taxaNatalidade,
  taxaDesmame,
  pesoDesmame,
  kgVacaExposta,
  taxaAborto,
  intervaloEntrePartos,
  histogramaParicao,
  merma,
  custoPorCabeca,
  custoPorKgProduzido,
  resultadoPorHectare,
  margemLiquida,
  percentualCustoFixo,
  percentualCustoVariavel,
  resultadoPatrimonio,
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
    subtitulo: 'Prenhez, natalidade, desmame e parição',
    aberto: true,
    itens: [
      (IndicadorId.taxaPrenhez, 'Taxa de prenhez'),
      (IndicadorId.taxaNatalidade, 'Taxa de natalidade'),
      (IndicadorId.taxaDesmame, 'Taxa de desmame'),
      (IndicadorId.pesoDesmame, 'Peso ao desmame'),
      (IndicadorId.kgVacaExposta, 'Kg/vaca exposta'),
      (IndicadorId.taxaAborto, 'Taxa de aborto'),
      (IndicadorId.intervaloEntrePartos, 'Intervalo entre partos'),
      (IndicadorId.histogramaParicao, 'Histograma de parição'),
      (IndicadorId.merma, 'Merma'),
    ],
  ),
  _Modulo(
    titulo: 'Desfrute e saídas',
    subtitulo: 'Desfrute, abate, giro e mortalidade',
    aberto: true,
    itens: [
      (IndicadorId.taxaDesfrute, 'Taxa de desfrute'),
      (IndicadorId.taxaAbate, 'Taxa de abate'),
      (IndicadorId.taxaGiro, 'Taxa de giro'),
      (IndicadorId.mortalidade, 'Mortalidade'),
    ],
  ),
  _Modulo(
    titulo: 'Financeiro',
    subtitulo: 'Custos, margem e resultado',
    aberto: true,
    itens: [
      (IndicadorId.custoPorCabeca, 'Custo por cabeça'),
      (IndicadorId.custoPorKgProduzido, 'Custo por kg produzido'),
      (IndicadorId.resultadoPorHectare, 'Resultado por hectare'),
      (IndicadorId.margemLiquida, 'Margem líquida'),
      (IndicadorId.percentualCustoFixo, '% Custo fixo'),
      (IndicadorId.percentualCustoVariavel, '% Custo variável'),
      (IndicadorId.resultadoPatrimonio, 'Resultado sobre patrimônio'),
    ],
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
    case IndicadorId.taxaDesfrute:
      return 'Taxa de desfrute';
    case IndicadorId.taxaAbate:
      return 'Taxa de abate';
    case IndicadorId.taxaGiro:
      return 'Taxa de giro';
    case IndicadorId.mortalidade:
      return 'Mortalidade';
    case IndicadorId.taxaPrenhez:
      return 'Taxa de prenhez';
    case IndicadorId.taxaNatalidade:
      return 'Taxa de natalidade';
    case IndicadorId.taxaDesmame:
      return 'Taxa de desmame';
    case IndicadorId.pesoDesmame:
      return 'Peso ao desmame';
    case IndicadorId.kgVacaExposta:
      return 'Kg/vaca exposta';
    case IndicadorId.taxaAborto:
      return 'Taxa de aborto';
    case IndicadorId.intervaloEntrePartos:
      return 'Intervalo entre partos';
    case IndicadorId.histogramaParicao:
      return 'Histograma de parição';
    case IndicadorId.merma:
      return 'Merma';
    case IndicadorId.custoPorCabeca:
      return 'Custo por cabeça';
    case IndicadorId.custoPorKgProduzido:
      return 'Custo por kg produzido';
    case IndicadorId.resultadoPorHectare:
      return 'Resultado por hectare';
    case IndicadorId.margemLiquida:
      return 'Margem líquida';
    case IndicadorId.percentualCustoFixo:
      return '% Custo fixo';
    case IndicadorId.percentualCustoVariavel:
      return '% Custo variável';
    case IndicadorId.resultadoPatrimonio:
      return 'Resultado sobre patrimônio';
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
      case IndicadorId.taxaDesfrute:
        return _desfrute(lista);
      case IndicadorId.taxaAbate:
        return _abate(lista);
      case IndicadorId.taxaGiro:
        return _giro(lista);
      case IndicadorId.mortalidade:
        return _mortalidade(lista);
      case IndicadorId.taxaPrenhez:
        return _reproTaxa(
          lista,
          bloco: lista.taxaPrenhez,
          titulo: 'Taxa de prenhez',
          unidade: '%',
          legenda: 'Prenhas ÷ acasaladas',
        );
      case IndicadorId.taxaNatalidade:
        return _reproTaxa(
          lista,
          bloco: lista.taxaNatalidade,
          titulo: 'Taxa de natalidade',
          unidade: '%',
          legenda: 'Crias vivas ÷ acasaladas',
        );
      case IndicadorId.taxaDesmame:
        return _reproTaxa(
          lista,
          bloco: lista.taxaDesmame,
          titulo: 'Taxa de desmame',
          unidade: '%',
          legenda: 'Desmamados ÷ acasaladas',
        );
      case IndicadorId.pesoDesmame:
        return _reproTaxa(
          lista,
          bloco: lista.pesoDesmame,
          titulo: 'Peso ao desmame',
          unidade: 'kg',
          legenda: 'Média dos pesos de desmame',
        );
      case IndicadorId.kgVacaExposta:
        return _reproTaxa(
          lista,
          bloco: lista.kgVacaExposta,
          titulo: 'Kg/vaca exposta',
          unidade: 'kg/vaca',
        );
      case IndicadorId.taxaAborto:
        return _reproTaxa(
          lista,
          bloco: lista.taxaAborto,
          titulo: 'Taxa de aborto',
          unidade: '%',
          legenda: 'Abortadas ÷ diagnosticadas prenhas',
        );
      case IndicadorId.intervaloEntrePartos:
        return _reproTaxa(
          lista,
          bloco: lista.intervaloEntrePartos,
          titulo: 'Intervalo entre partos',
          unidade: 'dias',
        );
      case IndicadorId.histogramaParicao:
        return _histogramaParicao(lista);
      case IndicadorId.merma:
        return _reproTaxa(
          lista,
          bloco: lista.merma,
          titulo: 'Merma',
          unidade: '%',
          legenda: 'Perdas ÷ diagnosticadas prenhas',
        );
      case IndicadorId.custoPorCabeca:
        return _finCustoCabeca(lista);
      case IndicadorId.custoPorKgProduzido:
        return _finCustoKg(lista);
      case IndicadorId.resultadoPorHectare:
        return _finResultadoHa(lista);
      case IndicadorId.margemLiquida:
        return _finMargemLiquida(lista);
      case IndicadorId.percentualCustoFixo:
        return _finPctFixo(lista);
      case IndicadorId.percentualCustoVariavel:
        return _finPctVariavel(lista);
      case IndicadorId.resultadoPatrimonio:
        return _finPatrimonio(lista);
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
    ListaCardsIndicador(
      titulo: 'Lotes',
      itens: [
        for (final item in linhas)
          ItemCardIndicador(
            titulo: '${item['nome'] ?? '—'}',
            campos: [
              CampoCardIndicador(
                'Peso início',
                textoOuTraco(
                  numeroIndicador(item['peso_inicio']),
                  unidade: 'kg',
                  casas: 1,
                  fixo: true,
                ),
              ),
              CampoCardIndicador(
                'Peso fim',
                textoOuTraco(
                  numeroIndicador(item['peso_fim']),
                  unidade: 'kg',
                  casas: 1,
                  fixo: true,
                ),
              ),
              CampoCardIndicador(
                'Dias',
                textoOuTraco(numeroIndicador(item['dias']), casas: 0),
              ),
              CampoCardIndicador(
                'GMD',
                textoOuTraco(
                  numeroIndicador(item['gmd']),
                  casas: 3,
                  fixo: true,
                ),
              ),
            ],
          ),
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
    ListaCardsIndicador(
      titulo: 'Piquetes',
      itens: [
        for (final item in linhas)
          ItemCardIndicador(
            titulo: '${item['nome'] ?? '—'}',
            selo: '${item['status'] ?? ''}',
            esmaecido: !_ativo(item['status']),
            campos: [
              CampoCardIndicador(
                'Área',
                textoOuTraco(numeroIndicador(item['area']), unidade: 'ha'),
              ),
              CampoCardIndicador(
                'Cabeças',
                textoOuTraco(numeroIndicador(item['cabecas']), casas: 0),
              ),
              CampoCardIndicador(
                'UA',
                textoOuTraco(numeroIndicador(item['ua'])),
              ),
              CampoCardIndicador(
                'UA/ha',
                textoOuTraco(numeroIndicador(item['ua_ha'])),
              ),
            ],
          ),
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
    ListaCardsIndicador(
      titulo: 'Movimento mensal',
      itens: [
        for (final item in linhas)
          ItemCardIndicador(
            titulo: '${item['nome_mes'] ?? '—'}',
            campos: [
              CampoCardIndicador(
                'Entradas',
                _comSinal(numeroIndicador(item['entradas']), positivo: true),
                cor: const Color(0xFF1E7A42),
              ),
              CampoCardIndicador(
                'Saídas',
                _comSinal(numeroIndicador(item['saidas']), positivo: false),
                cor: const Color(0xFFB42318),
              ),
              CampoCardIndicador(
                'Estoque',
                textoOuTraco(numeroIndicador(item['estoque']), casas: 0),
              ),
            ],
          ),
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
    ListaCardsIndicador(
      titulo: 'Piquetes',
      itens: [
        for (final item in linhas)
          ItemCardIndicador(
            titulo: '${item['nome'] ?? '—'}',
            selo: '${item['status'] ?? ''}',
            esmaecido: !_ativo(item['status']),
            campos: [
              CampoCardIndicador(
                'Área',
                textoOuTraco(numeroIndicador(item['area']), unidade: 'ha'),
              ),
              CampoCardIndicador(
                'Lotes',
                textoOuTraco(numeroIndicador(item['lotes']), casas: 0),
              ),
              CampoCardIndicador(
                'Ocupação',
                '${item['ocupacao'] ?? '—'}',
              ),
            ],
          ),
      ],
    ),
  ];
}

List<Widget> _desfrute(IndicadoresLista lista) {
  final bloco = lista.taxaDesfrute;
  final linhas = bloco.detalhamento;
  return [
    GradeCartoes(
      cartoes: [
        CartaoIndicador(
          medicao: bloco.valor('taxa_desfrute'),
          unidadePadrao: '%',
          titulo: 'Desfrute',
          ajuda:
              'Fórmula: kg produzido ÷ kg inventário inicial.\n\n'
              'Quanto, em peso, a fazenda produziu (nasceu/engordou/saiu) em relação ao peso do rebanho com que o ano agrícola começou.\n\n'
              'Mesmo cálculo do “Kg produzido”: estoque atual + saídas − inventário inicial − compras.',
        ),
        CartaoIndicador(
          medicao: bloco.valor('kg_produzido'),
          unidadePadrao: 'kg',
          titulo: 'Kg produzido',
          ajuda: 'Peso produzido no período (estoque atual + saídas − inventário inicial − compras).',
        ),
        CartaoIndicador(
          medicao: bloco.valor('kg_inventario_inicial'),
          unidadePadrao: 'kg',
          titulo: 'Kg inventário',
          ajuda: 'Peso do rebanho no início do ano agrícola (base da taxa de desfrute).',
        ),
      ],
    ),
    const SizedBox(height: 12),
    ListaCardsIndicador(
      titulo: 'Saídas (venda/morte) no período',
      vazio: 'Sem saídas no período',
      itens: [
        for (final item in linhas)
          ItemCardIndicador(
            titulo: _campo(item, const ['categoria', 'nome_categoria']),
            subtitulo: _campo(item, const ['lote', 'nome_lote']),
            selo: _campo(item, const ['tipo']),
            campos: [
              CampoCardIndicador(
                'Data',
                _campo(item, const ['data', 'data_vinculo']),
              ),
              CampoCardIndicador(
                'Qtd',
                textoOuTraco(
                  numeroIndicador(item['qtd'] ?? item['quantidade']),
                  casas: 0,
                ),
              ),
              CampoCardIndicador(
                'Peso',
                textoOuTraco(
                  numeroIndicador(item['peso'] ?? item['peso_total']),
                  unidade: 'kg',
                ),
              ),
            ],
          ),
      ],
    ),
  ];
}

List<Widget> _abate(IndicadoresLista lista) {
  final bloco = lista.taxaAbate;
  final vendidos = bloco.valor('kg_vendidos');
  final estoque = bloco.valor('kg_estoque_inicial');
  final equacao = _equacao(
    esquerda: vendidos,
    esquerdaUnidade: 'kg',
    esquerdaRotulo: 'vendidos',
    direita: estoque,
    direitaUnidade: 'kg',
    direitaRotulo: 'do estoque inicial',
  );
  return [
    GradeCartoes(
      cartoes: [
        CartaoIndicador(
          medicao: bloco.valor('taxa_abate'),
          unidadePadrao: '%',
          titulo: 'Abate',
          ajuda: [
            'Fórmula: kg vendidos ÷ kg estoque inicial.',
            if (equacao != null) 'Neste período: $equacao',
          ].join('\n\n'),
        ),
        CartaoIndicador(
          medicao: vendidos,
          unidadePadrao: 'kg',
          titulo: 'Kg vendidos',
          ajuda: 'Soma do peso das vendas no período.',
        ),
        CartaoIndicador(
          medicao: estoque,
          unidadePadrao: 'kg',
          titulo: 'Kg estoque',
          ajuda: 'Peso do estoque inicial usado no cálculo da taxa de abate.',
        ),
      ],
    ),
  ];
}

List<Widget> _giro(IndicadoresLista lista) {
  final bloco = lista.taxaGiro;
  final vendidas = bloco.valor('cabecas_vendidas');
  final estoque = bloco.valor('estoque_inicial');
  final equacao = _equacao(
    esquerda: vendidas,
    esquerdaUnidade: 'cab',
    esquerdaRotulo: 'vendidas',
    direita: estoque,
    direitaUnidade: 'cab',
    direitaRotulo: 'do estoque inicial',
  );
  return [
    GradeCartoes(
      cartoes: [
        CartaoIndicador(
          medicao: bloco.valor('taxa_giro'),
          unidadePadrao: '%',
          titulo: 'Giro',
          ajuda: [
            'Fórmula: cabeças vendidas ÷ estoque inicial.',
            if (equacao != null) 'Neste período: $equacao',
          ].join('\n\n'),
        ),
        CartaoIndicador(
          medicao: vendidas,
          unidadePadrao: 'cab',
          titulo: 'Vendidas',
          ajuda: 'Quantidade de cabeças vendidas no período.',
        ),
        CartaoIndicador(
          medicao: estoque,
          unidadePadrao: 'cab',
          titulo: 'Estoque inicial',
          ajuda: 'Cabeças no estoque inicial usadas no cálculo da taxa de giro.',
        ),
      ],
    ),
  ];
}

List<Widget> _mortalidade(IndicadoresLista lista) {
  final bloco = lista.mortalidade;
  final meses = bloco.mesesEstoqueMedio;
  final linhas = bloco.detalhamento;
  final serie = bloco.serie('mortalidade_categoria');
  return [
    GradeCartoes(
      cartoes: [
        CartaoIndicador(
          medicao: bloco.valor('taxa_mortalidade'),
          unidadePadrao: '%',
          titulo: 'Mortalidade',
          ajuda: 'Fórmula: (mortes + abigeato) ÷ estoque médio.',
        ),
        CartaoIndicador(
          medicao: bloco.valor('animais_perdidos'),
          inteiro: true,
          titulo: 'Perdidos',
          ajuda: 'Soma de mortes e abigeatos no período.',
        ),
        CartaoIndicador(
          medicao: bloco.valor('estoque_medio'),
          inteiro: true,
          titulo: 'Estoque médio',
          ajuda: meses == null
              ? 'Média mensal do estoque no período.'
              : 'Média mensal do estoque no período ($meses mês(es)).',
        ),
      ],
    ),
    const SizedBox(height: 12),
    GraficoIndicador(
      titulo: 'Mortalidade por categoria',
      barras: true,
      pontos: [
        for (final item in serie)
          PontoSerie(
            _campo(item, const ['nome', 'categoria', 'nome_categoria']),
            numeroIndicador(
              item['qtd'] ?? item['mortes'] ?? item['valor'] ?? item['quantidade'],
            ),
          ),
      ],
    ),
    const SizedBox(height: 12),
    ListaCardsIndicador(
      titulo: 'Registros',
      vazio: 'Nenhuma morte registrada no período',
      itens: [
        for (final item in linhas)
          ItemCardIndicador(
            titulo: _campo(item, const ['categoria', 'nome_categoria']),
            subtitulo: _campo(item, const ['lote', 'nome_lote']),
            selo: _campo(item, const ['tipo']),
            campos: [
              CampoCardIndicador(
                'Data',
                _campo(item, const ['data', 'data_vinculo']),
              ),
              CampoCardIndicador(
                'Qtd',
                textoOuTraco(
                  numeroIndicador(item['quantidade'] ?? item['qtd']),
                  casas: 0,
                ),
              ),
            ],
          ),
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

String _campo(Map<String, dynamic> item, List<String> chaves) {
  for (final chave in chaves) {
    final valor = item[chave];
    if (valor == null) {
      continue;
    }
    if (valor is Map) {
      final nome = valor['nome']?.toString().trim();
      if (nome != null && nome.isNotEmpty) {
        return nome;
      }
    }
    final texto = valor.toString().trim();
    if (texto.isNotEmpty && texto != 'null') {
      return texto;
    }
  }
  return '—';
}

String? _equacao({
  required IndicadorValor esquerda,
  required String esquerdaUnidade,
  required String esquerdaRotulo,
  required IndicadorValor direita,
  required String direitaUnidade,
  required String direitaRotulo,
}) {
  if (esquerda.qtd == null || direita.qtd == null) {
    return null;
  }
  final esq = esquerda.partes(unidadePadrao: esquerdaUnidade);
  final dir = direita.partes(unidadePadrao: direitaUnidade);
  return '${esq.numero} ${esq.unidade ?? esquerdaUnidade} $esquerdaRotulo ÷ ${dir.numero} ${dir.unidade ?? direitaUnidade} $direitaRotulo.';
}

List<Widget> _reproTaxa(
  IndicadoresLista lista, {
  required IndicadorBloco bloco,
  required String titulo,
  required String unidade,
  String? legenda,
}) {
  final listaDetalhe = _listaDetalhamentoRepro(bloco);
  return [
    ..._avisosReproducao(lista.reproducaoMeta),
    GradeCartoes(
      cartoes: [
        CartaoIndicador(
          medicao: bloco.valorPrincipal,
          unidadePadrao: unidade,
          titulo: titulo,
          ajuda: legenda,
        ),
        ..._cartoesDetalheRepro(bloco.detalheCampos),
      ],
    ),
    if (listaDetalhe.isNotEmpty) ...[
      const SizedBox(height: 12),
      ListaCardsIndicador(
        titulo: 'Detalhamento',
        itens: listaDetalhe,
      ),
    ],
  ];
}

List<Widget> _histogramaParicao(IndicadoresLista lista) {
  final bloco = lista.histogramaParicao;
  final serie = bloco.serie('nascimentos_mes');
  final listaDetalhe = _listaDetalhamentoRepro(bloco);
  return [
    ..._avisosReproducao(lista.reproducaoMeta),
    GradeCartoes(
      cartoes: [
        CartaoIndicador(
          medicao: bloco.valorPrincipal,
          unidadePadrao: 'cab.',
          titulo: 'Nascimentos no período',
          ajuda: 'Total no histograma',
        ),
        ..._cartoesDetalheRepro(bloco.detalheCampos),
      ],
    ),
    const SizedBox(height: 12),
    GraficoIndicador(
      titulo: 'Nascimentos por mês',
      barras: true,
      pontos: [
        for (final item in serie)
          PontoSerie(
            _rotuloMesRepro(item['mes']?.toString() ?? item['nome_mes']?.toString()),
            numeroIndicador(item['quantidade'] ?? item['qtd']),
          ),
      ],
    ),
    if (listaDetalhe.isNotEmpty) ...[
      const SizedBox(height: 12),
      ListaCardsIndicador(
        titulo: 'Detalhamento',
        itens: listaDetalhe,
      ),
    ],
  ];
}

List<Widget> _avisosReproducao(ReproducaoMetadados meta) {
  if (!meta.temAviso) {
    return const [];
  }
  final pendencias = <String>[
    for (final item in meta.pendencias)
      if ((item['msg']?.toString() ?? '').trim().isNotEmpty)
        '${item['brinco'] != null && item['brinco'].toString().trim().isNotEmpty ? 'Brinco ${item['brinco']}: ' : ''}${item['msg']}',
  ];
  if (!meta.parcial && pendencias.isEmpty && meta.limitacoes.isEmpty) {
    return const [];
  }
  return [
    CaixaNota(
      titulo: 'Atenção',
      compacta: true,
      texto: '',
      parcial: meta.parcial,
      pendencias: pendencias,
      limitacoes: meta.limitacoes,
    ),
    const SizedBox(height: 12),
  ];
}

List<CartaoIndicador> _cartoesDetalheRepro(Map<String, dynamic> mapa) {
  final saida = <CartaoIndicador>[];
  for (final entry in mapa.entries) {
    final chave = entry.key;
    final valor = entry.value;
    if (valor is List) {
      if (valor.isEmpty) {
        continue;
      }
      saida.add(
        CartaoIndicador(
          valor: '${valor.length}',
          titulo: _rotuloCampoRepro(chave),
          inteiro: true,
        ),
      );
      continue;
    }
    if (valor is bool) {
      saida.add(
        CartaoIndicador(
          valor: valor ? 'Sim' : 'Não',
          titulo: _rotuloCampoRepro(chave),
        ),
      );
      continue;
    }
    if (valor is Map) {
      final medicao = IndicadorValor.de(valor);
      if (medicao.texto != null || medicao.qtd != null) {
        saida.add(
          CartaoIndicador(
            medicao: medicao,
            inteiro: medicao.qtd != null && medicao.qtd! % 1 == 0,
            titulo: _rotuloCampoRepro(chave),
          ),
        );
      }
      continue;
    }
    if (valor is String) {
      final texto = valor.trim();
      if (texto.isEmpty) {
        continue;
      }
      saida.add(
        CartaoIndicador(
          valor: texto,
          titulo: _rotuloCampoRepro(chave),
        ),
      );
      continue;
    }
    final numero = numeroIndicador(valor);
    if (numero != null) {
      saida.add(
        CartaoIndicador(
          medicao: IndicadorValor(qtd: numero),
          inteiro: numero % 1 == 0,
          titulo: _rotuloCampoRepro(chave),
        ),
      );
    }
  }
  return saida;
}

/// Lista (array) no detalhamento → cards; mapa fica em [_cartoesDetalheRepro].
List<ItemCardIndicador> _listaDetalhamentoRepro(IndicadorBloco bloco) {
  final linhas = bloco.detalhamento;
  if (linhas.isEmpty) {
    return const [];
  }
  return [
    for (final item in linhas)
      ItemCardIndicador(
        titulo: _tituloLinhaRepro(item),
        campos: [
          for (final entry in item.entries)
            if (entry.key != 'nome' &&
                entry.key != 'titulo' &&
                entry.key != 'brinco' &&
                entry.key != 'id')
              CampoCardIndicador(
                _rotuloCampoRepro(entry.key),
                _textoCampoRepro(entry.value),
              ),
        ],
      ),
  ];
}

String _tituloLinhaRepro(Map<String, dynamic> item) {
  for (final chave in ['nome', 'titulo', 'brinco']) {
    final valor = item[chave]?.toString().trim();
    if (valor != null && valor.isNotEmpty) {
      return chave == 'brinco' ? 'Brinco $valor' : valor;
    }
  }
  final id = item['id'];
  if (id != null) {
    return 'Registro $id';
  }
  return 'Registro';
}

String _textoCampoRepro(dynamic valor) {
  if (valor == null) {
    return '—';
  }
  if (valor is bool) {
    return valor ? 'Sim' : 'Não';
  }
  if (valor is Map) {
    final medicao = IndicadorValor.de(valor);
    return medicao.temValor ? medicao.exibir() : '—';
  }
  if (valor is List) {
    return valor.isEmpty ? '—' : '${valor.length}';
  }
  final texto = valor.toString().trim();
  if (texto.isEmpty || texto.toLowerCase() == 'null') {
    return '—';
  }
  return texto;
}

String _rotuloCampoRepro(String chave) {
  return switch (chave) {
    'prenhas' => 'Prenhas',
    'acasaladas' => 'Acasaladas',
    'matrizes_com_cria_viva' => 'Matrizes com cria viva',
    'nascimentos' => 'Nascimentos',
    'natimortos' => 'Natimortos',
    'em_observacao_24h' => 'Em observação 24h',
    'horario_indisponivel' => 'Horário indisponível',
    'desmamados' => 'Desmamados',
    'sem_pesagem' => 'Sem pesagem',
    'abortadas' => 'Abortadas',
    'diagnosticadas_prenhas' => 'Diagnosticadas prenhas',
    'intervalos' => 'Intervalos',
    'temporadas_ambiguas' => 'Temporadas ambíguas',
    'perdas' => 'Perdas',
    'matrizes' => 'Matrizes',
    _ => chave.replaceAll('_', ' '),
  };
}

String _rotuloMesRepro(String? mes) {
  final texto = (mes ?? '').trim();
  if (texto.isEmpty) {
    return '—';
  }
  final match = RegExp(r'^(\d{4})-(\d{2})').firstMatch(texto);
  if (match != null) {
    const nomes = {
      '01': 'Jan',
      '02': 'Fev',
      '03': 'Mar',
      '04': 'Abr',
      '05': 'Mai',
      '06': 'Jun',
      '07': 'Jul',
      '08': 'Ago',
      '09': 'Set',
      '10': 'Out',
      '11': 'Nov',
      '12': 'Dez',
    };
    return nomes[match.group(2)!] ?? match.group(2)!;
  }
  return texto;
}

List<Widget> _finCustoCabeca(IndicadoresLista lista) {
  final bloco = lista.custoPorCabeca;
  return _finBloco(
    bloco: bloco,
    cartoes: [
      CartaoIndicador(
        medicao: bloco.valor('desembolso_cabeca_mes'),
        unidadePadrao: 'R\$',
        titulo: 'Desembolso por cabeça / mês',
        ajuda: '(CF + CV) ÷ rebanho médio ÷ meses',
      ),
      CartaoIndicador(
        medicao: bloco.valor('custo_producao_cabeca'),
        unidadePadrao: 'R\$',
        titulo: 'Custo de produção / cabeça',
        ajuda: '(CF + CV + Investimento) ÷ rebanho médio',
      ),
      CartaoIndicador(
        medicao: bloco.valor('rebanho_medio'),
        unidadePadrao: 'cab',
        titulo: 'Rebanho médio',
      ),
    ],
    tituloGrafico: 'Desembolso por cabeça / mês',
    chaveSerie: 'desembolso_cabeca_mes',
    chaveValorSerie: 'valor',
  );
}

List<Widget> _finCustoKg(IndicadoresLista lista) {
  final bloco = lista.custoPorKgProduzido;
  return _finBloco(
    bloco: bloco,
    cartoes: [
      CartaoIndicador(
        medicao: bloco.valor('custo_kg'),
        unidadePadrao: 'R\$',
        titulo: 'Custo por kg produzido',
        ajuda: '(CF + CV) ÷ kg produzidos; exclui compra de animais, juros e investimentos',
      ),
      CartaoIndicador(
        medicao: bloco.valor('kg_produzido'),
        unidadePadrao: 'kg',
        titulo: 'Kg produzidos',
      ),
      CartaoIndicador(
        medicao: bloco.valor('custo_producao'),
        unidadePadrao: 'R\$',
        titulo: 'Custo de produção',
        ajuda: 'CF + CV',
      ),
    ],
    tituloGrafico: 'Custo por kg produzido',
    chaveSerie: 'custo_kg',
    chaveValorSerie: 'valor',
  );
}

List<Widget> _finResultadoHa(IndicadoresLista lista) {
  final bloco = lista.resultadoOperacaoHectare;
  return _finBloco(
    bloco: bloco,
    cartoes: [
      CartaoIndicador(
        medicao: bloco.valor('resultado_hectare'),
        unidadePadrao: 'R\$',
        titulo: 'Resultado por hectare',
        ajuda: 'Resultado da operação ÷ área pastoril média',
      ),
      CartaoIndicador(
        medicao: bloco.valor('resultado_operacao'),
        unidadePadrao: 'R\$',
        titulo: 'Resultado do período',
      ),
      CartaoIndicador(
        medicao: bloco.valor('area_media'),
        unidadePadrao: 'ha',
        titulo: 'Área',
      ),
    ],
  );
}

List<Widget> _finMargemLiquida(IndicadoresLista lista) {
  final bloco = lista.resultadoOperacao;
  final resultado = bloco.valor('resultado_operacao');
  final receita = bloco.valor('valor_producao');
  final margem = _margemLiquidaPct(resultado, receita);
  return _finBloco(
    bloco: bloco,
    cartoes: [
      CartaoIndicador(
        medicao: margem,
        unidadePadrao: '%',
        titulo: 'Margem líquida',
        ajuda: 'Resultado ÷ receita (valor da produção)',
      ),
      CartaoIndicador(
        medicao: receita,
        unidadePadrao: 'R\$',
        titulo: 'Receita',
        ajuda: 'Valor da produção no período',
      ),
      CartaoIndicador(
        medicao: resultado,
        unidadePadrao: 'R\$',
        titulo: 'Resultado',
      ),
    ],
  );
}

List<Widget> _finPctFixo(IndicadoresLista lista) {
  final bloco = lista.percentualCustoFixo;
  return _finBloco(
    bloco: bloco,
    cartoes: [
      CartaoIndicador(
        medicao: bloco.valor('percentual_custo_fixo'),
        unidadePadrao: '%',
        titulo: '% Custo fixo',
        ajuda: 'CF ÷ (CF + CV) × 100',
      ),
      CartaoIndicador(
        medicao: bloco.valor('custo_fixo'),
        unidadePadrao: 'R\$',
        titulo: 'Custo fixo',
      ),
      CartaoIndicador(
        medicao: bloco.valor('custo_total'),
        unidadePadrao: 'R\$',
        titulo: 'Custo total',
      ),
    ],
  );
}

List<Widget> _finPctVariavel(IndicadoresLista lista) {
  final bloco = lista.percentualCustoVariavel;
  return _finBloco(
    bloco: bloco,
    cartoes: [
      CartaoIndicador(
        medicao: bloco.valor('percentual_custo_variavel'),
        unidadePadrao: '%',
        titulo: '% Custo variável',
        ajuda: 'CV ÷ (CF + CV) × 100',
      ),
      CartaoIndicador(
        medicao: bloco.valor('custo_variavel'),
        unidadePadrao: 'R\$',
        titulo: 'Custo variável',
      ),
      CartaoIndicador(
        medicao: bloco.valor('custo_total'),
        unidadePadrao: 'R\$',
        titulo: 'Custo total',
      ),
    ],
  );
}

List<Widget> _finPatrimonio(IndicadoresLista lista) {
  final bloco = lista.resultadoPatrimonio;
  return _finBloco(
    bloco: bloco,
    cartoes: [
      CartaoIndicador(
        medicao: bloco.valor('resultado_patrimonio'),
        unidadePadrao: '%',
        titulo: 'Resultado sobre patrimônio',
        ajuda: 'Resultado ÷ (terra + rebanho + máquinas)',
      ),
      CartaoIndicador(
        medicao: bloco.valor('patrimonio_total'),
        unidadePadrao: 'R\$',
        titulo: 'Patrimônio total',
        ajuda: 'Terra + rebanho + máquinas',
      ),
      CartaoIndicador(
        medicao: bloco.valor('resultado_periodo'),
        unidadePadrao: 'R\$',
        titulo: 'Resultado do período',
      ),
    ],
  );
}

IndicadorValor _margemLiquidaPct(IndicadorValor resultado, IndicadorValor receita) {
  final r = resultado.qtd;
  final v = receita.qtd;
  if (r == null || v == null || v == 0) {
    return IndicadorValor.vazio;
  }
  final pct = (r / v) * 100;
  return IndicadorValor(
    qtd: pct,
    unidade: '%',
    texto: '${formatarNumero(pct, casas: 1, fixo: true)}%',
  );
}

List<Widget> _finBloco({
  required IndicadorBloco bloco,
  required List<CartaoIndicador> cartoes,
  String? tituloGrafico,
  String? chaveSerie,
  String chaveValorSerie = 'valor',
}) {
  final serie = (chaveSerie == null || chaveSerie.isEmpty)
      ? const <Map<String, dynamic>>[]
      : bloco.serie(chaveSerie);
  final listaDetalhe = _listaDetalhamentoFin(bloco);
  return [
    ..._avisosFinanceiro(bloco),
    GradeCartoes(cartoes: cartoes),
    if (bloco.formula != null && bloco.formula!.isNotEmpty) ...[
      const SizedBox(height: 12),
      CaixaNota(titulo: 'Como foi calculado', texto: bloco.formula!),
    ],
    if (tituloGrafico != null && serie.isNotEmpty) ...[
      const SizedBox(height: 12),
      GraficoIndicador(
        titulo: tituloGrafico,
        pontos: [
          for (final item in serie)
            PontoSerie(
              item['nome_mes']?.toString() ??
                  _rotuloMesRepro(item['mes']?.toString()),
              numeroIndicador(item[chaveValorSerie]),
            ),
        ],
      ),
    ],
    if (listaDetalhe.isNotEmpty) ...[
      const SizedBox(height: 12),
      ListaCardsIndicador(
        titulo: 'Detalhamento',
        itens: listaDetalhe,
      ),
    ],
  ];
}

List<Widget> _avisosFinanceiro(IndicadorBloco bloco) {
  if (!bloco.temAvisoFinanceiro) {
    return const [];
  }
  final linhas = <String>[
    if (!bloco.disponivel) 'Indicador indisponível para o período/filtros atuais.',
    ...bloco.avisos,
  ];
  if (linhas.isEmpty) {
    return const [];
  }
  return [
    CaixaNota(
      titulo: 'Atenção',
      compacta: true,
      texto: linhas.join('\n'),
    ),
    const SizedBox(height: 12),
  ];
}

List<ItemCardIndicador> _listaDetalhamentoFin(IndicadorBloco bloco) {
  final linhas = bloco.detalhamento;
  if (linhas.isEmpty) {
    return const [];
  }
  return [
    for (final item in linhas)
      ItemCardIndicador(
        titulo: _tituloLinhaFin(item),
        campos: [
          if ((item['data']?.toString() ?? '').trim().isNotEmpty)
            CampoCardIndicador('Data', item['data'].toString()),
          if ((item['classificacao']?.toString() ?? '').trim().isNotEmpty)
            CampoCardIndicador(
              'Classificação',
              item['classificacao'].toString().replaceAll('_', ' '),
            ),
          if ((item['direcao']?.toString() ?? '').trim().isNotEmpty)
            CampoCardIndicador('Direção', item['direcao'].toString()),
          if ((item['natureza']?.toString() ?? '').trim().isNotEmpty)
            CampoCardIndicador('Natureza', item['natureza'].toString()),
          CampoCardIndicador(
            'Valor',
            _textoValorFin(item['valor']),
          ),
          if (item['estorno'] == true)
            const CampoCardIndicador('Estorno', 'Sim'),
        ],
      ),
  ];
}

String _tituloLinhaFin(Map<String, dynamic> item) {
  final descricao = item['descricao']?.toString().trim();
  if (descricao != null && descricao.isNotEmpty) {
    return descricao;
  }
  final id = item['id'];
  if (id != null) {
    return 'Lançamento #$id';
  }
  return 'Registro';
}

String _textoValorFin(dynamic valor) {
  if (valor == null) {
    return '—';
  }
  if (valor is Map) {
    final medicao = IndicadorValor.de(valor);
    return medicao.temValor
        ? medicao.exibir(unidadePadrao: 'R\$')
        : '—';
  }
  final numero = numeroIndicador(valor);
  if (numero == null) {
    final texto = valor.toString().trim();
    if (texto.isEmpty || texto.toLowerCase() == 'null') {
      return '—';
    }
    return texto;
  }
  return IndicadorValor(qtd: numero, unidade: 'R\$').exibir(unidadePadrao: 'R\$');
}
