import 'package:costeira/core/input_formatters/brazilian_currency_input_formatter.dart';
import 'package:costeira/features/dashboard/domain/entities/dashboard_filter_entity.dart';
import 'package:costeira/features/fazendas/domain/entities/fazenda_entity.dart';
import 'package:costeira/features/financeiro/domain/financeiro_mock.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

const fundoFinanceiro = Color(0xFFF6F4EE);

const mascaraMoeda = BrazilianCurrencyInputFormatter();

MaskTextInputFormatter mascaraData() => MaskTextInputFormatter(
      mask: '##/##/####',
      filter: {'#': RegExp(r'[0-9]')},
    );

final mascaraPercentual = FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'));

TextInputType get tecladoMoeda => const TextInputType.numberWithOptions(decimal: true);

TextInputType get tecladoData => TextInputType.datetime;

String reais(num valor) {
  final negativo = valor < 0;
  final fixo = valor.abs().toStringAsFixed(2);
  final partes = fixo.split('.');
  final inteiro = partes[0];
  final buffer = StringBuffer();
  for (var i = 0; i < inteiro.length; i++) {
    final restante = inteiro.length - i;
    if (i > 0 && restante % 3 == 0) buffer.write('.');
    buffer.write(inteiro[i]);
  }
  final texto = 'R\$ $buffer,${partes[1]}';
  return negativo ? '-$texto' : texto;
}

class SecaoRotulo extends StatelessWidget {
  const SecaoRotulo(this.texto, {super.key});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      style: const TextStyle(
        fontFamily: 'Montserrat',
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
        color: Color(0xFF6B6B6B),
      ),
    );
  }
}

class GrupoChips extends StatelessWidget {
  const GrupoChips({
    super.key,
    required this.opcoes,
    required this.selecionado,
    required this.aoEscolher,
    this.travados = const {},
  });

  final List<String> opcoes;
  final String? selecionado;
  final ValueChanged<String> aoEscolher;
  final Set<String> travados;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final opcao in opcoes)
          _ChipOpcao(
            rotulo: opcao,
            ativo: opcao == selecionado,
            travado: travados.contains(opcao),
            aoToque: () => aoEscolher(opcao),
          ),
      ],
    );
  }
}

class _ChipOpcao extends StatelessWidget {
  const _ChipOpcao({
    required this.rotulo,
    required this.ativo,
    required this.travado,
    required this.aoToque,
  });

  final String rotulo;
  final bool ativo;
  final bool travado;
  final VoidCallback aoToque;

  @override
  Widget build(BuildContext context) {
    final fundo = ativo ? MyColors.colorPrimary : Colors.white;
    final letra = ativo ? Colors.white : const Color(0xFF3D5346);
    return Material(
      color: fundo,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: aoToque,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: ativo ? MyColors.colorPrimary : const Color(0xFFD7D1C4),
            ),
          ),
          child: Text(
            rotulo,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: travado && !ativo ? const Color(0xFF8A8A8A) : letra,
            ),
          ),
        ),
      ),
    );
  }
}

class CampoFinanceiro extends StatelessWidget {
  const CampoFinanceiro({
    super.key,
    required this.rotulo,
    required this.child,
  });

  final String rotulo;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SecaoRotulo(rotulo),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

/// Indicador colorido no padrão dashboard (`_Faixa`).
class IndicadorFaixaFinanceiro extends StatelessWidget {
  const IndicadorFaixaFinanceiro({
    super.key,
    required this.rotulo,
    required this.valor,
    required this.fundo,
    required this.letra,
  });

  final String rotulo;
  final String valor;
  final Color fundo;
  final Color letra;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: fundo,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(rotulo, style: TextStyle(fontFamily: 'Montserrat', fontSize: 11, color: letra)),
          const SizedBox(height: 2),
          Text(
            valor,
            style: TextStyle(fontFamily: 'Montserrat', fontSize: 14, fontWeight: FontWeight.w800, color: letra),
          ),
        ],
      ),
    );
  }
}

class FlagStatusFinanceiro extends StatelessWidget {
  const FlagStatusFinanceiro({
    super.key,
    required this.rotulo,
    this.positivo = true,
    this.cor,
  });

  final String rotulo;
  final bool positivo;
  final Color? cor;

