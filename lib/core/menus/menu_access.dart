import 'package:costeira/app/app_routes.dart';
import 'package:costeira/core/common/get_list/domain/entities/app_menu_entity.dart';
import 'package:costeira/core/menus/menu_action_resolver.dart';

/// Allowed menu actions/slugs derived from `/util/lista` trees.
class MenuAccess {
  const MenuAccess({
    required this.navSlugs,
    required this.profileActions,
    required this.dashboardActions,
  });

  final Set<String> navSlugs;
  final Set<String> profileActions;
  final Set<String> dashboardActions;

  factory MenuAccess.fromMenus({
    required List<AppMenuEntity> navigation,
    required List<AppMenuEntity> profile,
    required List<AppMenuEntity> dashboard,
  }) {
    return MenuAccess(
      navSlugs: _slugs(navigation),
      profileActions: _leafSlugs(profile),
      dashboardActions: _leafSlugs(dashboard),
    );
  }

  bool allowsNavSlug(String slug) => navSlugs.contains(slug);

  /// Profile module action for [path], or null if path is not a gated module.
  String? profileActionForPath(String path) {
    for (final entry in _profilePrefixes.entries) {
      for (final prefix in entry.value) {
        if (path == prefix || path.startsWith('$prefix/')) {
          return entry.key;
        }
      }
    }
    return null;
  }

  /// True when [path] is a gated profile module the user no longer has.
  bool isBlockedProfilePath(String path) {
    final action = profileActionForPath(path);
    if (action == null) {
      return false;
    }
    return !profileActions.contains(action);
  }

  static const _profilePrefixes = <String, List<String>>{
    'potreiros': [AppRoutes.potreirosHub, AppRoutes.potreiros],
    'estoque': [AppRoutes.estoque],
    'tarefas': [AppRoutes.tasks],
    'pluviosidade': [AppRoutes.climateRain],
    'fornecedores': [AppRoutes.fornecedores],
    'compradores': [AppRoutes.compradores],
    'usuarios': [AppRoutes.usuarios],
    'movimentacoes': [AppRoutes.movimentacoes],
  };

  static Set<String> _slugs(List<AppMenuEntity> items) {
    return {
      for (final item in items) MenuActionResolver.slugOf(item),
      for (final item in items) ..._slugs(item.children),
    };
  }

  static Set<String> _leafSlugs(List<AppMenuEntity> items) {
    final result = <String>{};
    for (final item in items) {
      if (item.children.isEmpty) {
        result.add(MenuActionResolver.slugOf(item));
      } else {
        result.addAll(_leafSlugs(item.children));
      }
    }
    return result;
  }
}
