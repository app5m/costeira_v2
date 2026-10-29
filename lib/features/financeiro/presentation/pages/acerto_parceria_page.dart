import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/features/financeiro/domain/financeiro_mock.dart';
import 'package:costeira/features/financeiro/presentation/widgets/financeiro_ui.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class AcertoParceriaPage extends StatefulWidget {
  const AcertoParceriaPage({
    super.key,
    required this.parceriaId,
    required this.vendaId,
    required this.aoVoltar,
    required this.aoConfirmado,
  });

  final int parceriaId;
  final int vendaId;
  final VoidCallback aoVoltar;
  final VoidCallback aoConfirmado;

  @override
  State<AcertoParceriaPage> createState() => _AcertoParceriaPageState();
}

class _AcertoParceriaPageState extends State<AcertoParceriaPage> {
  final _data = TextEditingController();
  late final MaskTextInputFormatter _maskData = mascaraData();
  Map<String, dynamic>? _simulacao;
  bool _carregando = true;
  bool _confirmando = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    final agora = DateTime.now();
    _data.text =
        '${agora.day.toString().padLeft(2, '0')}/${agora.month.toString().padLeft(2, '0')}/${agora.year}';
    WidgetsBinding.instance.addPostFrameCallback((_) => _simular());
  }

  @override
  void dispose() {
    _data.dispose();
    super.dispose();
  }

  Future<void> _simular() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final mapa = await FinanceiroEscopo.of(context).simularApuracaoParceria(
        vendaId: widget.vendaId,
        data: _data.text.trim().isEmpty ? null : _data.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        _simulacao = mapa;
        _carregando = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      final msg = error.message.toLowerCase();
      // API já confirmou: lista às vezes não traz flag — manda pro financeiro.
      if (msg.contains('já possui apuração') ||
          msg.contains('ja possui apuracao') ||
          msg.contains('apuracao confirmada') ||
          msg.contains('apuração confirmada')) {
        FinanceiroEscopo.of(context).marcarVendaAcertada(
          parceriaId: widget.parceriaId,
          vendaId: widget.vendaId,
        );
        widget.aoConfirmado();
        return;
      }
      setState(() {
        _erro = error.message;
        _carregando = false;
        _simulacao = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _erro = 'Não foi possível simular o acerto.';
        _carregando = false;
        _simulacao = null;
      });
    }
  }

  String _texto(dynamic valor) {
    if (valor == null) return '—';
    final s = valor.toString().trim();
    return s.isEmpty ? '—' : s;
  }

  dynamic _buscarCampo(String chave, [String? stringKey]) {
    final mapa = _simulacao;
    if (mapa == null) return null;

    final aliases = <String, List<String>>{
      'capital': ['capital_investidor'],
      'capital_investidor': ['capital'],
      'reembolso': ['reembolso_custo'],
      'reembolso_custo': ['reembolso'],
    };

    dynamic em(Map fonte, String k, [String? sk]) {
      if (sk != null) {
        final preferido = fonte[sk];
        if (preferido != null && preferido.toString().trim().isNotEmpty) {
          return preferido;
        }
      }
      final bruto = fonte[k];
      if (bruto != null && bruto.toString().trim().isNotEmpty) return bruto;
      return null;
    }

    dynamic procurar(String k, [String? sk]) {
      final direto = em(mapa, k, sk);
      if (direto != null) return direto;
      for (final nestedKey in const [
        'totais',
        'resumo',
        'indicadores',
        'dados',
        'data',
        'apuracao',
        'simulacao',
        'resultado',
      ]) {
        final nested = mapa[nestedKey];
        if (nested is Map) {
          final achou = em(Map<String, dynamic>.from(nested), k, sk);
          if (achou != null) return achou;
        }
      }
      return null;
    }

    final direto = procurar(chave, stringKey);
    if (direto != null) return direto;

    for (final alt in aliases[chave] ?? const <String>[]) {
      final achou = procurar(alt, '${alt}_string');
      if (achou != null) return achou;
    }
    return null;
  }

  double? _numeroCampo(String chave) {
    // Preferir chave numérica (sem _string) p/ sinal correto.
    return _paraNumero(_buscarCampo(chave));
  }

  double? _paraNumero(dynamic bruto) {
    if (bruto == null) return null;
    if (bruto is num) return bruto.toDouble();
    final texto = bruto.toString().trim();
    if (texto.isEmpty) return null;
    final limpo = texto.replaceAll(RegExp(r'[^\d,.-]'), '');
    if (limpo.isEmpty) return null;
    if (limpo.contains(',') && limpo.contains('.')) {
      return double.tryParse(limpo.replaceAll('.', '').replaceAll(',', '.'));
    }
    if (limpo.contains(',')) {
      return double.tryParse(limpo.replaceAll(',', '.'));
    }
    return double.tryParse(limpo);
  }

  String _linha(String chave, [String? stringKey]) {
    final bruto = _buscarCampo(chave, stringKey);
    if (bruto == null) return '—';
    if (bruto is num) return reais(bruto.toDouble());
    final texto = bruto.toString().trim();
    if (texto.contains('R\$') || texto.contains('r\$')) return texto;
    final n = _paraNumero(bruto);
    if (n != null) return reais(n);
    return _texto(bruto);
  }

  Color _corSinal(double? n) {
    if (n == null) return const Color(0xFF313131);
    if (n > 0) return const Color(0xFF1B7A4A);
    if (n < 0) return const Color(0xFFC62828);
    return const Color(0xFF6B6B6B);
  }

  bool get _vendaJaAcertada {
    final loja = FinanceiroEscopo.of(context);
    final parceria = loja.parceriaDetalhe?.id == widget.parceriaId
        ? loja.parceriaDetalhe
        : loja.parcerias.where((e) => e.id == widget.parceriaId).firstOrNull;
    final venda = parceria?.vendas.where((v) => v.id == widget.vendaId).firstOrNull;
    return venda?.acertoConfirmado == true;
  }

  Future<void> _confirmar() async {
    if (_vendaJaAcertada) {
      AppSnackBar.show(context: context, message: 'Esta venda já tem acerto confirmado.');
      widget.aoConfirmado();
      return;
    }
    final hash = _simulacao?['hash_simulacao']?.toString();
    if (hash == null || hash.isEmpty) {
      AppSnackBar.show(context: context, message: 'Simule o acerto antes de confirmar.');
      return;
    }
    if (_confirmando) return;
    setState(() => _confirmando = true);
    try {
      await FinanceiroEscopo.of(context).confirmarApuracaoParceria(
        parceriaId: widget.parceriaId,
        vendaId: widget.vendaId,
        data: _data.text.trim(),
        hashSimulacao: hash,
      );
      if (!mounted) return;
      AppSnackBar.show(context: context, message: 'Acerto confirmado.', isError: false);
      widget.aoConfirmado();
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _confirmando = false);
      AppSnackBar.show(context: context, message: error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _confirmando = false);
      AppSnackBar.show(context: context, message: 'Não foi possível confirmar o acerto.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final itens = _simulacao?['itens'];
    final listaItens = itens is List ? itens : const [];

    return Scaffold(
      backgroundColor: fundoFinanceiro,
      appBar: AppBar(
        backgroundColor: MyColors.colorPrimary,
        foregroundColor: Colors.white,
        title: const Text('Conferir acerto', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: _confirmando ? null : widget.aoVoltar),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          CampoFinanceiro(
            rotulo: 'DATA DO ACERTO',
            child: TextField(
              controller: _data,
              inputFormatters: [_maskData],
              keyboardType: tecladoData,
              decoration: decoracaoCampo('DD/MM/AAAA'),
              onChanged: (_) {},
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _carregando || _confirmando ? null : _simular,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Recalcular', style: TextStyle(fontFamily: 'Montserrat')),
            ),
          ),
          if (_carregando)
            const LoadingFinanceiro(altura: 160, rotulo: 'Simulando acerto…')
          else if (_erro != null)
            CartaoBranco(
              child: Text(_erro!, style: const TextStyle(fontFamily: 'Montserrat', color: Color(0xFFC62828))),
            )
          else if (_simulacao != null) ...[
            CartaoBranco(
              child: Column(
                children: [
                  _Linha(
                    'Receita bruta',
                    _linha('receita_bruta', 'receita_bruta_string'),
                    cor: _corSinal(_numeroCampo('receita_bruta')),
                  ),
                  _Linha(
                    'Capital',
                    _linha('capital_investidor', 'capital_investidor_string'),
                    cor: _corSinal(_numeroCampo('capital_investidor')),
                  ),
                  _Linha(
                    'Ganho total',
                    _linha('ganho_valor', 'ganho_valor_string'),
                    cor: _corSinal(_numeroCampo('ganho_valor')),
                  ),
                  _Linha(
                    'Ganho investidor',
                    _linha('ganho_investidor', 'ganho_investidor_string'),
                    cor: _corSinal(_numeroCampo('ganho_investidor')),
                  ),
                  _Linha(
                    'Ganho fazenda',
                    _linha('ganho_fazenda', 'ganho_fazenda_string'),
                    cor: _corSinal(_numeroCampo('ganho_fazenda')),
                  ),
                  _Linha(
                    'Custo operacional',
                    _linha('custo_operacional', 'custo_operacional_string'),
                    cor: const Color(0xFFC45C26),
                  ),
                  _Linha(
                    'Reembolso',
                    _linha('reembolso_custo', 'reembolso_custo_string'),
                    cor: _corSinal(_numeroCampo('reembolso_custo')),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _MargemFazendaCard(
              valorTexto: _linha('margem_fazenda', 'margem_fazenda_string'),
              valor: _numeroCampo('margem_fazenda'),
            ),
            if (listaItens.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Itens',
                style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700, fontSize: 15),
              ),
              const SizedBox(height: 8),
              for (final item in listaItens)
                if (item is Map) ...[
                  _ItemAcertoCard(item: Map<String, dynamic>.from(item)),
                  const SizedBox(height: 8),
                ],
            ],
            const SizedBox(height: 16),
            if (_vendaJaAcertada)
              CartaoBranco(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Acerto já confirmado para esta venda. Não é possível confirmar de novo.',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4A4A4A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    BotaoPrimarioFinanceiro(
                      rotulo: 'Ver financeiro',
                      onPressed: widget.aoConfirmado,
                    ),
                  ],
                ),
              )
            else
              BotaoPrimarioFinanceiro(
                rotulo: 'Confirmar acerto',
                carregando: _confirmando,
                onPressed: _confirmar,
              ),
          ],
        ],
      ),
    );
  }
}