  /// Flag de liquidação: Liquidado / Parcial / Pendente.
  factory FlagStatusFinanceiro.titulo({
    required bool pago,
    required bool parcial,
    required bool pendente,
  }) {
    if (pago) {
      return const FlagStatusFinanceiro(
        rotulo: 'Liquidado',
        positivo: true,
        cor: Color(0xFF1B7A4A),
      );
    }
    if (parcial) {
      return const FlagStatusFinanceiro(
        rotulo: 'Parcial',
        positivo: false,
        cor: Color(0xFFC45C26),
      );
    }
    return FlagStatusFinanceiro(
      rotulo: pendente ? 'Pendente' : '—',
      positivo: false,
      cor: const Color(0xFFC9A227),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tom = cor ?? (positivo ? MyColors.colorPrimary : const Color(0xFFC62828));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: tom.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        rotulo,
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: tom,
        ),
      ),
    );
  }
}

InputDecoration decoracaoCampo(String hint) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 13,
      color: Color(0xFF8A8A8A),
    ),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE6E6E6)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE6E6E6)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: MyColors.colorPrimary),
    ),
  );
}

/// Campo select no padrão financeiro (tap → bottom sheet). Evita overflow do DropdownButton.
class CampoEscolhaFinanceiro extends StatelessWidget {
  const CampoEscolhaFinanceiro({
    super.key,
    required this.valor,
    required this.placeholder,
    this.habilitado = true,
    this.onTap,
  });

  final String valor;
  final String placeholder;
  final bool habilitado;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final vazio = valor.trim().isEmpty;
    return Material(
      color: habilitado ? Colors.white : const Color(0xFFF3F3F3),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: habilitado ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE6E6E6)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  vazio ? placeholder : valor,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 14,
                    fontWeight: vazio ? FontWeight.w500 : FontWeight.w600,
                    color: !habilitado || vazio ? const Color(0xFF8A8A8A) : const Color(0xFF313131),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: habilitado ? MyColors.colorPrimary : const Color(0xFFB0B0B0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<T?> abrirOpcoesFinanceiro<T>({
  required BuildContext context,
  required String titulo,
  required List<({T value, String label})> opcoes,
  T? atual,
}) {
  if (opcoes.isEmpty) return Future.value(null);
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
      final maxH = MediaQuery.sizeOf(ctx).height * 0.55;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9D9D9),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                titulo,
                style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700, fontSize: 16),
              ),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: maxH),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: opcoes.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (_, index) {
                    final item = opcoes[index];
                    final marcada = item.value == atual;
                    return Material(
                      color: marcada ? const Color(0xFFE7F6EC) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () => Navigator.pop(ctx, item.value),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: marcada ? MyColors.colorPrimary : const Color(0xFFE6E6E6),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.label,
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontWeight: marcada ? FontWeight.w700 : FontWeight.w600,
                                    fontSize: 14,
                                    color: const Color(0xFF313131),
                                  ),
                                ),
                              ),
                              if (marcada)
                                const Icon(Icons.check_circle, color: MyColors.colorPrimary, size: 20),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class CartaoBranco extends StatelessWidget {
  const CartaoBranco({super.key, required this.child, this.aoToque});

  final Widget child;
  final VoidCallback? aoToque;

  @override
  Widget build(BuildContext context) {
    final miolo = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE6E6E6)),
      ),
      child: child,
    );
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      // Sem InkWell quando não há toque: dropdown/select interno precisa do gesto.
      child: aoToque == null
          ? miolo
          : InkWell(
              onTap: aoToque,
              borderRadius: BorderRadius.circular(16),
              child: miolo,
            ),
    );
  }
}

class OpcaoCartaoFinanceiro extends StatelessWidget {
  const OpcaoCartaoFinanceiro({
    super.key,
    required this.titulo,
    required this.icone,
    required this.selecionado,
    required this.aoToque,
    this.subtitulo,
    this.travado = false,
    this.corAccent,
  });

  final String titulo;
  final IconData icone;
  final bool selecionado;
  final VoidCallback aoToque;
  final String? subtitulo;
  final bool travado;
  final Color? corAccent;

