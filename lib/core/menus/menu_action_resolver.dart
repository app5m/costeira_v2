import 'package:costeira/app/app_route_data.dart';
import 'package:costeira/app/app_routes.dart';
import 'package:costeira/core/common/get_list/domain/entities/app_menu_entity.dart';
import 'package:costeira/core/menus/menu_slug.dart';
import 'package:costeira/core/utils/app_logger.dart';
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
import 'package:costeira/features/movimentacoes/movimentacoes.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/presentation/pages/manejo/add_manejo.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/presentation/pages/suplementacao/add_suplemento.dart';
import 'package:costeira/features/sanitarios/presentation/pages/add_planejamento.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

enum MenuSurface { dashboard, profile, nav }

class MenuActionResolver {
  const MenuActionResolver._();

  static String slugOf(AppMenuEntity item) {
    return MenuSlug.resolve(action: item.action, name: item.name);
  }

  static Future<void> open(
    BuildContext context,
    AppMenuEntity item, {
    required MenuSurface surface,
  }) async {
    final action = item.action?.trim() ?? '';
    if (action.startsWith('/')) {
      Modular.to.pushNamed(action);
      return;
    }

    final slug = slugOf(item);
    AppLogger.info(
      'MENU ACTION: surface=$surface nome=${item.name} action=${item.action} slug=$slug',
    );
    if (surface == MenuSurface.profile) {
      final route = profileRoute(slug);
      if (route == null) {
        Modular.to.pushNamed(
          AppRoutes.comingSoon,
          arguments: ComingSoonRouteData(
            title: item.name,
            message: 'Em breve.',
            menu: item,
          ),
        );
        return;
      }
      Modular.to.pushNamed(route);
      return;
    }

    if (surface == MenuSurface.dashboard) {
      final page = dashboardPage(slug);
      if (page == null) {
        Modular.to.pushNamed(
          AppRoutes.comingSoon,
          arguments: ComingSoonRouteData(
            title: item.name,
            message: 'Em breve.',
            menu: item,
          ),
        );
        return;
      }
      await Navigator.push(context, MaterialPageRoute(builder: (_) => page()));
    }
  }

  static String? profileRoute(String slug) {
    return switch (slug) {
      MenuSlug.potreiros => AppRoutes.potreirosHub,
      MenuSlug.estoque => AppRoutes.estoque,
      MenuSlug.tarefas => AppRoutes.tasks,
      MenuSlug.pluviosidade => AppRoutes.climateRain,
      MenuSlug.fornecedores => AppRoutes.fornecedores,
      MenuSlug.compradores => AppRoutes.compradores,
      MenuSlug.usuarios => AppRoutes.usuarios,
      MenuSlug.movimentacoes => AppRoutes.movimentacoes,
      _ => null,
    };
  }

  static Widget Function()? dashboardPage(String slug) {
    return switch (slug) {
      MenuSlug.movimentacoes => () => const Movimentacoes(),
      MenuSlug.compra => () => const AddCompra(),
      MenuSlug.nascimento || 'parto' => () => const AddNascimento(),
      MenuSlug.transferenciaRecebida ||
      'transferencia_enviada' ||
      'movimentacao_de_piquete' => () => const AddTransferencia(),
      MenuSlug.venda => () => const AddVenda(),
      MenuSlug.morte => () => const AddMorte(),
      'abigeato' => () => const AddAbigeato(),
      'consumo' || 'consumo_carnear' => () => const AddConsumoPage(),
      MenuSlug.estoque ||
      'estoque_entrada' => () => const AddCompraInsumo(tipo: 1),
      'baixa_estoque' => () => const AddCompraInsumo(tipo: 2),
      MenuSlug.manejoAnimal || 'sanitario' => () => const AddPlanejamento(),
      'suplementacao' => () => const AddSuplemento(),
      'troca_de_categoria' => () => const AddTrocaCategoria(),
      'aborto' => () => const AddAborto(),
      'manejo_campo' => () => const AddManejo(),
      _ => null,
    };
  }
}
