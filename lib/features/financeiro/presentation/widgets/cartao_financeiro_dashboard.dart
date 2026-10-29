import 'package:costeira/app/app_routes.dart';
import 'package:costeira/core/menus/app_menus_controller.dart';
import 'package:costeira/core/api/api_client.dart';
import 'package:costeira/features/financeiro/infra/financeiro_api.dart';
import 'package:costeira/features/financeiro/presentation/financeiro_acesso.dart';
import 'package:costeira/features/financeiro/presentation/financeiro_shell_page.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CartaoFinanceiroDashboard extends StatefulWidget {
  const CartaoFinanceiroDashboard({super.key});

  @override
  State<CartaoFinanceiroDashboard> createState() => _CartaoFinanceiroDashboardState();
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
    _carregar();
  }

  Future<void> _carregar() async {
    final api = FinanceiroApi(ApiClient.instance);
    try {
      final fluxo = await api.fluxo();
      final lista = await api.lancamentos(limite: 50);
      if (!mounted) return;
      final dados = lista['dados'];
      var pagar = 0.0;
      var receber = 0.0;
      if (dados is List) {
        for (final item in dados) {
          if (item is! Map) continue;
          final estado = item['estado']?.toString() ?? '';
          if (estado == 'rascunho' || estado == 'estornado' || estado == 'cancelado') continue;
          final pendente = double.tryParse(item['saldo_pendente']?.toString() ?? '') ??
              ((double.tryParse(item['valor']?.toString() ?? '') ?? 0) - (double.tryParse(item['valor_liquidado']?.toString() ?? '') ?? 0));
          if (pendente <= 0) continue;
          if ((item['tipo']?.toString() ?? '').toLowerCase() == 'recebimento') {
            receber += pendente;
          } else {
            pagar += pendente;
          }
        }
      }
      setState(() {
        _saldo = fluxo['indicadores']?['saldo_disponivel_string']?.toString() ?? _saldo;
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
    Modular.to.pushNamed(
      AppRoutes.financeiro,
      arguments: form ? const FinanceiroAbrir.form() : const FinanceiroAbrir.modulo(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!podeVerFinanceiro(_menus)) return const SizedBox.shrink();
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
                child: const Icon(LucideIcons.wallet, size: 16, color: MyColors.colorPrimary),
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
            style: TextStyle(fontFamily: 'Montserrat', fontSize: 12, color: Color(0xFF8A8A8A)),
          ),
          Text(
            _saldo,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1C1C1C),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _Faixa(rotulo: 'A pagar no período', valor: _pagar, fundo: const Color(0xFFFDECEC), letra: const Color(0xFFC62828))),
              const SizedBox(width: 8),
              Expanded(child: _Faixa(rotulo: 'A receber no período', valor: _receber, fundo: const Color(0xFFE7F6EC), letra: MyColors.colorPrimary)),
            ],
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _abrir(form: true),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Novo lançamento', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600)),
            style: OutlinedButton.styleFrom(
              foregroundColor: MyColors.colorPrimary,
              minimumSize: const Size.fromHeight(44),
              side: const BorderSide(color: Color(0xFFD7E8DC)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
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