Color _corSinalValor(double? n) {
  if (n == null) return const Color(0xFF313131);
  if (n > 0) return const Color(0xFF1B7A4A);
  if (n < 0) return const Color(0xFFC62828);
  return const Color(0xFF6B6B6B);
}

double? _numeroDeMapa(Map fonte, String chave) {
  final bruto = fonte[chave];
  if (bruto == null) return null;
  if (bruto is num) return bruto.toDouble();
  final texto = bruto.toString().trim();
  if (texto.isEmpty) return null;
  final limpo = texto.replaceAll(RegExp(r'[^\d,.-]'), '');
  if (limpo.isEmpty) return null;
  if (limpo.contains(',') && limpo.contains('.')) {
    return double.tryParse(limpo.replaceAll('.', '').replaceAll(',', '.'));
  }
  if (limpo.contains(',')) return double.tryParse(limpo.replaceAll(',', '.'));
  return double.tryParse(limpo);
}

String _textoMoedaItem(Map item, String chave) {
  final s = item['${chave}_string']?.toString().trim();
  if (s != null && s.isNotEmpty) return s;
  final n = _numeroDeMapa(item, chave);
  if (n != null) return reais(n);
  return '—';
}

class _Linha extends StatelessWidget {
  const _Linha(this.rotulo, this.valor, {this.cor});

