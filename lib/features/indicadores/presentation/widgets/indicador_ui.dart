import 'package:costeira/core/components/form_accordion.dart';
import 'package:costeira/core/components/web_dialog_frame.dart';
import 'package:costeira/features/indicadores/domain/indicador_valor.dart';
import 'package:costeira/features/indicadores/presentation/indicadores_controller.dart';
import 'package:costeira/features/indicadores/presentation/web/indicadores_filter_web_dialog.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/foundation.dart';
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
    this.ajuda,
  });

  final String titulo;
  final IndicadorValor? medicao;
  final String? valor;
  final String? unidade;
  final String? unidadePadrao;
  final bool inteiro;
  /// Texto curto no card (só se [ajuda] for null — evita corte ilegível).
  final String? legenda;
  /// Explicação completa: mostra `?` e abre dialog/sheet ao tocar.
  final String? ajuda;

  Future<void> _abrirAjuda(BuildContext context) async {
    await abrirAjudaIndicador(
      context,
      titulo: titulo,
      texto: ajuda,
    );
  }

  @override
  Widget build(BuildContext context) {
    final partes = medicao?.partes(
      unidadePadrao: unidadePadrao,
      inteiro: inteiro,
    );
    final bruto = (partes?.numero ?? valor ?? '').trim();
    final vazio = bruto.isEmpty ||
        bruto == '—' ||
        bruto.toLowerCase() == 'null' ||
        (medicao != null && !medicao!.temValor && (valor == null || valor!.trim().isEmpty));
    final numero = vazio ? '—' : bruto;
    // Sem unidade se valor ausente (evita "%" / "R$" sozinhos).
    final unidadeLinha = vazio ? null : (partes?.unidade ?? unidade);
    final temAjuda = ajuda != null && ajuda!.trim().isNotEmpty;
    final legendaCurta = !temAjuda && legenda != null && legenda!.isNotEmpty;
    return Container(
      constraints: const BoxConstraints(minHeight: 108),
      padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E4D9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  titulo.toUpperCase(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                    color: Color(0xFF6B6B6B),
                    height: 1.2,
                  ),
                ),
              ),
              if (temAjuda)
                InkWell(
                  onTap: () => _abrirAjuda(context),
                  borderRadius: BorderRadius.circular(12),
                  child: const Padding(
                    padding: EdgeInsets.fromLTRB(4, 0, 0, 4),
                    child: Icon(
                      Icons.help_outline_rounded,
                      size: 16,
                      color: Color(0xFF8A8A8A),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: _ValorComUnidade(
              numero: numero,
              unidade: unidadeLinha,
              vazio: vazio,
            ),
          ),
          if (vazio) ...[
            const SizedBox(height: 4),
            const Text(
              'Sem dados',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Color(0xFFB0B0B0),
              ),
            ),
          ] else if (legendaCurta) ...[
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

/// Valor + unidade na mesma linha.
/// `R$` / `$` à esquerda; `%` e demais à direita, menores.
class _ValorComUnidade extends StatelessWidget {
  const _ValorComUnidade({
    required this.numero,
    this.unidade,
    this.vazio = false,
  });

  final String numero;
  final String? unidade;
  final bool vazio;

  static const _numeroStyle = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: Color(0xFF1F3D2A),
    height: 1,
  );

  static const _numeroVazioStyle = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: Color(0xFFB0B0B0),
    height: 1,
  );

  static const _unidadeStyle = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: MyColors.colorPrimary,
    height: 1,
  );

  bool get _prefixo {
    final u = (unidade ?? '').trim().toLowerCase();
    return u == r'r$' || u == r'$' || u.startsWith(r'r$');
  }

  @override
  Widget build(BuildContext context) {
    final styleNumero = vazio ? _numeroVazioStyle : _numeroStyle;
    final u = vazio ? '' : (unidade ?? '').trim();
    if (u.isEmpty) {
      return Text(numero, maxLines: 1, softWrap: false, style: styleNumero);
    }
    final unidadeWidget = Text(u, maxLines: 1, softWrap: false, style: _unidadeStyle);
    final numeroWidget = Text(numero, maxLines: 1, softWrap: false, style: styleNumero);
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: _prefixo
          ? [unidadeWidget, const SizedBox(width: 4), numeroWidget]
          : [
              numeroWidget,
              SizedBox(width: u == '%' ? 1 : 4),
              unidadeWidget,
            ],
    );
  }
}

