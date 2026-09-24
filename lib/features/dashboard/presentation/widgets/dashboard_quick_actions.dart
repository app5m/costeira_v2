import 'package:costeira/core/common/get_list/domain/entities/app_menu_entity.dart';
import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/core/menus/app_menus_controller.dart';
import 'package:costeira/core/menus/menu_action_resolver.dart';
import 'package:costeira/core/menus/menu_icon.dart';
import 'package:costeira/features/insumos/presentation/pages/add_compra.dart';
import 'package:costeira/features/movimentacoes/abigeatos/add_abigeato.dart';
import 'package:costeira/features/movimentacoes/abortos/presentation/pages/add_aborto.dart';
import 'package:costeira/features/movimentacoes/compras/presentation/pages/add_compra.dart';
import 'package:costeira/features/movimentacoes/consumo/presentation/pages/add_consumo.dart';
import 'package:costeira/features/movimentacoes/mortes/presentation/pages/add_morte.dart';
import 'package:costeira/features/movimentacoes/nascimento/presentation/pages/add_nascimento.dart';
import 'package:costeira/features/movimentacoes/transferencias/add_transferencia.dart';
import 'package:costeira/features/movimentacoes/troca_categoria/presentation/pages/add_trocacategoria.dart';
import 'package:costeira/features/movimentacoes/vendas/presentation/pages/add_venda.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/presentation/pages/manejo/add_manejo.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/presentation/pages/suplementacao/add_suplemento.dart';
import 'package:costeira/features/sanitarios/presentation/pages/add_planejamento.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:lucide_icons/lucide_icons.dart';

class DashboardQuickActions extends StatelessWidget {
  const DashboardQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'dashboard-quick-actions',
      backgroundColor: MyColors.colorPrimary,
      foregroundColor: Colors.white,
      shape: const CircleBorder(),
      onPressed: () => _openQuickMenu(context),
      child: const Icon(LucideIcons.plus),
    );
  }
}

const _pillColors = [
  MyColors.colorPrimary,
  Color(0xFFC45C4A),
  MyColors.colorPrimary2,
];

