import 'package:costeira/app/app_route_data.dart';
import 'package:costeira/app/app_routes.dart';
import 'package:costeira/core/common/get_list/domain/entities/app_menu_entity.dart';
import 'package:costeira/core/menus/menu_slug.dart';
import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/features/manejos_animais/presentation/pages/manejo_animal_sessao_page.dart';
import 'package:costeira/features/manejos_animais/presentation/pages/manejo_campo_page.dart';
import 'package:costeira/features/manejos_animais/presentation/pages/manejo_reprodutivo_page.dart';
import 'package:costeira/features/insumos/presentation/pages/add_compra.dart';
import 'package:costeira/features/movimentacoes/abigeatos/abigeatos.dart';
import 'package:costeira/features/movimentacoes/abigeatos/add_abigeato.dart';
import 'package:costeira/features/movimentacoes/abigeatos/presentation/web/abigeatos_web_page.dart';
import 'package:costeira/features/movimentacoes/abortos/abortos.dart';
import 'package:costeira/features/movimentacoes/abortos/presentation/pages/add_aborto.dart';
import 'package:costeira/features/movimentacoes/abortos/presentation/web/abortos_web_page.dart';
import 'package:costeira/features/movimentacoes/compras/presentation/pages/add_compra.dart';
import 'package:costeira/features/movimentacoes/compras/presentation/pages/compras.dart';
import 'package:costeira/features/movimentacoes/compras/presentation/web/compras_web_page.dart';
import 'package:costeira/features/movimentacoes/consumo/consumo.dart';
import 'package:costeira/features/movimentacoes/consumo/presentation/pages/add_consumo.dart';
import 'package:costeira/features/movimentacoes/consumo/presentation/web/consumo_web_page.dart';
import 'package:costeira/features/movimentacoes/mortes/presentation/pages/add_morte.dart';
import 'package:costeira/features/movimentacoes/mortes/presentation/pages/mortes.dart';
import 'package:costeira/features/movimentacoes/mortes/presentation/web/mortes_web_page.dart';
import 'package:costeira/features/movimentacoes/movimentacoes.dart';
import 'package:costeira/features/movimentacoes/nascimento/presentation/pages/add_nascimento.dart';
import 'package:costeira/features/movimentacoes/nascimento/presentation/pages/nascimentos.dart';
import 'package:costeira/features/movimentacoes/nascimento/presentation/web/nascimentos_web_page.dart';
import 'package:costeira/features/movimentacoes/transferencias/add_transferencia.dart';
import 'package:costeira/features/movimentacoes/transferencias/add_transferencia_fazenda.dart';
import 'package:costeira/features/movimentacoes/transferencias/presentation/pages/transferencias_fazenda_page.dart';
import 'package:costeira/features/movimentacoes/transferencias/presentation/web/transferencias_web_page.dart';
import 'package:costeira/features/movimentacoes/transferencias/transferencia.dart';
import 'package:costeira/features/movimentacoes/troca_categoria/presentation/pages/add_trocacategoria.dart';
import 'package:costeira/features/movimentacoes/troca_categoria/presentation/pages/trocas.dart';
import 'package:costeira/features/movimentacoes/troca_categoria/presentation/web/troca_categoria_web_page.dart';
import 'package:costeira/features/movimentacoes/vendas/presentation/pages/add_venda.dart';
import 'package:costeira/features/movimentacoes/vendas/presentation/pages/vendas.dart';
import 'package:costeira/features/movimentacoes/vendas/presentation/web/vendas_web_page.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/presentation/pages/suplementacao/add_suplemento.dart';
import 'package:costeira/features/sanitarios/presentation/pages/add_planejamento.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

enum MenuSurface { dashboard, profile, nav, movimentacoes }

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
      return;
    }

    if (surface == MenuSurface.movimentacoes) {
      final page = movimentacoesPage(slug);
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
      MenuSlug.indicadores => AppRoutes.indicadores,
      MenuSlug.fornecedores => AppRoutes.fornecedores,
      MenuSlug.compradores => AppRoutes.compradores,
      MenuSlug.usuarios => AppRoutes.usuarios,
      MenuSlug.movimentacoes => AppRoutes.movimentacoes,
      _ => null,
    };
  }

  static Widget Function()? movimentacoesPage(String slug) {
    return switch (slug) {
      MenuSlug.compras =>
        () => kIsWeb ? const ComprasWebPage() : const Compras(),
      MenuSlug.vendas => () => kIsWeb ? const VendasWebPage() : const Vendas(),
      MenuSlug.mortes =>
        () => kIsWeb ? const MortesWebPage() : const Mortes(),
      MenuSlug.nascimentos => () =>
          kIsWeb ? const NascimentosWebPage() : const Nascimentos(),
      MenuSlug.trocasCategoria => () =>
          kIsWeb ? const TrocaCategoriaWebPage() : const TrocaCategoria(),
      MenuSlug.abigeato =>
        () => kIsWeb ? const AbigeatosWebPage() : const Abigeatos(),
      MenuSlug.abortos =>
        () => kIsWeb ? const AbortosWebPage() : const Abortos(),
      MenuSlug.consumo =>
        () => kIsWeb ? const ConsumoWebPage() : const Consumo(),
      MenuSlug.transferencias => () =>
          kIsWeb ? const TransferenciasWebPage() : const Transferencia(),
      MenuSlug.movimentacoes => () => const Movimentacoes(),
      _ => null,
    };
  }

  static Widget Function()? dashboardPage(String slug) {
    return switch (slug) {
      MenuSlug.movimentacoes => () => const Movimentacoes(),
      MenuSlug.compra => () => const AddCompra(),
      MenuSlug.nascimento || 'parto' => () => const AddNascimento(),
      MenuSlug.transferenciaRecebida => () => const TransferenciasFazendaPage(
        initialTab: 0,
      ),
      'transferencia_enviada' => () => const AddTransferenciaFazenda(),
      'movimentacao_de_piquete' => () => const AddTransferencia(),
      MenuSlug.venda => () => const AddVenda(),
      MenuSlug.morte => () => const AddMorte(),
      MenuSlug.abigeato => () => const AddAbigeato(),
      MenuSlug.consumo => () => const AddConsumoPage(),
      MenuSlug.estoque ||
      'estoque_entrada' => () => const AddCompraInsumo(tipo: 1),
      'baixa_estoque' => () => const AddCompraInsumo(tipo: 2),
      MenuSlug.manejoAnimal => () => const ManejoAnimalSessaoPage(),
      'sanitario' => () => const AddPlanejamento(),
      'suplementacao' => () => const AddSuplemento(),
      'troca_de_categoria' => () => const AddTrocaCategoria(),
      'aborto' => () => const AddAborto(),
      'manejo_campo' => () => const ManejoCampoPage(),
      'manejo_reprodutivo' => () => const ManejoReprodutivoPage(),
      _ => null,
    };
  }
}