  @override
  Widget build(BuildContext context) {
    final accent = corAccent ?? MyColors.colorPrimary;
    final fundo = selecionado
        ? accent.withValues(alpha: 0.10)
        : travado
            ? const Color(0xFFF3F1EB)
            : const Color(0xFFF8F7F3);
    final borda = selecionado
        ? accent
        : travado
            ? const Color(0xFFE4E0D6)
            : const Color(0xFFE8E4DA);
    final letra = travado && !selecionado
        ? const Color(0xFF8A8A8A)
        : selecionado
            ? accent
            : const Color(0xFF2F3B34);
    final iconeFundo = selecionado ? accent : Colors.white;
    final iconeCor = selecionado ? Colors.white : (travado ? const Color(0xFF9A958A) : accent);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: fundo,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: aoToque,
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borda, width: selecionado ? 1.5 : 1),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconeFundo,
                    borderRadius: BorderRadius.circular(12),
                    border: selecionado ? null : Border.all(color: const Color(0xFFE6E2D8)),
                    boxShadow: selecionado
                        ? [BoxShadow(color: accent.withValues(alpha: 0.22), blurRadius: 8, offset: const Offset(0, 2))]
                        : null,
                  ),
                  child: Icon(icone, size: 20, color: iconeCor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 14,
                          fontWeight: selecionado ? FontWeight.w700 : FontWeight.w600,
                          color: letra,
                        ),
                      ),
                      if (subtitulo != null && subtitulo!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitulo!,
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: travado ? const Color(0xFF9A958A) : const Color(0xFF7A7A7A),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (selecionado)
                  Icon(Icons.check_circle_rounded, color: accent, size: 22)
                else if (travado)
                  const Icon(Icons.lock_outline_rounded, color: Color(0xFFB0AAA0), size: 18)
                else
                  const Icon(Icons.chevron_right_rounded, color: Color(0xFFC5C0B5), size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

IconData iconeTipoLancamento(String id) {
  switch (id) {
    case 'recebimento':
      return Icons.south_west_rounded;
    case 'pagamento':
      return Icons.north_east_rounded;
    case 'investimento':
      return Icons.savings_outlined;
    case 'estoque':
      return Icons.inventory_2_outlined;
    default:
      return Icons.category_outlined;
  }
}

Color corTipoLancamento(String id) {
  switch (id) {
    case 'recebimento':
      return const Color(0xFF1B7A4A);
    case 'pagamento':
      return const Color(0xFFC45C26);
    case 'investimento':
      return const Color(0xFF2F6FED);
    case 'estoque':
      return const Color(0xFF6B5B3E);
    default:
      return MyColors.colorPrimary;
  }
}

IconData iconePorTextoFinanceiro(String texto) {
  final t = texto.toLowerCase();
  if (t.contains('receita') || t.contains('receb')) return Icons.trending_up_rounded;
  if (t.contains('operacional') && t.contains('não')) return Icons.account_balance_wallet_outlined;
  if (t.contains('nao operacional') || t.contains('não operacional')) return Icons.account_balance_wallet_outlined;
  if (t.contains('fixo')) return Icons.home_work_outlined;
  if (t.contains('variavel') || t.contains('variável')) return Icons.grass_outlined;
  if (t.contains('financeiro') || t.contains('juros') || t.contains('dívida') || t.contains('divida')) {
    return Icons.percent_rounded;
  }
  if (t.contains('quitação') || t.contains('quitacao') || t.contains('dívida')) return Icons.paid_outlined;
  if (t.contains('venda') || t.contains('boi') || t.contains('novilh') || t.contains('terneir') || t.contains('vaca') || t.contains('touro')) {
    return Icons.pets_outlined;
  }
  if (t.contains('leite') || t.contains('derivad') || t.contains('queijo')) return Icons.water_drop_outlined;
  if (t.contains('suplement') || t.contains('ração') || t.contains('racao') || t.contains('nutri')) {
    return Icons.restaurant_outlined;
  }
  if (t.contains('sanit') || t.contains('vacina') || t.contains('veterin')) return Icons.medical_services_outlined;
  if (t.contains('diesel') || t.contains('combust')) return Icons.local_gas_station_outlined;
  if (t.contains('frete') || t.contains('comiss')) return Icons.local_shipping_outlined;
  if (t.contains('folha') || t.contains('salário') || t.contains('salario') || t.contains('pró-labore') || t.contains('pro-labore')) {
    return Icons.badge_outlined;
  }
  if (t.contains('luz') || t.contains('energia')) return Icons.bolt_outlined;
  if (t.contains('internet')) return Icons.wifi_rounded;
  if (t.contains('arrend')) return Icons.landscape_outlined;
  if (t.contains('imposto') || t.contains('taxa')) return Icons.receipt_long_outlined;
  if (t.contains('manuten')) return Icons.build_outlined;
  if (t.contains('pastag') || t.contains('aduba') || t.contains('semente')) return Icons.eco_outlined;
  if (t.contains('estoque') || t.contains('insumo')) return Icons.inventory_2_outlined;
  if (t.contains('invest')) return Icons.savings_outlined;
  return Icons.label_outline_rounded;
}

class RodapeAcoesFinanceiro extends StatelessWidget {
  const RodapeAcoesFinanceiro({super.key, required this.filhos});

  final List<Widget> filhos;

  @override
  Widget build(BuildContext context) {
    final teclado = MediaQuery.of(context).viewInsets.bottom;
    return Material(
      color: Colors.white,
      elevation: 10,
      shadowColor: Colors.black26,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + teclado),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < filhos.length; i++) ...[
                if (i > 0) const SizedBox(height: 8),
                filhos[i],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class BotaoPrimarioFinanceiro extends StatelessWidget {
  const BotaoPrimarioFinanceiro({
    super.key,
    required this.rotulo,
    required this.onPressed,
    this.carregando = false,
    this.habilitado = true,
  });

  final String rotulo;
  final VoidCallback? onPressed;
  final bool carregando;
  final bool habilitado;

  @override
  Widget build(BuildContext context) {
    final ativo = habilitado && !carregando && onPressed != null;
    return FilledButton(
      onPressed: ativo ? onPressed : null,
      style: FilledButton.styleFrom(
        backgroundColor: MyColors.colorPrimary,
        disabledBackgroundColor: MyColors.colorPrimary.withValues(alpha: 0.45),
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: carregando
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
            )
          : Text(rotulo, style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600)),
    );
  }
}

class LoadingFinanceiro extends StatelessWidget {
  const LoadingFinanceiro({super.key, this.altura = 120, this.rotulo});

  final double altura;
  final String? rotulo;

  @override
  Widget build(BuildContext context) {
    final compacto = altura < 72;
    return SizedBox(
      height: altura,
      child: Center(
        child: compacto
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: altura < 40 ? 18 : 22,
                    height: altura < 40 ? 18 : 22,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: MyColors.colorPrimary,
                    ),
                  ),
                  if (rotulo != null) ...[
                    const SizedBox(width: 10),
                    Text(
                      rotulo!,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 12,
                        color: Color(0xFF8692A8),
                      ),
                    ),
                  ],
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.6,
                      color: MyColors.colorPrimary,
                    ),
                  ),
                  if (rotulo != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      rotulo!,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 12,
                        color: Color(0xFF8692A8),
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}

class ContextoFinanceiroFiltros extends StatelessWidget {
  const ContextoFinanceiroFiltros({super.key, this.mostrarAno = true});

  final bool mostrarAno;

  @override
  Widget build(BuildContext context) {
    final loja = FinanceiroEscopo.of(context);
    return Row(
      children: [
        Expanded(
          child: _PillContexto(
            icone: Icons.warehouse_outlined,
            rotulo: loja.fazendaNome,
            onTap: () => _escolherFazenda(context, loja),
          ),
        ),
        if (mostrarAno) ...[
          const SizedBox(width: 8),
          Expanded(
            child: _PillContexto(
              icone: Icons.calendar_today_outlined,
              rotulo: loja.anoAgricolaLabel,
              onTap: () => _escolherAno(context, loja),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _escolherFazenda(BuildContext context, FinanceiroLoja loja) async {
    if (loja.fazendas.isEmpty) return;
    final id = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheet) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Escolher fazenda', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: loja.fazendas.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, index) {
                      final farm = loja.fazendas[index];
                      final selecionada = farm.id == loja.fazendaId;
                      return _OpcaoContexto(
                        titulo: _nomeFazenda(farm),
                        selecionada: selecionada,
                        onTap: () => Navigator.pop(sheet, farm.id),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (id == null) return;
    await loja.selecionarFazenda(id);
  }

  Future<void> _escolherAno(BuildContext context, FinanceiroLoja loja) async {
    final anos = loja.anosAgricolas;
    if (anos.isEmpty) return;
    final escolhido = await showModalBottomSheet<AgriculturalYearRange>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheet) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ano agrícola', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 12),
                for (final ano in anos) ...[
                  _OpcaoContexto(
                    titulo: ano.label,
                    selecionada: ano.label == loja.anoAgricola?.label,
                    onTap: () => Navigator.pop(sheet, ano),
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),
        );
      },
    );
    if (escolhido == null) return;
    await loja.selecionarAnoAgricola(escolhido);
  }

  String _nomeFazenda(FazendaEntity farm) {
    final nome = farm.nome.trim().isNotEmpty ? farm.nome.trim() : farm.nomeFantasia.trim();
    return nome.isEmpty ? 'Fazenda ${farm.id}' : nome;
  }
}

class _PillContexto extends StatelessWidget {
  const _PillContexto({required this.icone, required this.rotulo, required this.onTap});

  final IconData icone;
  final String rotulo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE6E6E6)),
          ),
          child: Row(
            children: [
              Icon(icone, size: 14, color: MyColors.colorPrimary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  rotulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontFamily: 'Montserrat', fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
              const Icon(Icons.expand_more, size: 16, color: Color(0xFF8A8A8A)),
            ],
          ),
        ),
      ),
    );
  }
}