class GradeCartoes extends StatelessWidget {
  const GradeCartoes({super.key, required this.cartoes, this.colunas});

  final List<Widget> cartoes;
  /// Se null: 3 cartões → 1 linha; senão 2 por linha.
  final int? colunas;

  @override
  Widget build(BuildContext context) {
    if (cartoes.isEmpty) {
      return const SizedBox.shrink();
    }
    final porLinha = colunas ?? (cartoes.length == 3 ? 3 : 2);
    final linhas = <Widget>[];
    for (var i = 0; i < cartoes.length; i += porLinha) {
      final fatia = cartoes.sublist(
        i,
        i + porLinha > cartoes.length ? cartoes.length : i + porLinha,
      );
      if (linhas.isNotEmpty) {
        linhas.add(const SizedBox(height: 8));
      }
      linhas.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var j = 0; j < fatia.length; j++) ...[
                if (j > 0) const SizedBox(width: 8),
                Expanded(child: fatia[j]),
              ],
              for (var j = fatia.length; j < porLinha; j++) ...[
                const SizedBox(width: 8),
                const Expanded(child: SizedBox.shrink()),
              ],
            ],
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: linhas,
    );
  }
}

Future<void> abrirAjudaIndicador(
  BuildContext context, {
  required String titulo,
  String? texto,
}) async {
  final corpo = texto?.trim();
  if (corpo == null || corpo.isEmpty) {
    return;
  }
  await _abrirSheetIndicador(
    context,
    titulo: titulo,
    filho: Text(
      corpo,
      style: const TextStyle(
        fontFamily: 'Montserrat',
        fontSize: 14,
        height: 1.45,
        color: Color(0xFF313131),
      ),
    ),
  );
}

Future<void> abrirAvisoIndicador(
  BuildContext context, {
  required String titulo,
  bool parcial = false,
  List<String> pendencias = const [],
  List<String> limitacoes = const [],
}) async {
  if (!parcial && pendencias.isEmpty && limitacoes.isEmpty) {
    return;
  }
  await _abrirSheetIndicador(
    context,
    titulo: titulo,
    filho: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (parcial) ...[
          const _ChipAviso(
            icone: Icons.info_outline_rounded,
            texto: 'Dados parciais — alguns vínculos ou horários são aproximados.',
          ),
          if (pendencias.isNotEmpty || limitacoes.isNotEmpty)
            const SizedBox(height: 14),
        ],
        if (pendencias.isNotEmpty) ...[
          const _TituloSecaoAviso('Pendências'),
          const SizedBox(height: 8),
          for (var i = 0; i < pendencias.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _ItemAviso(
              icone: Icons.warning_amber_rounded,
              texto: pendencias[i],
            ),
          ],
          if (limitacoes.isNotEmpty) const SizedBox(height: 16),
        ],
        if (limitacoes.isNotEmpty) ...[
          const _TituloSecaoAviso('Limitações'),
          const SizedBox(height: 8),
          for (var i = 0; i < limitacoes.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _ItemAviso(
              icone: Icons.circle,
              iconePequeno: true,
              texto: limitacoes[i],
            ),
          ],
        ],
      ],
    ),
  );
}

