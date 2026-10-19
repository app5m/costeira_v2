import 'package:costeira/core/components/form_accordion.dart';
import 'package:costeira/features/indicadores/domain/indicador_valor.dart';
import 'package:costeira/features/indicadores/presentation/indicadores_controller.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';

const tituloPagina = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 16,
  fontWeight: FontWeight.w600,
  color: Color(0xFF313131),
);

const tituloSecao = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 15,
  fontWeight: FontWeight.w700,
  color: Color(0xFF313131),
);

const tituloLista = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 15,
  fontWeight: FontWeight.w600,
  color: Color(0xFF313131),
);

const subtituloLista = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 12,
  fontWeight: FontWeight.w500,
  color: Color(0xFF8A8A8A),
);

class IndicadorCores {
  const IndicadorCores._();

  static const fundo = Color(0xFFF3F0E8);
  static const verde = Color(0xFF1E7A42);
  static const texto = Color(0xFF243028);
  static const legenda = Color(0xFF6B675F);
  static const linha = Color(0xFFD7D1C4);
}

class CartaoIndicador extends StatelessWidget {
  const CartaoIndicador({
    super.key,
    required this.titulo,
    this.medicao,
    this.valor,
    this.unidade,
    this.unidadePadrao,
    this.inteiro = false,
    this.legenda,
  });

  final String titulo;
  final IndicadorValor? medicao;
  final String? valor;
  final String? unidade;
  final String? unidadePadrao;
  final bool inteiro;
  final String? legenda;

  @override
  Widget build(BuildContext context) {
    final partes = medicao?.partes(
      unidadePadrao: unidadePadrao,
      inteiro: inteiro,
    );
    final numero = partes?.numero ?? valor ?? '—';
    final unidadeLinha = partes?.unidade ?? unidade;
    return Container(
      constraints: const BoxConstraints(minHeight: 118),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E4D9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo.toUpperCase(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
              color: Color(0xFF6B6B6B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            numero,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1F3D2A),
              height: 1,
            ),
          ),
          if (unidadeLinha != null && unidadeLinha.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              unidadeLinha,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: MyColors.colorPrimary,
              ),
            ),
          ],
          if (legenda != null && legenda!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              legenda!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Color(0xFF8A8A8A),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class GradeCartoes extends StatelessWidget {
  const GradeCartoes({super.key, required this.cartoes});

  final List<Widget> cartoes;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 12.0;
        final largura = (constraints.maxWidth - gap) / 2;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final cartao in cartoes)
              SizedBox(width: largura, child: cartao),
          ],
        );
      },
    );
  }
}

class CaixaNota extends StatelessWidget {
  const CaixaNota({super.key, required this.texto, this.titulo});

  final String texto;
  final String? titulo;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: IndicadorCores.linha),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (titulo != null) ...[
            Text(titulo!, style: tituloSecao),
            const SizedBox(height: 6),
          ],
          Text(
            texto,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 13,
              height: 1.35,
              color: Color(0xFF313131),
            ),
          ),
        ],
      ),
    );
  }
}

class PontoSerie {
  const PontoSerie(this.rotulo, this.valor);

  final String rotulo;
  final num? valor;
}

class GraficoIndicador extends StatelessWidget {
  const GraficoIndicador({
    super.key,
    required this.titulo,
    required this.pontos,
    this.barras = false,
  });

  final String titulo;
  final List<PontoSerie> pontos;
  final bool barras;

  bool get _barrasHorizontais {
    if (!barras) {
      return false;
    }
    return pontos.length > 6 || pontos.any((ponto) => ponto.rotulo.length > 4);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: IndicadorCores.linha),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: tituloSecao),
          const SizedBox(height: 8),
          if (_barrasHorizontais)
            _BarrasHorizontais(pontos: pontos)
          else
            SizedBox(
              height: 200,
              width: double.infinity,
              child: CustomPaint(
                painter: _GraficoPainter(pontos: pontos, barras: barras),
              ),
            ),
        ],
      ),
    );
  }
}

class _GraficoPainter extends CustomPainter {
  _GraficoPainter({required this.pontos, required this.barras});

  final List<PontoSerie> pontos;
  final bool barras;

