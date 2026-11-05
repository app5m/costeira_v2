import 'package:costeira/features/financeiro/domain/financeiro_mock.dart';
import 'package:costeira/features/financeiro/presentation/widgets/financeiro_ui.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DespesaParceriaDetalhePage extends StatelessWidget {
  const DespesaParceriaDetalhePage({
    super.key,
    required this.parceriaId,
    required this.titulo,
    required this.aoVoltar,
    required this.aoPagar,
  });

  final int parceriaId;
  final TituloParceriaFin titulo;
  final VoidCallback aoVoltar;
  final VoidCallback aoPagar;

  String _tituloHero() {
    if (titulo.descricao.trim().isNotEmpty) return titulo.descricao.trim();
    if (titulo.categoriaNome != null && titulo.categoriaNome!.trim().isNotEmpty) {
      return titulo.categoriaNome!.trim();
    }
    return 'Despesa #${titulo.id}';
  }

  String _dataExibir(String raw) {
    final texto = raw.trim();
    final iso = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(texto);
    if (iso != null) {
      return '${iso.group(3)}/${iso.group(2)}/${iso.group(1)}';
    }
    return texto;
  }

  String _meta() {
    return [
      if (titulo.dataCompetencia.isNotEmpty) _dataExibir(titulo.dataCompetencia),
      if (titulo.classificacaoNome != null && titulo.classificacaoNome!.trim().isNotEmpty)
        titulo.classificacaoNome!.trim(),
      if (titulo.categoriaNome != null &&
          titulo.categoriaNome!.trim().isNotEmpty &&
          titulo.categoriaNome!.trim() != _tituloHero())
        titulo.categoriaNome!.trim(),
    ].join(' · ');
  }

  String _valorExibir() {
    if (titulo.valorString?.trim().isNotEmpty == true) return titulo.valorString!.trim();
    return reais(titulo.valor);
  }

  String _saldoExibir() {
    if (titulo.saldoPendenteString?.trim().isNotEmpty == true) {
      return titulo.saldoPendenteString!.trim();
    }
    return reais(titulo.saldoPendente);
  }

  @override
  Widget build(BuildContext context) {
    final loja = FinanceiroEscopo.of(context);
    final parceria = loja.parceriaDetalhe?.id == parceriaId
        ? loja.parceriaDetalhe
        : loja.parcerias.where((e) => e.id == parceriaId).firstOrNull;
    final qtd = titulo.qtdAnimais ?? parceria?.qtdAnimaisDoLancamento(titulo.id) ?? 0;
    final hero = _tituloHero();
    final meta = _meta();
    final fornecedor = (titulo.parteNome == null || titulo.parteNome!.trim().isEmpty)
        ? 'Sem fornecedor'
        : titulo.parteNome!.trim();
    final contaFallback = loja.lancamentos
        .where((l) => l.id == titulo.id)
        .expand((l) => l.pagamentos)
        .map((p) => p.conta.trim())
        .where((nome) => nome.isNotEmpty)
        .toSet()
        .join(' · ');
    final conta = (titulo.contaPagamento?.trim().isNotEmpty == true)
        ? titulo.contaPagamento!.trim()
        : (contaFallback.isEmpty ? null : contaFallback);

    return Scaffold(
      backgroundColor: fundoFinanceiro,
      appBar: kIsWeb ? null : AppBar(
        backgroundColor: MyColors.colorPrimary,
        foregroundColor: Colors.white,
        title: const Text(
          'Detalhe da despesa',
          style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600),
        ),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: aoVoltar),
      ),
      body: ListView(
        primary: false,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          CartaoBranco(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE7F6EC),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.receipt_long_outlined,
                        color: MyColors.colorPrimary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hero,
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1F2A24),
                            ),
                          ),
                          if (meta.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              meta,
                              style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 12,
                                color: Color(0xFF8A8A8A),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                FlagStatusFinanceiro.titulo(
                  pago: titulo.pago,
                  parcial: titulo.parcial,
                  pendente: titulo.pendente,
                ),
                const SizedBox(height: 12),
                Text(
                  _valorExibir(),
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1F2A24),
                  ),
                ),
                if (titulo.parcial || titulo.pendente) ...[
                  const SizedBox(height: 4),
                  Text(
                    titulo.pago
                        ? 'Liquidado'
                        : 'Saldo pendente ${_saldoExibir()}',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: titulo.pendente
                          ? const Color(0xFFC45C26)
                          : MyColors.colorPrimary,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                if (titulo.parcial) ...[
                  _Linha(
                    rotulo: 'Liquidado',
                    valor: reais(titulo.valorLiquidado),
                    valorCor: MyColors.colorPrimary,
                  ),
                  _Linha(
                    rotulo: 'Pendente',
                    valor: _saldoExibir(),
                    valorCor: const Color(0xFFC45C26),
                  ),
                ],
                if (titulo.dataCompetencia.isNotEmpty)
                  _Linha(rotulo: 'Competência', valor: _dataExibir(titulo.dataCompetencia)),
                if (titulo.classificacaoNome != null &&
                    titulo.classificacaoNome!.trim().isNotEmpty)
                  _Linha(rotulo: 'Classificação', valor: titulo.classificacaoNome!.trim()),
                if (titulo.categoriaNome != null && titulo.categoriaNome!.trim().isNotEmpty)
                  _Linha(rotulo: 'Rubrica', valor: titulo.categoriaNome!.trim()),
                _Linha(rotulo: 'Fornecedor', valor: fornecedor),
                if (conta != null) _Linha(rotulo: 'Conta', valor: conta),
                _Linha(
                  rotulo: 'Animais',
                  valor: qtd > 0 ? '$qtd ${qtd == 1 ? 'animal' : 'animais'}' : '—',
                ),
              ],
            ),
          ),
          if (titulo.pendente) ...[
            const SizedBox(height: 12),
            IndicadorFaixaFinanceiro(
              rotulo: 'A pagar',
              valor: _saldoExibir(),
              fundo: const Color(0xFFFDECEC),
              letra: const Color(0xFFC62828),
            ),
            const SizedBox(height: 16),
            BotaoPrimarioFinanceiro(
              rotulo: 'Confirmar Pagamento',
              onPressed: aoPagar,
            ),
          ],
        ],
      ),
    );
  }
}

class _Linha extends StatelessWidget {
  const _Linha({
    required this.rotulo,
    required this.valor,
    this.valorCor,
  });

  final String rotulo;
  final String valor;
  final Color? valorCor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              rotulo,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 13,
                color: Color(0xFF8A8A8A),
              ),
            ),
          ),
          Flexible(
            child: Text(
              valor,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: valorCor ?? const Color(0xFF313131),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