Future<void> _abrirSheetIndicador(
  BuildContext context, {
  required String titulo,
  required Widget filho,
}) {
  if (kIsWeb) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => WebDialogFrame(
        title: titulo,
        width: 560,
        maxHeight: 640,
        bodyPadding: const EdgeInsets.fromLTRB(28, 12, 28, 8),
        footer: Padding(
          padding: const EdgeInsets.fromLTRB(28, 16, 28, 24),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: MyColors.colorPrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: const Text('Entendi'),
            ),
          ),
        ),
        child: filho,
      ),
    );
  }

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (sheet) {
      final maxH = MediaQuery.sizeOf(sheet).height * 0.72;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD9D9D9),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                titulo,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: Color(0xFF1C1C1C),
                ),
              ),
              const SizedBox(height: 14),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: maxH - 120),
                child: SingleChildScrollView(child: filho),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(sheet),
                  style: FilledButton.styleFrom(
                    backgroundColor: MyColors.colorPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Entendi',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _ChipAviso extends StatelessWidget {
  const _ChipAviso({required this.icone, required this.texto});

  final IconData icone;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F4EA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8E4D9)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, size: 18, color: MyColors.colorPrimary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 13,
                height: 1.35,
                fontWeight: FontWeight.w600,
                color: Color(0xFF313131),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TituloSecaoAviso extends StatelessWidget {
  const _TituloSecaoAviso(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Text(
      texto.toUpperCase(),
      style: const TextStyle(
        fontFamily: 'Montserrat',
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
        color: Color(0xFF8A8A8A),
      ),
    );
  }
}

class _ItemAviso extends StatelessWidget {
  const _ItemAviso({
    required this.icone,
    required this.texto,
    this.iconePequeno = false,
  });

  final IconData icone;
  final String texto;
  final bool iconePequeno;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: IndicadorCores.linha),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: iconePequeno ? 5 : 1),
            child: Icon(
              icone,
              size: iconePequeno ? 7 : 18,
              color: iconePequeno
                  ? const Color(0xFFB0B0B0)
                  : const Color(0xFFC4A35A),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 13,
                height: 1.4,
                color: Color(0xFF313131),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CaixaNota extends StatelessWidget {
  const CaixaNota({
    super.key,
    required this.texto,
    this.titulo,
    this.compacta = false,
    this.parcial = false,
    this.pendencias = const [],
    this.limitacoes = const [],
  });

  final String texto;
  final String? titulo;
  /// Só título + `?`; abre dialog/sheet.
  final bool compacta;
  final bool parcial;
  final List<String> pendencias;
  final List<String> limitacoes;

  bool get _temEstrutura =>
      parcial || pendencias.isNotEmpty || limitacoes.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final tituloExibir = titulo ?? 'Atenção';
    if (compacta) {
      final resumo = parcial
          ? 'Dados parciais'
          : pendencias.isNotEmpty
              ? '${pendencias.length} pendência${pendencias.length == 1 ? '' : 's'}'
              : limitacoes.isNotEmpty
                  ? '${limitacoes.length} limitação${limitacoes.length == 1 ? '' : 'ões'}'
                  : 'Ver detalhes';
      return Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            if (_temEstrutura) {
              abrirAvisoIndicador(
                context,
                titulo: tituloExibir,
                parcial: parcial,
                pendencias: pendencias,
                limitacoes: limitacoes,
              );
            } else {
              abrirAjudaIndicador(
                context,
                titulo: tituloExibir,
                texto: texto,
              );
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: IndicadorCores.linha),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 18,
                  color: MyColors.colorPrimary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tituloExibir, style: tituloSecao),
                      const SizedBox(height: 2),
                      Text(
                        resumo,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF8A8A8A),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.help_outline_rounded,
                  size: 18,
                  color: Color(0xFF8A8A8A),
                ),
              ],
            ),
          ),
        ),
      );
    }
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

class CampoCardIndicador {
  const CampoCardIndicador(this.rotulo, this.valor, {this.cor});

  final String rotulo;
  final String valor;
  final Color? cor;
}

class ItemCardIndicador {
  const ItemCardIndicador({
    required this.titulo,
    this.subtitulo,
    this.selo,
    this.campos = const [],
    this.esmaecido = false,
  });

  final String titulo;
  final String? subtitulo;
  final String? selo;
  final List<CampoCardIndicador> campos;
  final bool esmaecido;
}

class ListaCardsIndicador extends StatefulWidget {
  const ListaCardsIndicador({
    super.key,
    required this.itens,
    this.titulo,
    this.vazio,
    this.limite = 3,
  });

  final List<ItemCardIndicador> itens;
  final String? titulo;
  final String? vazio;
  final int limite;

  @override
  State<ListaCardsIndicador> createState() => _ListaCardsIndicadorState();
}