  @override
  void paint(Canvas canvas, Size size) {
    const topo = 12.0;
    const base = 36.0;
    final area = Rect.fromLTWH(0, topo, size.width, size.height - topo - base);
    final valores = pontos.map((p) => p.valor).whereType<num>().toList();
    final maximo = valores.isEmpty
        ? 1.0
        : valores.map((v) => v.toDouble()).reduce((a, b) => a > b ? a : b);
    final teto = maximo <= 0 ? 1.0 : maximo * 1.15;
    final eixo = Paint()
      ..color = IndicadorCores.linha
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(0, area.bottom),
      Offset(size.width, area.bottom),
      eixo,
    );
    if (pontos.isEmpty) {
      return;
    }
    final passo = area.width / pontos.length;
    final barra = Paint()..color = IndicadorCores.verde;
    final linha = Paint()
      ..color = IndicadorCores.verde
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final pontosLinha = <Offset>[];
    for (var i = 0; i < pontos.length; i++) {
      final ponto = pontos[i];
      final x = area.left + passo * i + passo / 2;
      if (ponto.valor != null) {
        final y = area.bottom - (ponto.valor!.toDouble() / teto) * area.height;
        if (barras) {
          final altura = (area.bottom - y)
            .clamp(ponto.valor == 0 ? 1.0 : 0.0, area.height)
            .toDouble();
          final largura = (passo * 0.55).clamp(3.0, 22.0);
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(x - largura / 2, area.bottom - altura, largura, altura),
              const Radius.circular(3),
            ),
            barra,
          );
        } else {
          pontosLinha.add(Offset(x, y));
          canvas.drawCircle(Offset(x, y), 3.5, Paint()..color = IndicadorCores.verde);
        }
      }
      final rotulo = TextPainter(
        text: TextSpan(
          text: ponto.rotulo,
          style: const TextStyle(color: IndicadorCores.legenda, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
        ellipsis: '…',
      )..layout(maxWidth: passo - 4);
      rotulo.paint(canvas, Offset(x - rotulo.width / 2, area.bottom + 8));
    }
    if (!barras && pontosLinha.length > 1) {
      final caminho = Path()..moveTo(pontosLinha.first.dx, pontosLinha.first.dy);
      for (final ponto in pontosLinha.skip(1)) {
        caminho.lineTo(ponto.dx, ponto.dy);
      }
      canvas.drawPath(caminho, linha);
    }
  }

  @override
  bool shouldRepaint(covariant _GraficoPainter oldDelegate) => true;
}

class _BarrasHorizontais extends StatelessWidget {
  const _BarrasHorizontais({required this.pontos});

  final List<PontoSerie> pontos;

