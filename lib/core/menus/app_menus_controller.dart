import 'package:costeira/core/common/get_list/domain/entities/app_menu_entity.dart';
import 'package:costeira/core/common/get_list/domain/entities/get_list_params_entity.dart';
import 'package:costeira/core/common/get_list/domain/usecases/get_list_usecase.dart';
import 'package:costeira/core/menus/menu_action_resolver.dart';
import 'package:costeira/core/menus/menu_slug.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/core/utils/app_logger.dart';
import 'package:flutter/foundation.dart';

class AppMenusController extends ChangeNotifier {
  AppMenusController(this._getListUsecase);

  final GetListUsecase _getListUsecase;

  List<AppMenuEntity> dashboardMenu = const [];
  List<AppMenuEntity> profileMenu = const [];
  List<AppMenuEntity> navigationMenu = const [];
  bool isLoading = false;
  bool loaded = false;
  String _signature = '';

  /// Snapshot signature of current menu trees (nav + profile + dashboard).
  String get signature => _signature;

  Future<void> load({bool force = false}) async {
    if ((loaded || isLoading) && !force) {
      return;
    }
    await _fetch(silent: false);
  }

  /// Background refresh. Only notifies when the tree actually changes.
  /// On network failure keeps the current menus.
  Future<bool> refresh() => _fetch(silent: true);

  Future<bool> _fetch({required bool silent}) async {
    if (isLoading) {
      return false;
    }

    isLoading = true;
    if (!silent) {
      notifyListeners();
    }

    try {
      final user = await SessionStorage.getUserSession();
      final result = await _getListUsecase(
        GetListParamsEntity(sexo: 1, userId: user?.id),
      );
      final nextDash = _visible(result.dashboardMenu);
      final nextProfile = _visible(result.menu);
      final nextNav = _visible(result.menuNavigation, keepDashboard: true);
      final nextSignature =
          'dash=${_slugTree(nextDash)}|perfil=${_slugTree(nextProfile)}|nav=${_slugTree(nextNav)}';

      final changed = nextSignature != _signature;
      dashboardMenu = nextDash;
      profileMenu = nextProfile;
      navigationMenu = nextNav;
      loaded = true;
      _signature = nextSignature;

      AppLogger.info(
        'APP MENUS: $nextSignature changed=$changed silent=$silent',
      );

      if (!silent || changed) {
        notifyListeners();
      }
      return changed;
    } catch (error) {
      AppLogger.error('APP MENUS: fetch failed error=$error');
      if (!loaded) {
        notifyListeners();
      }
      return false;
    } finally {
      isLoading = false;
      if (!silent) {
        notifyListeners();
      }
    }
  }

  List<AppMenuEntity> _visible(
    List<AppMenuEntity> items, {
    bool keepDashboard = false,
  }) {
    return items
        .where((item) {
          if (item.isEnabled) {
            return true;
          }
          return keepDashboard &&
              MenuActionResolver.slugOf(item) == MenuSlug.dashboard;
        })
        .map(
          (item) => item.copyWith(
            children: _visible(item.children, keepDashboard: keepDashboard),
          ),
        )
        .where((item) {
          // Grupo pai sem filhos (ex.: Cadastros com menus_n1 []) não aparece.
          final action = item.action?.trim() ?? '';
          if (action.isEmpty && item.children.isEmpty) {
            return false;
          }
          return true;
        })
        .toList(growable: false);
  }

  String _slugTree(List<AppMenuEntity> items) {
    return items
        .map((item) {
          final slug = MenuActionResolver.slugOf(item);
          final action = item.action ?? '-';
          if (item.children.isEmpty) {
            return '$action>$slug';
          }
          return '$action>$slug[${_slugTree(item.children)}]';
        })
        .join(',');
  }
}