Future<void> _openQuickMenu(BuildContext context) {
  final menus = Modular.get<AppMenusController>().dashboardMenu;
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Ações rápidas',
    barrierColor: const Color(0x99000000),
    transitionDuration: const Duration(milliseconds: 280),
    pageBuilder: (dialogContext, _, __) {
      return _QuickActionMenu(
        items: menus,
        onItem: (item) {
          Navigator.pop(dialogContext);
          _openDashboardItem(context, item);
        },
        onEntrada: () {
          Navigator.pop(dialogContext);
          _showEntradaSheet(context);
        },
        onSaida: () {
          Navigator.pop(dialogContext);
          _showSaidaSheet(context);
        },
        onManejo: () {
          Navigator.pop(dialogContext);
          _showManejoSheet(context);
        },
        onClose: () => Navigator.pop(dialogContext),
      );
    },
    transitionBuilder: (context, animation, _, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

Future<void> _openDashboardItem(
  BuildContext context,
  AppMenuEntity item,
) async {
  if (item.children.isNotEmpty) {
    await _showMenuSheet(context, item);
    return;
  }
  await MenuActionResolver.open(context, item, surface: MenuSurface.dashboard);
}

Future<void> _showMenuSheet(BuildContext context, AppMenuEntity item) {
  return _showActionSheet(
    context: context,
    title: item.name,
    items: [
      for (final child in item.children)
        _ActionItem(
          title: child.name,
          subtitle: child.description,
          menu: child,
          children: child.children.isEmpty
              ? null
              : [
                  for (final nested in child.children)
                    _ActionItem(
                      title: nested.name,
                      subtitle: nested.description,
                      menu: nested,
                    ),
                ],
        ),
    ],
  );
}

class _QuickActionMenu extends StatelessWidget {
  const _QuickActionMenu({
    required this.items,
    required this.onItem,
    required this.onEntrada,
    required this.onSaida,
    required this.onManejo,
    required this.onClose,
  });

  final List<AppMenuEntity> items;
  final ValueChanged<AppMenuEntity> onItem;
  final VoidCallback onEntrada;
  final VoidCallback onSaida;
  final VoidCallback onManejo;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          Positioned.fill(child: GestureDetector(onTap: onClose)),
          Positioned(
            left: 20,
            right: 20,
            bottom: 88 + bottom,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (items.isNotEmpty)
                  for (var i = 0; i < items.length; i++) ...[
                    if (i > 0) const SizedBox(height: 8),
                    _ActionPill(
                      index: i,
                      color: _pillColors[i % _pillColors.length],
                      title: items[i].name,
                      subtitle: items[i].description ?? '',
                      item: items[i],
                      onTap: () => onItem(items[i]),
                    ),
                  ]
                else ...[
                  _ActionPill(
                    index: 0,
                    color: MyColors.colorPrimary,
                    title: 'Entrada',
                    subtitle: 'Compra · Nascimento · Transferência',
                    onTap: onEntrada,
                  ),
                  const SizedBox(height: 8),
                  _ActionPill(
                    index: 1,
                    color: const Color(0xFFC45C4A),
                    title: 'Saída',
                    subtitle: 'Venda · Abate · Baixa',
                    onTap: onSaida,
                  ),
                  const SizedBox(height: 8),
                  _ActionPill(
                    index: 2,
                    color: MyColors.colorPrimary2,
                    title: 'Manejo',
                    subtitle: 'Pesagem · Vacina · IATF',
                    onTap: onManejo,
                  ),
                ],
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: _CloseFab(onTap: onClose),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionPill extends StatelessWidget {
  const _ActionPill({
    required this.index,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.item,
  });

  final int index;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final AppMenuEntity? item;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 280 + (index * 60)),
      curve: Interval(index * 0.12, 1, curve: Curves.easeOutCubic),
      tween: Tween(begin: 0, end: 1),
      builder: (context, value, child) {
        return Opacity(
          opacity: value.clamp(0, 1),
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            child: Row(
              children: [
                if (MenuIcon.maybe(item: item, size: 22, color: Colors.white)
                    case final icon?) ...[
                  icon,
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.82),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CloseFab extends StatelessWidget {
  const _CloseFab({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF313131),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const SizedBox(
          width: 48,
          height: 48,
          child: Icon(Icons.close_rounded, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}

class _ActionItem {
  const _ActionItem({
    required this.title,
    this.subtitle,
    this.page,
    this.menu,
    this.children,
    this.comingSoon = false,
  });

  final String title;
  final String? subtitle;
  final Widget Function()? page;
  final AppMenuEntity? menu;
  final List<_ActionItem>? children;
  final bool comingSoon;
}

Future<void> _showEntradaSheet(BuildContext context) {
  return _showActionSheet(
    context: context,
    title: 'Entrada',
    items: [
      _ActionItem(
        title: 'Compra',
        subtitle: 'Compra de animais',
        page: () => const AddCompra(),
      ),
      _ActionItem(
        title: 'Nascimento',
        subtitle: 'Registro de cria',
        page: () => const AddNascimento(),
      ),
      _ActionItem(
        title: 'Transferência',
        subtitle: 'Movimentação de campo',
        page: () => const AddTransferencia(),
      ),
      _ActionItem(
        title: 'Estoque',
        subtitle: 'Compra de insumo',
        page: () => const AddCompraInsumo(tipo: 1),
      ),
    ],
  );
}

Future<void> _showSaidaSheet(BuildContext context) {
  return _showActionSheet(
    context: context,
    title: 'Saída',
    items: [
      _ActionItem(
        title: 'Venda',
        subtitle: 'Venda de animais',
        page: () => const AddVenda(),
      ),
      _ActionItem(
        title: 'Morte / Baixa',
        subtitle: 'Morte, abigeato ou consumo',
        children: [
          _ActionItem(title: 'Morte', page: () => const AddMorte()),
          _ActionItem(title: 'Abigeato', page: () => const AddAbigeato()),
          _ActionItem(
            title: 'Consumo (carnear)',
            page: () => const AddConsumoPage(),
          ),
        ],
      ),
      _ActionItem(
        title: 'Baixa de estoque',
        subtitle: 'Uso de insumo',
        page: () => const AddCompraInsumo(tipo: 2),
      ),
    ],
  );
}

Future<void> _showManejoSheet(BuildContext context) {
  return _showActionSheet(
    context: context,
    title: 'Manejo',
    items: [
      _ActionItem(
        title: 'Manejo animal',
        subtitle: 'Sanitário, suplemento, piquete, categoria',
        children: [
          _ActionItem(title: 'Sanitário', page: () => const AddPlanejamento()),
          _ActionItem(
            title: 'Suplementação',
            page: () => const AddSuplemento(),
          ),
          _ActionItem(
            title: 'Movimentação de piquete',
            page: () => const AddTransferencia(),
          ),
          _ActionItem(
            title: 'Troca de categoria',
            page: () => const AddTrocaCategoria(),
          ),
          const _ActionItem(title: 'Pesagem', comingSoon: true),
          const _ActionItem(title: 'Castração', comingSoon: true),
          const _ActionItem(title: 'Identificação', comingSoon: true),
        ],
      ),
      _ActionItem(
        title: 'Manejo reprodutivo',
        subtitle: 'Parto, aborto e estação de monta',
        children: [
          _ActionItem(title: 'Parto', page: () => const AddNascimento()),
          _ActionItem(title: 'Aborto', page: () => const AddAborto()),
          const _ActionItem(title: 'Entrada de touro', comingSoon: true),
          const _ActionItem(title: 'Retirada de touro', comingSoon: true),
          const _ActionItem(title: 'IATF', comingSoon: true),
          const _ActionItem(title: 'Diagnóstico de gestação', comingSoon: true),
        ],
      ),
      _ActionItem(
        title: 'Manejo de campo',
        subtitle: 'Adubação, calagem, roçada, pastagem',
        page: () => const AddManejo(),
      ),
    ],
  );
}

Future<void> _showActionSheet({
  required BuildContext context,
  required String title,
  required List<_ActionItem> items,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 72,
                  height: 3,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E2E2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF313131),
                ),
              ),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(sheetContext).size.height * 0.55,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, index) {
                    final item = items[index];
                    return _ActionTile(
                      item: item,
                      onTap: () => _handleItem(sheetContext, item),
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

Future<void> _handleItem(BuildContext context, _ActionItem item) async {
  if (item.comingSoon) {
    Navigator.pop(context);
    AppSnackBar.show(
      context: context,
      message: '${item.title} em breve.',
      isError: false,
    );
    return;
  }

  if (item.children != null) {
    Navigator.pop(context);
    await _showActionSheet(
      context: context,
      title: item.title,
      items: item.children!,
    );
    return;
  }

  Navigator.pop(context);
  final menu = item.menu;
  if (menu != null) {
    await MenuActionResolver.open(
      context,
      menu,
      surface: MenuSurface.dashboard,
    );
    return;
  }
  final page = item.page;
  if (page == null) {
    return;
  }
  await Navigator.push(context, MaterialPageRoute(builder: (_) => page()));
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.item, required this.onTap});

  final _ActionItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF7F6F2),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              if (MenuIcon.maybe(
                    item: item.menu,
                    size: 22,
                    color: const Color(0xFF313131),
                  )
                  case final icon?) ...[
                icon,
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF313131),
                      ),
                    ),
                    if (item.subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.subtitle!,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF6B6B6B),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                item.comingSoon ? LucideIcons.clock : LucideIcons.chevronRight,
                size: 18,
                color: const Color(0xFF9A9A9A),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