  @override
  Widget build(BuildContext context) {
    final valores = pontos.map((ponto) => ponto.valor).whereType<num>();
    final maximo = valores.isEmpty
        ? 1.0
        : valores.map((valor) => valor.toDouble()).reduce((a, b) => a > b ? a : b);
    final teto = maximo <= 0 ? 1.0 : maximo;
    return Column(
      children: [
        for (final ponto in pontos)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 96,
                  child: Text(
                    ponto.rotulo,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, height: 1.15),
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final fracao = ponto.valor == null
                          ? 0.0
                          : (ponto.valor!.toDouble() / teto).clamp(0.0, 1.0);
                      final largura = ponto.valor == 0
                          ? 2.0
                          : constraints.maxWidth * fracao;
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          height: 8,
                          width: largura,
                          decoration: BoxDecoration(
                            color: ponto.valor == null
                                ? IndicadorCores.linha
                                : IndicadorCores.verde,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 52,
                  child: Text(
                    ponto.valor == null ? '—' : formatarNumero(ponto.valor!),
                    textAlign: TextAlign.end,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class TabelaIndicador extends StatelessWidget {
  const TabelaIndicador({
    super.key,
    required this.colunas,
    required this.linhas,
    this.esmaecer,
  });

  final List<String> colunas;
  final List<List<Widget>> linhas;
  final bool Function(int indice)? esmaecer;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: IndicadorCores.linha),
      ),
      child: Column(
        children: [
          Container(
            color: const Color(0xFFF7F5F0),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                for (var i = 0; i < colunas.length; i++)
                  Expanded(
                    flex: i == 0 ? 3 : 2,
                    child: Text(
                      colunas[i],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        color: IndicadorCores.verde,
                        fontSize: 11,
                        height: 1.15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          for (var i = 0; i < linhas.length; i++)
            Opacity(
              opacity: esmaecer?.call(i) == true ? 0.4 : 1,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: IndicadorCores.linha)),
                ),
                child: Row(
                  children: [
                    for (var c = 0; c < linhas[i].length; c++)
                      Expanded(flex: c == 0 ? 3 : 2, child: linhas[i][c]),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

Widget celula(String texto, {Color? cor}) {
  return Text(
    texto,
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
    style: TextStyle(
      fontFamily: 'Montserrat',
      color: cor ?? IndicadorCores.texto,
      fontSize: 11,
      height: 1.15,
    ),
  );
}

class FiltrosIndicador extends StatelessWidget {
  const FiltrosIndicador({super.key, required this.controller});

  final IndicadoresController controller;

  @override
  Widget build(BuildContext context) {
    final ativo = controller.filtrosAtivos;
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: IconButton(
        onPressed: () => _abrir(context),
        style: IconButton.styleFrom(
          backgroundColor: ativo ? const Color(0x14128977) : Colors.transparent,
          side: BorderSide(
            color: ativo ? MyColors.colorPrimary : const Color(0xFFE6E6E6),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        icon: Icon(
          Icons.tune_rounded,
          color: ativo ? MyColors.colorPrimary : const Color(0xFF8C8C8C),
        ),
      ),
    );
  }

  Future<void> _abrir(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _FiltroSheet(controller: controller),
    );
  }
}

class _FiltroSheet extends StatefulWidget {
  const _FiltroSheet({required this.controller});

  final IndicadoresController controller;

  @override
  State<_FiltroSheet> createState() => _FiltroSheetState();
}

class _FiltroSheetState extends State<_FiltroSheet> {
  late final TextEditingController dias;
  String? _aberto;

  IndicadoresController get c => widget.controller;

  @override
  void initState() {
    super.initState();
    dias = TextEditingController(text: '${c.ultimosDias}');
    c.addListener(_atualizar);
  }

  void _atualizar() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    c.removeListener(_atualizar);
    dias.dispose();
    super.dispose();
  }

  void _alternar(String id) {
    setState(() => _aberto = _aberto == id ? null : id);
  }

  @override
  Widget build(BuildContext context) {
    final altura = MediaQuery.sizeOf(context).height * 0.7;
    final pedeAplicar =
        c.periodo == TipoPeriodoIndicador.ultimosDias ||
        c.periodo == TipoPeriodoIndicador.personalizado;
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 72,
            height: 2,
            color: const Color(0xFFE2E2E2),
          ),
          const SizedBox(height: 16),
          const Text(
            'Filtros',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: Color(0xFF1C1C1C),
            ),
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: altura),
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              children: [
                FormAccordion(
                  title: 'Período · ${c.rotuloPeriodo}',
                  expanded: _aberto == 'periodo',
                  onToggle: () => _alternar('periodo'),
                  complete: c.periodo == TipoPeriodoIndicador.anoAgricola
                      ? null
                      : true,
                  child: Column(
                    children: [
                      _opcao(
                        'Todo o período',
                        c.periodo == TipoPeriodoIndicador.todo,
                        () => c.setPeriodo(TipoPeriodoIndicador.todo),
                      ),
                      _opcao(
                        'Ano agrícola atual',
                        c.periodo == TipoPeriodoIndicador.anoAgricola,
                        () => c.setPeriodo(TipoPeriodoIndicador.anoAgricola),
                      ),
                      _opcao(
                        'Últimos X dias',
                        c.periodo == TipoPeriodoIndicador.ultimosDias,
                        () => c.setPeriodo(TipoPeriodoIndicador.ultimosDias),
                      ),
                      _opcao(
                        'Personalizado',
                        c.periodo == TipoPeriodoIndicador.personalizado,
                        () => c.setPeriodo(TipoPeriodoIndicador.personalizado),
                      ),
                      if (c.periodo == TipoPeriodoIndicador.ultimosDias)
                        TextField(
                          controller: dias,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Dias'),
                        ),
                      if (c.periodo == TipoPeriodoIndicador.personalizado)
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _data(true),
                                child: Text(
                                  'De ${c.dataDe == null ? '' : IndicadoresController.formatar(c.dataDe!)}',
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _data(false),
                                child: Text(
                                  'Até ${c.dataAte == null ? '' : IndicadoresController.formatar(c.dataAte!)}',
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                FormAccordion(
                  title: 'Lote · ${_nome(c.lotes, c.loteId, 'Todos os lotes')}',
                  expanded: _aberto == 'lote',
                  onToggle: () => _alternar('lote'),
                  complete: c.loteId == null ? null : true,
                  child: Column(
                    children: [
                      _opcao('Todos os lotes', c.loteId == null, () => c.setLote(null)),
                      for (final lote in c.lotes)
                        _opcao(
                          lote.nome,
                          c.loteId == lote.id,
                          () => c.setLote(lote.id),
                        ),
                    ],
                  ),
                ),
                FormAccordion(
                  title: 'Categoria · ${_nomeCategoria()}',
                  expanded: _aberto == 'categoria',
                  onToggle: () => _alternar('categoria'),
                  complete: c.categoriaId == null ? null : true,
                  child: Column(
                    children: [
                      _opcao(
                        'Todas as categorias',
                        c.categoriaId == null,
                        () => c.setCategoria(null),
                      ),
                      for (final categoria in c.categorias)
                        _opcao(
                          categoria.nome,
                          c.categoriaId == categoria.id,
                          () => c.setCategoria(categoria.id),
                        ),
                    ],
                  ),
                ),
                FormAccordion(
                  title: 'Piquete · ${_nome(c.piquetes, c.piqueteId, 'Todos os piquetes')}',
                  expanded: _aberto == 'piquete',
                  onToggle: () => _alternar('piquete'),
                  complete: c.piqueteId == null ? null : true,
                  child: Column(
                    children: [
                      _opcao(
                        'Todos os piquetes',
                        c.piqueteId == null,
                        () => c.setPiquete(null),
                      ),
                      for (final piquete in c.piquetes)
                        _opcao(
                          piquete.nome,
                          c.piqueteId == piquete.id,
                          () => c.setPiquete(piquete.id),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (c.filtrosAtivos || pedeAplicar)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Column(
                children: [
                  if (c.filtrosAtivos)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _limpar,
                        child: const Text(
                          'Limpar filtros',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  if (c.filtrosAtivos && pedeAplicar) const SizedBox(height: 8),
                  if (pedeAplicar)
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _aplicar,
                        child: const Text('Aplicar'),
                      ),
                    ),
                ],
              ),
            )
          else
            const SizedBox(height: 8),
        ],
      ),
    );
  }

  String _nome(List<dynamic> itens, int? id, String todos) {
    if (id == null) {
      return todos;
    }
    for (final item in itens) {
      if (item.id == id) {
        return item.nome as String;
      }
    }
    return todos;
  }

  String _nomeCategoria() {
    for (final categoria in c.categorias) {
      if (categoria.id == c.categoriaId) {
        return categoria.nome;
      }
    }
    return 'Todas as categorias';
  }

  Future<void> _data(bool inicio) async {
    final atual = inicio ? c.dataDe : c.dataAte;
    final data = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: atual ?? DateTime.now(),
    );
    if (data == null) {
      return;
    }
    c.setDatas(inicio ? data : c.dataDe, inicio ? c.dataAte : data);
  }

  void _limpar() {
    Navigator.of(context).pop();
    c.limparFiltros();
  }

  void _aplicar() {
    if (c.periodo == TipoPeriodoIndicador.ultimosDias) {
      final valor = int.tryParse(dias.text.trim());
      if (valor == null || valor <= 0) {
        return;
      }
      c.setUltimosDias(valor);
    }
    Navigator.of(context).pop();
    c.carregar();
  }

  Widget _opcao(String label, bool selecionado, VoidCallback aoToque) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        label,
        style: TextStyle(
          color: selecionado ? MyColors.colorPrimary : const Color(0xFF313131),
          fontFamily: 'Montserrat',
          fontWeight: selecionado ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
      trailing: selecionado
          ? const Icon(Icons.check_rounded, color: MyColors.colorPrimary)
          : null,
      onTap: aoToque,
    );
  }
}


EdgeInsets paddingIndicadores(BuildContext context) {
  final baixo = MediaQuery.paddingOf(context).bottom;
  return EdgeInsets.fromLTRB(16, 8, 16, 40 + baixo);
}

String textoOuTraco(
  num? valor, {
  String? unidade,
  int casas = 3,
  bool fixo = false,
}) {
  if (valor == null) {
    return '—';
  }
  final numero = formatarNumero(valor, casas: casas, fixo: fixo);
  if (unidade == null || unidade.isEmpty) {
    return numero;
  }
  return '$numero $unidade';
}
