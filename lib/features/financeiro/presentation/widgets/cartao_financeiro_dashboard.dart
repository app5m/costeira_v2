import 'package:costeira/app/app_routes.dart';
import 'package:costeira/core/menus/app_menus_controller.dart';
import 'package:costeira/core/menus/menu_action_resolver.dart';
import 'package:costeira/features/financeiro/presentation/financeiro_acesso.dart';
import 'package:costeira/features/financeiro/presentation/financeiro_shell_page.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CartaoFinanceiroDashboard extends StatefulWidget {
  const CartaoFinanceiroDashboard({super.key});

  @override
  State<CartaoFinanceiroDashboard> createState() =>
      _CartaoFinanceiroDashboardState();
}

class _CartaoFinanceiroDashboardState extends State<CartaoFinanceiroDashboard> {
  late final AppMenusController _menus;

  @override
  void initState() {
    super.initState();
    _menus = Modular.get<AppMenusController>();
    _menus.addListener(_atualizar);
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
            'Saldo disponível em 20/10/2026',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 12,
              color: Color(0xFF8A8A8A),
            ),
          ),
          const Text(
            'R\$ 24.580,00',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1C1C1C),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: const [
              Expanded(
                child: _Faixa(
                  rotulo: 'A pagar no período',
                  valor: 'R\$ 3.250,00',
                  fundo: Color(0xFFFDECEC),
                  letra: Color(0xFFC62828),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _Faixa(
                  rotulo: 'A receber no período',
                  valor: 'R\$ 8.900,00',
                  fundo: Color(0xFFE7F6EC),
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