  final String rotulo;
  final String valor;
  final Color? cor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              rotulo,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF4A4A4A),
              ),
            ),
          ),
          Text(
            valor,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w700,
              color: cor ?? const Color(0xFF313131),
            ),
          ),
        ],
      ),
    );
  }
}

class _MargemFazendaCard extends StatelessWidget {
  const _MargemFazendaCard({required this.valorTexto, required this.valor});

  final String valorTexto;
  final double? valor;

  @override
  Widget build(BuildContext context) {
    final cor = _corSinalValor(valor);
    final positivo = (valor ?? 0) > 0;
    final negativo = (valor ?? 0) < 0;
    final fundo = negativo
        ? const Color(0xFFFDECEC)
        : positivo
            ? const Color(0xFFE7F6EC)
            : const Color(0xFFF3F1EB);
    final borda = negativo
        ? const Color(0xFFF5C2C2)
        : positivo
            ? const Color(0xFFCDEAD7)
            : const Color(0xFFE4E0D6);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: fundo,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borda),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: cor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              negativo
                  ? Icons.trending_down_rounded
                  : positivo
                      ? Icons.trending_up_rounded
                      : Icons.remove_rounded,
              color: cor,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Margem da fazenda',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF5A5A5A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  valorTexto,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: cor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemAcertoCard extends StatelessWidget {
  const _ItemAcertoCard({required this.item});

  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final margem = _numeroDeMapa(item, 'margem_fazenda');
    final corMargem = _corSinalValor(margem);
    final brinco = item['brinco']?.toString() ??
        (item['app_animais_id'] == null ? 'Animal' : 'Animal #${item['app_animais_id']}');
    final categoria = item['categoria_nome']?.toString().trim();

    return CartaoBranco(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      brinco,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    if (categoria != null && categoria.isNotEmpty)
                      Text(
                        categoria,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 12,
                          color: Color(0xFF8A8A8A),
                        ),
                      ),
                  ],
                ),
              ),
              Text(
                _textoMoedaItem(item, 'margem_fazenda'),
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: corMargem,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _MiniLinha('Receita', _textoMoedaItem(item, 'receita_bruta'), _corSinalValor(_numeroDeMapa(item, 'receita_bruta'))),
          _MiniLinha('Capital', _textoMoedaItem(item, 'capital_investidor'), _corSinalValor(_numeroDeMapa(item, 'capital_investidor'))),
          _MiniLinha('Ganho', _textoMoedaItem(item, 'ganho_valor'), _corSinalValor(_numeroDeMapa(item, 'ganho_valor'))),
          _MiniLinha(
            'Custo',
            _textoMoedaItem(item, 'custo_operacional'),
            const Color(0xFFC45C26),
          ),
        ],
      ),
    );
  }
}

class _MiniLinha extends StatelessWidget {
  const _MiniLinha(this.rotulo, this.valor, this.cor);

  final String rotulo;
  final String valor;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              rotulo,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 12,
                color: Color(0xFF8A8A8A),
              ),
            ),
          ),
          Text(
            valor,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: cor,
            ),
          ),
        ],
      ),
    );
  }
}
