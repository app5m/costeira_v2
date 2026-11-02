import 'package:costeira/app/app_routes.dart';
import 'package:costeira/core/menus/app_menus_controller.dart';
import 'package:costeira/core/api/api_client.dart';
import 'package:costeira/core/menus/menu_action_resolver.dart';
import 'package:costeira/features/financeiro/infra/financeiro_api.dart';
import 'package:costeira/features/financeiro/presentation/financeiro_acesso.dart';
import 'package:costeira/features/financeiro/presentation/financeiro_shell_page.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CartaoFinanceiroDashboard extends StatefulWidget {
  const CartaoFinanceiroDashboard({
    super.key,
    this.onAbrir,
    this.onNovoLancamento,
  });

  /// Quando informado (ex.: web), abre o ambiente financeiro sem rota mobile.
  final VoidCallback? onAbrir;
  final VoidCallback? onNovoLancamento;

  @override
  State<CartaoFinanceiroDashboard> createState() =>
      _CartaoFinanceiroDashboardState();
}

class _CartaoFinanceiroDashboardState extends State<CartaoFinanceiroDashboard> {
  late final AppMenusController _menus;
  String _saldo = r'R$ 0,00';
  String _pagar = r'R$ 0,00';
  String _receber = r'R$ 0,00';

  @override
  void initState() {
    super.initState();
    _menus = Modular.get<AppMenusController>();
    _menus.addListener(_atualizar);
    // No dashboard web os dados completos são carregados pelo ambiente
    // Financeiro. Evita uma segunda chamada concorrente durante a montagem
    // do dashboard, que pode deixar o PageView sem conteúdo em caso de sessão
    // ainda não pronta. O fluxo mobile permanece inalterado.
    if (!kIsWeb) {
      _carregar();
    }
  }

  Future<void> _carregar() async {
    final api = FinanceiroApi(ApiClient.instance);
    try {
      final fluxo = await api.fluxo();
      final lista = await api.lancamentos(limite: 50);
      if (!mounted) {
        return;
      }
      final dados = lista['dados'];
      var pagar = 0.0;
      var receber = 0.0;
      if (dados is List) {
        for (final item in dados) {
          if (item is! Map) continue;
          final estado = item['estado']?.toString() ?? '';
          if (estado == 'rascunho' ||
              estado == 'estornado' ||
              estado == 'cancelado') {
            continue;
          }
          final pendente =
              double.tryParse(item['saldo_pendente']?.toString() ?? '') ??
              ((double.tryParse(item['valor']?.toString() ?? '') ?? 0) -
                  (double.tryParse(item['valor_liquidado']?.toString() ?? '') ??
                      0));
          if (pendente <= 0) continue;
          if ((item['tipo']?.toString() ?? '').toLowerCase() == 'recebimento') {
            receber += pendente;
          } else {
            pagar += pendente;
          }
        }
      }
      setState(() {
        _saldo =
            fluxo['indicadores']?['saldo_disponivel_string']?.toString() ??
            _saldo;
        _pagar = _reais(pagar);
        _receber = _reais(receber);
      });
    } catch (_) {}
  }

  String _reais(double valor) {
    final texto = valor.toStringAsFixed(2).replaceAll('.', ',');
    return 'R\$ $texto';
  }

  @override
  void dispose() {
    _menus.removeListener(_atualizar);
    super.dispose();
  }

  void _atualizar() {
    if (mounted) setState(() {});
  }

