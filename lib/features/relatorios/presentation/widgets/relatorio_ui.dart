import 'package:costeira/features/relatorios/domain/relatorio_models.dart';
import 'package:flutter/material.dart';

class RelatorioCores {
  const RelatorioCores._();

  static const fundo = Color(0xFFF3F0E8);
  static const verde = Color(0xFF1E7A42);
  static const texto = Color(0xFF243028);
  static const legenda = Color(0xFF6B675F);
  static const linha = Color(0xFFE8E4D9);
  static const cartao = Colors.white;
}

const tituloRelatorio = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 16,
  fontWeight: FontWeight.w600,
  color: RelatorioCores.texto,
);

const tituloSecaoRelatorio = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 14,
  fontWeight: FontWeight.w700,
  color: RelatorioCores.texto,
);

const subtituloRelatorio = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 12,
  fontWeight: FontWeight.w500,
  color: RelatorioCores.legenda,
);

class ChipPeriodoRelatorio extends StatelessWidget {
  const ChipPeriodoRelatorio({
    super.key,
    required this.rotulo,
    required this.ativo,
    required this.onTap,
  });

  final String rotulo;
  final bool ativo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ativo ? RelatorioCores.verde : Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            rotulo,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: ativo ? Colors.white : RelatorioCores.texto,
            ),
          ),
        ),
      ),
    );
  }
}

class CartaoKpiRelatorio extends StatelessWidget {
  const CartaoKpiRelatorio({
    super.key,
    required this.titulo,
    required this.valor,
  });

  final String titulo;
  final RelatorioValor valor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
      decoration: BoxDecoration(
        color: RelatorioCores.cartao,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RelatorioCores.linha),
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
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
              color: Color(0xFF6B6B6B),
              height: 1.2,
            ),
          ),
          const Spacer(),
          Text(
            valor.disponivel ? valor.exibicao : '—',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: RelatorioCores.verde,
            ),
          ),
        ],
      ),
    );
  }
}

class SecaoCartoesRelatorio extends StatelessWidget {
  const SecaoCartoesRelatorio({
    super.key,
    required this.titulo,
    required this.linhas,
  });

  final String titulo;
  final List<Map<String, dynamic>> linhas;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: tituloSecaoRelatorio),
        const SizedBox(height: 8),
        if (linhas.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: RelatorioCores.cartao,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: RelatorioCores.linha),
            ),
            child: const Text('Sem registros no período.', style: subtituloRelatorio),
          )
        else
          for (var i = 0; i < linhas.length && i < 50; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            CartaoLinhaRelatorio(linha: linhas[i]),
          ],
        if (linhas.length > 50) ...[
          const SizedBox(height: 8),
          Text('+ ${linhas.length - 50} itens', style: subtituloRelatorio),
        ],
      ],
    );
  }
}

class CartaoLinhaRelatorio extends StatelessWidget {
  const CartaoLinhaRelatorio({super.key, required this.linha});

  final Map<String, dynamic> linha;