class _ListaCardsIndicadorState extends State<ListaCardsIndicador> {
  bool _expandido = false;

  @override
  Widget build(BuildContext context) {
    final total = widget.itens.length;
    final cortar = !_expandido && total > widget.limite;
    final visiveis = cortar
        ? widget.itens.take(widget.limite).toList()
        : widget.itens;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.titulo != null) ...[
          Text(widget.titulo!, style: tituloSecao),
          const SizedBox(height: 8),
        ],
        if (total == 0)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: IndicadorCores.linha),
            ),
            child: Text(
              widget.vazio ?? 'Sem registros',
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 13,
                color: Color(0xFF8A8A8A),
              ),
            ),
          )
        else ...[
          for (var i = 0; i < visiveis.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _CardListaIndicador(item: visiveis[i]),
          ],
          if (total > widget.limite) ...[
            const SizedBox(height: 10),
            _botaoVerMais(
              rotulo: _expandido ? 'Ver menos' : 'Ver mais ($total)',
              onPressed: () => setState(() => _expandido = !_expandido),
            ),
          ],
        ],
      ],
    );
  }

  Widget _botaoVerMais({
    required String rotulo,
    required VoidCallback onPressed,
  }) {
    final botao = OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: MyColors.colorPrimary,
        backgroundColor: Colors.white,
        side: const BorderSide(color: Color(0xFFE6E6E6)),
        padding: EdgeInsets.symmetric(
          vertical: 12,
          horizontal: kIsWeb ? 20 : 12,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        rotulo,
        style: const TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    // Web: compacto e centralizado. Mobile: faixa larga pra toque.
    if (kIsWeb) {
      return Center(child: botao);
    }
    return SizedBox(width: double.infinity, child: botao);
  }
}

class _CardListaIndicador extends StatelessWidget {
  const _CardListaIndicador({required this.item});

  final ItemCardIndicador item;

  ({Color bg, Color fg}) _coresSelo(String selo) {
    final s = selo.toLowerCase();
    if (s.contains('morte') || s.contains('abigeato') || s == 'inativo') {
      return (bg: const Color(0xFFFDECEC), fg: const Color(0xFFC62828));
    }
    if (s.contains('venda') || s == 'ativo') {
      return (bg: const Color(0xFFE7F6EC), fg: MyColors.colorPrimary);
    }
    return (bg: const Color(0xFFF3F6F4), fg: const Color(0xFF3D5346));
  }

  @override
  Widget build(BuildContext context) {
    final selo = item.selo?.trim();
    final sub = item.subtitulo?.trim();
    final cores = selo == null || selo.isEmpty ? null : _coresSelo(selo);
    final temSub = sub != null && sub.isNotEmpty;

    return Opacity(
      opacity: item.esmaecido ? 0.45 : 1,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE6E6E6)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho: título (+ lote) | selo — uma linha só
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: temSub
                      ? Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: item.titulo,
                                style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1C1C1C),
                                ),
                              ),
                              const TextSpan(
                                text: '  ·  ',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFFB0B0B0),
                                ),
                              ),
                              TextSpan(
                                text: sub,
                                style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF8C8C8C),
                                ),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      : Text(
                          item.titulo,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1C1C1C),
                          ),
                        ),
                ),
                if (selo != null && selo.isNotEmpty && cores != null) ...[
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: cores.bg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      selo,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: cores.fg,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            if (item.campos.isNotEmpty) ...[
              const SizedBox(height: 10),
              // Faixa de métricas: rótulo acima do valor (como antes), só mais baixa
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F5F0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    for (var i = 0; i < item.campos.length; i++) ...[
                      if (i > 0)
                        Container(
                          width: 1,
                          height: 24,
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          color: const Color(0xFFE2DDD2),
                        ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.campos[i].rotulo.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.35,
                                color: Color(0xFF8A8A8A),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.campos[i].valor,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                height: 1.15,
                                color: item.campos[i].cor ??
                                    const Color(0xFF313131),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
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
    if (kIsWeb) {
      return showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => IndicadoresFilterWebDialog(controller: controller),
      );
    }
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
