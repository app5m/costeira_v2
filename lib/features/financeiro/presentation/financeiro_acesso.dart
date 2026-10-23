import 'package:costeira/core/common/get_list/domain/entities/app_menu_entity.dart';
import 'package:costeira/core/menus/app_menus_controller.dart';
import 'package:costeira/core/menus/menu_action_resolver.dart';
import 'package:costeira/core/storage/session_storage.dart';

bool podeVerFinanceiro(AppMenusController menus) {
  if (SessionStorage.cachedSubUserId == null) {
    return true;
  }
  return _tem(menus.dashboardMenu) ||
      _tem(menus.profileMenu) ||
      _tem(menus.navigationMenu);
}

bool _tem(List<AppMenuEntity> itens) {
  for (final item in itens) {
    final slug = MenuActionResolver.slugOf(item);
    if (slug == 'financeiro') return true;
    if (_tem(item.children)) return true;
  }
  return false;
}