class _OpcaoContexto extends StatelessWidget {
  const _OpcaoContexto({required this.titulo, required this.selecionada, required this.onTap});

  final String titulo;
  final bool selecionada;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selecionada ? const Color(0xFFE7F6EC) : Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: selecionada ? MyColors.colorPrimary : const Color(0xFFE6E6E6)),
          ),
          child: Text(
            titulo,
            style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ),
      ),
    );
  }
}

Future<void> avisoDesenvolvimento(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text(
        'Em desenvolvimento',
        style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700),
      ),
      content: const Text(
        'Esse tipo de lançamento ainda não está disponível.',
        style: TextStyle(fontFamily: 'Montserrat'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Ok'),
        ),
      ],
    ),
  );
}

Future<ContaMock?> escolherContaFinanceiro(
  BuildContext context, {
  required List<ContaMock> contas,
  ContaMock? selecionada,
  String titulo = 'Escolher conta',
}) {
  if (contas.isEmpty) return Future.value(null);
  return showModalBottomSheet<ContaMock>(
    context: context,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (sheet) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9D9D9),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                titulo,
                style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700, fontSize: 16),
              ),
              const SizedBox(height: 4),
              const Text(
                'Saldo atual de cada conta',
                style: TextStyle(fontFamily: 'Montserrat', fontSize: 12, color: Color(0xFF8A8A8A)),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: contas.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, index) {
                    final conta = contas[index];
                    final marcada = selecionada?.id == conta.id;
                    final saldoNegativo = conta.saldo < 0;
                    return Material(
                      color: marcada ? const Color(0xFFE7F6EC) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () => Navigator.pop(sheet, conta),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: marcada ? MyColors.colorPrimary : const Color(0xFFE6E6E6),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: marcada ? const Color(0xFFD7F0E0) : const Color(0xFFF3F3F3),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  conta.tipo.toLowerCase().contains('caixa')
                                      ? Icons.payments_outlined
                                      : Icons.account_balance_outlined,
                                  size: 20,
                                  color: MyColors.colorPrimary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      conta.nome,
                                      style: const TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      conta.tipo,
                                      style: const TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 11,
                                        color: Color(0xFF8A8A8A),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                reais(conta.saldo),
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  color: saldoNegativo ? const Color(0xFFC62828) : MyColors.colorPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class SeletorContaFinanceiro extends StatelessWidget {
  const SeletorContaFinanceiro({
    super.key,
    required this.contas,
    required this.selecionada,
    required this.onChanged,
    this.hint = 'Selecionar conta',
  });

  final List<ContaMock> contas;
  final ContaMock? selecionada;
  final ValueChanged<ContaMock> onChanged;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final conta = selecionada;
    final saldoNegativo = (conta?.saldo ?? 0) < 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: contas.isEmpty
                ? null
                : () async {
                    final escolhida = await escolherContaFinanceiro(
                      context,
                      contas: contas,
                      selecionada: conta,
                    );
                    if (escolhida != null) onChanged(escolhida);
                  },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE6E6E6)),
              ),
              child: Row(
                children: [
                  Icon(
                    conta == null
                        ? Icons.account_balance_wallet_outlined
                        : (conta.tipo.toLowerCase().contains('caixa')
                            ? Icons.payments_outlined
                            : Icons.account_balance_outlined),
                    size: 20,
                    color: MyColors.colorPrimary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      conta?.nome ?? hint,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 14,
                        fontWeight: conta == null ? FontWeight.w500 : FontWeight.w700,
                        color: conta == null ? const Color(0xFF8A8A8A) : const Color(0xFF1F2A24),
                      ),
                    ),
                  ),
                  const Icon(Icons.expand_more, size: 20, color: Color(0xFF8A8A8A)),
                ],
              ),
            ),
          ),
        ),
        if (conta != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: saldoNegativo ? const Color(0xFFFDECEC) : const Color(0xFFE7F6EC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: saldoNegativo ? const Color(0xFFF5C2C2) : const Color(0xFFCDEAD7),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.savings_outlined,
                  size: 18,
                  color: saldoNegativo ? const Color(0xFFC62828) : MyColors.colorPrimary,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Saldo da conta',
                    style: TextStyle(fontFamily: 'Montserrat', fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  reais(conta.saldo),
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: saldoNegativo ? const Color(0xFFC62828) : MyColors.colorPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
