import 'package:costeira/features/indicadores/domain/indicador_valor.dart';
import 'package:costeira/features/indicadores/presentation/indicadores_controller.dart';
import 'package:flutter/material.dart';

class IndicadorCores {
  const IndicadorCores._();

  static const fundo = Color(0xFFF3F0E8);
  static const card = Color(0xFFE7E2D4);
  static const verde = Color(0xFF1E7A42);
  static const chip = Color(0xFF1B6B38);
  static const marrom = Color(0xFF8C4E16);
  static const texto = Color(0xFF243028);
  static const legenda = Color(0xFF6B675F);
  static const linha = Color(0xFFD7D1C4);
}

class CartaoIndicador extends StatelessWidget {
  const CartaoIndicador({
    super.key,
    required this.valor,
    required this.titulo,
    this.legenda,
    this.corValor = IndicadorCores.verde,
  });

  final String valor;
  final String titulo;
  final String? legenda;
  final Color corValor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
      decoration: BoxDecoration(
        color: IndicadorCores.card,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            valor,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: corValor,
              fontSize: 18,
              height: 1.1,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            titulo,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: IndicadorCores.texto,
              fontSize: 12,
              height: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (legenda != null && legenda!.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              legenda!,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: IndicadorCores.legenda,
                fontSize: 10,
                height: 1.2,
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
    return Column(
      children: [
        for (var i = 0; i < cartoes.length; i += 2)
          Padding(
            padding: EdgeInsets.only(bottom: i + 2 < cartoes.length ? 8 : 0),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: cartoes[i]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: i + 1 < cartoes.length
                        ? cartoes[i + 1]
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
      ],
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
            Text(
              titulo!,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
          ],
          Text(texto, style: const TextStyle(height: 1.35)),
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
          Text(titulo, style: const TextStyle(fontWeight: FontWeight.w700)),
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
      color: cor ?? IndicadorCores.texto,
      fontSize: 11,
      height: 1.15,
    ),
  );
}

class FiltrosIndicador extends StatefulWidget {
  const FiltrosIndicador({super.key, required this.controller});

  final IndicadoresController controller;

  @override
  State<FiltrosIndicador> createState() => _FiltrosIndicadorState();
}

class _FiltrosIndicadorState extends State<FiltrosIndicador> {
  bool aberto = true;
  final dias = TextEditingController(text: '30');

  IndicadoresController get c => widget.controller;

  @override
  void dispose() {
    dias.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE7E4DA),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => aberto = !aberto),
            child: Text(
              aberto ? 'Filtros  ·  clique para ocultar' : 'Filtros  ·  clique para abrir',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          if (aberto) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _menu(
                  'PERÍODO',
                  c.rotuloPeriodo,
                  [
                    _item('Todo o período', () => c.setPeriodo(TipoPeriodoIndicador.todo)),
                    _item('Ano agrícola atual', () => c.setPeriodo(TipoPeriodoIndicador.anoAgricola)),
                    _item('Últimos X dias', () => c.setPeriodo(TipoPeriodoIndicador.ultimosDias)),
                    _item('Personalizado', () => c.setPeriodo(TipoPeriodoIndicador.personalizado)),
                  ],
                ),
                _menu(
                  'LOTE',
                  _nome(c.lotes, c.loteId, 'Todos os lotes'),
                  [
                    _item('Todos os lotes', () => c.setLote(null)),
                    for (final lote in c.lotes)
                      _item(lote.nome, () => c.setLote(lote.id)),
                  ],
                ),
                _menu(
                  'CATEGORIA',
                  _nomeCategoria(),
                  [
                    _item('Todas as categorias', () => c.setCategoria(null)),
                    for (final categoria in c.categorias)
                      _item(categoria.nome, () => c.setCategoria(categoria.id)),
                  ],
                ),
                _menu(
                  'PIQUETE',
                  _nome(c.piquetes, c.piqueteId, 'Todos os piquetes'),
                  [
                    _item('Todos os piquetes', () => c.setPiquete(null)),
                    for (final piquete in c.piquetes)
                      _item(piquete.nome, () => c.setPiquete(piquete.id)),
                  ],
                ),
              ],
            ),
            if (c.periodo == TipoPeriodoIndicador.ultimosDias) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  SizedBox(
                    width: 90,
                    child: TextField(
                      controller: dias,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Dias'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () {
                      final valor = int.tryParse(dias.text.trim());
                      if (valor == null || valor <= 0) {
                        return;
                      }
                      c.setUltimosDias(valor);
                      c.carregar();
                    },
                    child: const Text('Aplicar'),
                  ),
                ],
              ),
            ],
            if (c.periodo == TipoPeriodoIndicador.personalizado) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: [
                  OutlinedButton(
                    onPressed: () async {
                      final data = await showDatePicker(
                        context: context,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                        initialDate: c.dataDe ?? DateTime.now(),
                      );
                      if (data != null) {
                        c.setDatas(data, c.dataAte);
                      }
                    },
                    child: Text('De ${c.dataDe == null ? '' : IndicadoresController.formatar(c.dataDe!)}'),
                  ),
                  OutlinedButton(
                    onPressed: () async {
                      final data = await showDatePicker(
                        context: context,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                        initialDate: c.dataAte ?? DateTime.now(),
                      );
                      if (data != null) {
                        c.setDatas(c.dataDe, data);
                      }
                    },
                    child: Text('Até ${c.dataAte == null ? '' : IndicadoresController.formatar(c.dataAte!)}'),
                  ),
                  FilledButton(
                    onPressed: c.carregar,
                    child: const Text('Aplicar'),
                  ),
                ],
              ),
            ],
          ],
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

  PopupMenuItem<void> _item(String texto, VoidCallback acao) {
    return PopupMenuItem(onTap: acao, child: Text(texto));
  }

  Widget _menu(String rotulo, String valor, List<PopupMenuEntry<void>> itens) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          rotulo,
          style: const TextStyle(
            fontSize: 11,
            letterSpacing: 0.4,
            color: IndicadorCores.legenda,
          ),
        ),
        const SizedBox(height: 4),
        PopupMenuButton<void>(
          itemBuilder: (_) => itens,
          child: Container(
            constraints: const BoxConstraints(minWidth: 160),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: IndicadorCores.chip,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    valor,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
                const Icon(Icons.expand_more, color: Colors.white, size: 18),
              ],
            ),
          ),
        ),
      ],
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