  @override
  Widget build(BuildContext context) {
    final titulo = _titulo(linha);
    final destaque = _destaque(linha);
    final metas = _metas(linha);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: RelatorioCores.cartao,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RelatorioCores.linha),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  titulo,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: RelatorioCores.texto,
                  ),
                ),
              ),
              if (destaque != null) ...[
                const SizedBox(width: 8),
                Text(
                  destaque,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: RelatorioCores.verde,
                  ),
                ),
              ],
            ],
          ),
          if (metas.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final m in metas) _MetaChip(rotulo: m.$1, valor: m.$2),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _titulo(Map<String, dynamic> m) {
    for (final k in [
      'categoria',
      'nome',
      'produto',
      'descricao',
      'tipo',
      'nome_mes',
      'mes',
      'responsavel',
      'procedimento',
    ]) {
      final v = _txt(m[k]);
      if (v != null) return v;
    }
    return 'Item';
  }

  String? _destaque(Map<String, dynamic> m) {
    for (final k in [
      'cabecas',
      'ua',
      'ua_ha',
      'peso_medio',
      'custo',
      'valor',
      'valor_estoque',
      'gmd',
      'chuva_mm',
      'quantidade',
      'estoque',
      'entradas',
      'saidas',
      'resultado',
      'pendentes',
      'atrasadas',
    ]) {
      final v = _txt(m[k]);
      if (v == null) continue;
      final unidade = switch (k) {
        'cabecas' => 'cab.',
        'ua' => 'UA',
        'ua_ha' => 'UA/ha',
        'peso_medio' => 'kg',
        'chuva_mm' => 'mm',
        'gmd' => 'kg/dia',
        _ => '',
      };
      return unidade.isEmpty ? v : '$v $unidade';
    }
    return null;
  }

  List<(String, String)> _metas(Map<String, dynamic> m) {
    const preferidas = [
      'fase',
      'status',
      'status_atual',
      'categoria',
      'subcategoria',
      'unidade',
      'data',
      'data_in',
      'data_out',
      'data_prazo',
      'urgencia',
      'tipo',
      'motivo',
      'fornecedor',
      'comprador',
      'observacao',
      'obs',
      'area_util',
      'area_manejada',
      'saldo',
      'custo_medio',
      'quantidade_animais',
      'peso_total',
      'valor_total',
      'dias_com_chuva',
      'acumulado_mm',
      'inventario_inicial',
      'compras',
      'nascimentos',
      'rebanho_fim_mes',
      'kg_produzido',
      'gmd_global',
      'concluidas_periodo',
    ];
    final tituloKey = _chaveTitulo(m);
    final destaqueKey = _chaveDestaque(m);
    final out = <(String, String)>[];
    for (final k in preferidas) {
      if (k == tituloKey || k == destaqueKey) continue;
      if (!m.containsKey(k)) continue;
      final v = _txt(m[k]);
      if (v == null) continue;
      out.add((_rotulo(k), v));
      if (out.length >= 6) break;
    }
    return out;
  }

  String? _chaveTitulo(Map<String, dynamic> m) {
    for (final k in ['categoria', 'nome', 'produto', 'descricao', 'tipo', 'nome_mes', 'mes']) {
      if (_txt(m[k]) != null) return k;
    }
    return null;
  }

  String? _chaveDestaque(Map<String, dynamic> m) {
    for (final k in ['cabecas', 'ua', 'ua_ha', 'peso_medio', 'custo', 'valor', 'gmd', 'chuva_mm', 'estoque']) {
      if (_txt(m[k]) != null) return k;
    }
    return null;
  }

  String? _txt(dynamic v) {
    if (v == null) return null;
    if (v is List) return v.isEmpty ? null : '${v.length}';
    if (v is Map) {
      final n = v['nome'] ?? v['descricao'];
      return n == null ? null : '$n'.trim().isEmpty ? null : '$n'.trim();
    }
    final s = '$v'.trim();
    if (s.isEmpty || s == 'null' || s == '—') return null;
    return s;
  }

  String _rotulo(String k) {
    const mapa = {
      'fase': 'Fase',
      'status': 'Status',
      'status_atual': 'Status',
      'categoria': 'Categoria',
      'subcategoria': 'Subcategoria',
      'unidade': 'Unidade',
      'data': 'Data',
      'data_in': 'De',
      'data_out': 'Até',
      'data_prazo': 'Prazo',
      'urgencia': 'Urgência',
      'tipo': 'Tipo',
      'motivo': 'Motivo',
      'fornecedor': 'Fornecedor',
      'comprador': 'Comprador',
      'observacao': 'Obs.',
      'obs': 'Obs.',
      'area_util': 'Área útil',
      'area_manejada': 'Área',
      'saldo': 'Saldo',
      'custo_medio': 'Custo médio',
      'quantidade_animais': 'Animais',
      'peso_total': 'Peso total',
      'valor_total': 'Valor',
      'dias_com_chuva': 'Dias chuva',
      'acumulado_mm': 'Acumulado',
      'inventario_inicial': 'Inventário',
      'compras': 'Compras',
      'nascimentos': 'Nascimentos',
      'rebanho_fim_mes': 'Rebanho fim',
      'kg_produzido': 'Kg produzido',
      'gmd_global': 'GMD',
      'concluidas_periodo': 'Concluídas',
    };
    return mapa[k] ??
        k
            .replaceAll('_', ' ')
            .split(' ')
            .map((p) => p.isEmpty ? p : '${p[0].toUpperCase()}${p.substring(1)}')
            .join(' ');
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.rotulo, required this.valor});

  final String rotulo;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F0E8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$rotulo · ',
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: RelatorioCores.legenda,
              ),
            ),
            TextSpan(
              text: valor,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: RelatorioCores.texto,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LimitacoesRelatorio extends StatelessWidget {
  const LimitacoesRelatorio({super.key, required this.itens});

  final List<String> itens;

  @override
  Widget build(BuildContext context) {
    if (itens.isEmpty) return const SizedBox.shrink();
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Container(
        decoration: BoxDecoration(
          color: RelatorioCores.cartao,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: RelatorioCores.linha),
        ),
        child: ExpansionTile(
          initiallyExpanded: false,
          tilePadding: const EdgeInsets.symmetric(horizontal: 14),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
          title: Text(
            'Limitações dos dados (${itens.length})',
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: RelatorioCores.texto,
            ),
          ),
          subtitle: const Text(
            'Notas da API sobre o cálculo',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 11,
              color: RelatorioCores.legenda,
            ),
          ),
          children: [
            for (var i = 0; i < itens.length; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(Icons.info_outline, size: 14, color: RelatorioCores.legenda),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      itens[i],
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 12,
                        height: 1.35,
                        color: RelatorioCores.legenda,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class BotaoExportarPdf extends StatelessWidget {
  const BotaoExportarPdf({
    super.key,
    required this.carregando,
    required this.onPressed,
  });

  final bool carregando;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: carregando ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: RelatorioCores.verde,
          foregroundColor: Colors.white,
          disabledBackgroundColor: RelatorioCores.verde.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        icon: carregando
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.picture_as_pdf_outlined, size: 20),
        label: Text(
          carregando ? 'Gerando PDF…' : 'Exportar PDF',
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