  void _abrir({required bool form}) {
    final callback = form ? widget.onNovoLancamento : widget.onAbrir;
    if (callback != null) {
      callback();
      return;
    }
    if (kIsWeb) {
      MenuActionResolver.showDevelopmentDialog(
        context,
        moduleName: 'Financeiro',
      );
      return;
    }
    Modular.to.pushNamed(
      AppRoutes.financeiro,
      arguments: form
          ? const FinanceiroAbrir.form()
          : const FinanceiroAbrir.modulo(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!podeVerFinanceiro(_menus)) return const SizedBox.shrink();
    // O cartão original é mantido no fluxo mobile. A composição nova fica
    // restrita ao dashboard web para não alterar a experiência existente.
    return kIsWeb ? _buildWeb() : _buildMobile();
  }

  Widget _buildMobile() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E4D9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0x1400823A),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  LucideIcons.wallet,
                  size: 16,
                  color: MyColors.colorPrimary,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Financeiro',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF313131),
                  ),
                ),
              ),
              InkWell(
                onTap: () => _abrir(form: false),
                child: const Text(
                  'Ver financeiro >',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: MyColors.colorPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Saldo disponível',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 12,
              color: Color(0xFF8A8A8A),
            ),
          ),
          Text(
            _saldo,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1C1C1C),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _Faixa(
                  rotulo: 'A pagar no período',
                  valor: _pagar,
                  fundo: const Color(0xFFFDECEC),
                  letra: const Color(0xFFC62828),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Faixa(
                  rotulo: 'A receber no período',
                  valor: _receber,
                  fundo: const Color(0xFFE7F6EC),
                  letra: MyColors.colorPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _abrir(form: true),
            icon: const Icon(Icons.add, size: 16),
            label: const Text(
              'Novo lançamento',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: MyColors.colorPrimary,
              minimumSize: const Size.fromHeight(44),
              side: const BorderSide(color: Color(0xFFD7E8DC)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeb() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compacto = constraints.maxWidth < 760;
        final acaoCompacta = constraints.maxWidth < 500;
        return Container(
          padding: EdgeInsets.fromLTRB(
            compacto ? 16 : 20,
            compacto ? 16 : 18,
            compacto ? 16 : 20,
            compacto ? 16 : 18,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE1E5DE)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 18,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0x142F7A4A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      LucideIcons.walletCards,
                      size: 19,
                      color: MyColors.colorPrimary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Financeiro',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF263A2C),
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Resumo financeiro do período selecionado',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 11,
                            color: Color(0xFF7B827D),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (acaoCompacta)
                    IconButton(
                      tooltip: 'Ver financeiro',
                      onPressed: () => _abrir(form: false),
                      color: MyColors.colorPrimary,
                      icon: const Icon(LucideIcons.arrowUpRight, size: 18),
                    )
                  else ...[
                    SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () => _abrir(form: false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: MyColors.colorPrimary,
                          side: const BorderSide(color: Color(0xFFC9D4CB)),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(11),
                          ),
                          textStyle: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: const Text('Ver financeiro'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 190,
                      child: _BotaoNovoLancamento(
                        onPressed: () => _abrir(form: true),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 18),
              if (compacto) ...[
                _MetricaFinanceira(
                  rotulo: 'Saldo disponível',
                  valor: _saldo,
                  apoio: 'Disponível para movimentação',
                  fundo: const Color(0xFFF4F8F2),
                  borda: const Color(0xFFE1EDE1),
                  letra: const Color(0xFF1F3D2A),
                  rotuloCor: const Color(0xFF68806C),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _MetricaFinanceira(
                        rotulo: 'A pagar',
                        valor: _pagar,
                        apoio: 'No período selecionado',
                        fundo: const Color(0xFFFDECEC),
                        borda: const Color(0xFFF3D4D4),
                        letra: const Color(0xFFC62828),
                        rotuloCor: const Color(0xFFC62828),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _MetricaFinanceira(
                        rotulo: 'A receber',
                        valor: _receber,
                        apoio: 'No período selecionado',
                        fundo: const Color(0xFFE7F6EC),
                        borda: const Color(0xFFD2E8D8),
                        letra: MyColors.colorPrimary,
                        rotuloCor: MyColors.colorPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _BotaoNovoLancamento(onPressed: () => _abrir(form: true)),
              ] else
                Row(
                  children: [
                    Expanded(
                      child: _MetricaFinanceira(
                        rotulo: 'Saldo disponível',
                        valor: _saldo,
                        apoio: 'Disponível para movimentação',
                        fundo: const Color(0xFFF4F8F2),
                        borda: const Color(0xFFE1EDE1),
                        letra: const Color(0xFF1F3D2A),
                        rotuloCor: const Color(0xFF68806C),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _MetricaFinanceira(
                        rotulo: 'A pagar no período',
                        valor: _pagar,
                        apoio: 'Pendências a liquidar',
                        fundo: const Color(0xFFFDECEC),
                        borda: const Color(0xFFF3D4D4),
                        letra: const Color(0xFFC62828),
                        rotuloCor: const Color(0xFFC62828),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _MetricaFinanceira(
                        rotulo: 'A receber no período',
                        valor: _receber,
                        apoio: 'Valores a entrar',
                        fundo: const Color(0xFFE7F6EC),
                        borda: const Color(0xFFD2E8D8),
                        letra: MyColors.colorPrimary,
                        rotuloCor: MyColors.colorPrimary,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

class _MetricaFinanceira extends StatelessWidget {
  const _MetricaFinanceira({
    required this.rotulo,
    required this.valor,
    required this.apoio,
    required this.fundo,
    required this.borda,
    required this.letra,
    required this.rotuloCor,
  });

  final String rotulo;
  final String valor;
  final String apoio;
  final Color fundo;
  final Color borda;
  final Color letra;
  final Color rotuloCor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 104,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: fundo,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borda),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            rotulo.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: .35,
              color: rotuloCor,
            ),
          ),
          const SizedBox(height: 7),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              valor,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: letra,
              ),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            apoio,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 10,
              color: rotuloCor.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

class _BotaoNovoLancamento extends StatelessWidget {
  const _BotaoNovoLancamento({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.add, size: 17),
        label: const Text(
          'Novo lançamento',
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.visible,
        ),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: MyColors.colorPrimary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _Faixa extends StatelessWidget {
  const _Faixa({
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
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: fundo,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            rotulo,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 11,
              color: letra,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            valor,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: letra,
            ),
          ),
        ],
      ),
    );
  }
}
