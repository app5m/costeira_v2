import 'dart:async';

import 'package:costeira/app/app_routes.dart';
import 'package:costeira/core/common/get_list/domain/entities/app_menu_entity.dart';
import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/core/menus/app_menus_controller.dart';
import 'package:costeira/core/menus/menu_access.dart';
import 'package:costeira/core/menus/menu_action_resolver.dart';
import 'package:costeira/core/menus/menu_icon.dart';
import 'package:costeira/core/menus/menu_slug.dart';
import 'package:costeira/core/offline/cache/form_dependencies_cache_service.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/features/account/repositories/account_repository.dart';
import 'package:costeira/features/account/presentation/web/profile_web_page.dart';
import 'package:costeira/features/animals/presentation/pages/animals_page.dart';
import 'package:costeira/features/base/pages/module_placeholder_page.dart';
import 'package:costeira/features/dashboard/presentation/pages/dashboard.dart';
import 'package:costeira/features/dashboard/presentation/web/dashboard_web_page.dart';
import 'package:costeira/features/dashboard/presentation/widgets/dashboard_quick_actions.dart';
import 'package:costeira/features/fazendas/presentation/pages/fazendas_page.dart';
import 'package:costeira/features/fazendas/presentation/web/fazendas_web_page.dart';
import 'package:costeira/features/manejos_animais/presentation/pages/manejos_animais_page.dart';
import 'package:costeira/features/movimentacoes/movimentacoes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../theme/colors.dart';
import '../../../views/navigationscreen/Menu/menu_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage>
    with WidgetsBindingObserver {
  static const _pollInterval = Duration(seconds: 60);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int _selectedIndex = 0;
  final PageController _pageController = PageController(initialPage: 0);
  late final AppMenusController _menusController;
  Timer? _pollTimer;
  String _lastHandledSignature = '';
  String? _activeSlug;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _menusController = Modular.get<AppMenusController>();
    _menusController.addListener(_onMenus);
    _preload();
    _startPollTimer();
  }

  Future<void> _preload() async {
    final user = await SessionStorage.getUserSession();
    if (!mounted || user == null) {
      return;
    }
    await _loadSubUser(user.id);
    if (!mounted) {
      return;
    }
    unawaited(_menusController.load(force: true));
    unawaited(
      Modular.get<FormDependenciesCacheService>().preloadEssentialLists(),
    );
  }

  Future<void> _loadSubUser(int userId) async {
    try {
      await Modular.get<AccountRepository>().fetchProfile(userId: userId);
    } catch (_) {}
  }

  void _startPollTimer() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_pollInterval, (_) {
      unawaited(_menusController.refresh());
    });
  }

  void _stopPollTimer() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_menusController.refresh());
      _startPollTimer();
      return;
    }
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      _stopPollTimer();
    }
  }

  void _onMenus() {
    if (!mounted) {
      return;
    }

    final tabs = _tabs;
    var kicked = false;

    final currentSlug = _activeSlug;
    final access = MenuAccess.fromMenus(
      navigation: _menusController.navigationMenu,
      profile: _menusController.profileMenu,
      dashboard: _menusController.dashboardMenu,
    );

    if (currentSlug != null &&
        _menusController.navigationMenu.isNotEmpty &&
        !access.allowsNavSlug(currentSlug)) {
      kicked = _goToDashboardTab(tabs);
    } else if (currentSlug != null) {
      final updatedIndex = tabs.indexWhere((tab) => tab.slug == currentSlug);
      if (updatedIndex >= 0 && updatedIndex != _selectedIndex) {
        _selectedIndex = updatedIndex;
        if (_pageController.hasClients) {
          _pageController.jumpToPage(updatedIndex);
        }
      }
    } else if (_selectedIndex >= tabs.length) {
      _selectedIndex = 0;
      if (_pageController.hasClients) {
        _pageController.jumpToPage(0);
      }
      kicked = true;
    }

    final path = Modular.to.path;
    if (access.isBlockedProfilePath(path)) {
      while (Modular.to.canPop()) {
        Modular.to.pop();
      }
      kicked = _goToDashboardTab(tabs) || true;
    }

    final signature = _menusController.signature;
    if (kicked && signature.isNotEmpty && signature != _lastHandledSignature) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        AppSnackBar.show(
          context: context,
          message: 'Acesso atualizado.',
          isError: false,
        );
      });
    }
    _lastHandledSignature = signature;

    setState(() {});
  }

  bool _goToDashboardTab(List<_NavTab> tabs) {
    if (tabs.isEmpty) {
      return false;
    }
    final dashboardIndex = tabs.indexWhere(
      (tab) => tab.slug == MenuSlug.dashboard,
    );
    final target = dashboardIndex >= 0 ? dashboardIndex : 0;
    final changed = _selectedIndex != target;
    _selectedIndex = target;
    _activeSlug = tabs[target].slug;
    if (_pageController.hasClients) {
      _pageController.jumpToPage(target);
    }
    return changed || dashboardIndex >= 0;
  }

  List<_NavTab> get _tabs {
    return [
      for (final item in _menusController.navigationMenu)
        if (!kIsWeb ||
            MenuActionResolver.slugOf(item) != MenuSlug.movimentacoes)
          _NavTab(
            slug: MenuActionResolver.slugOf(item),
            label: item.name,
            item: item,
          ),
    ];
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopPollTimer();
    _menusController.removeListener(_onMenus);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tabs = _tabs;
    if (kIsWeb) {
      return _buildWebShell(tabs);
    }
    if (tabs.isEmpty) {
      return _emptyNavScaffold();
    }
    final current = tabs[_selectedIndex.clamp(0, tabs.length - 1)];
    _activeSlug ??= current.slug;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: current.slug == MenuSlug.dashboard
          ? const Color(0xFFF6F4EE)
          : Colors.white,
      endDrawer: _movementsDrawer(),
      appBar: AppBar(
        backgroundColor: MyColors.colorPrimary,
        leadingWidth: 20,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Text(
            current.label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Montserrat',
            ),
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Movimentações',
            icon: SvgPicture.asset(
              'icon/arrow-left-right.svg',
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),
          IconButton(
            icon: SvgPicture.asset(
              'icon/noti.svg',
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
            onPressed: () {
              Modular.to.pushNamed(AppRoutes.notifications);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (page) {
          setState(() {
            _selectedIndex = page;
            _activeSlug = tabs[page].slug;
          });
        },
        children: [for (final tab in tabs) _pageFor(tab)],
      ),
      floatingActionButton: current.slug == MenuSlug.dashboard
          ? const DashboardQuickActions()
          : null,
      bottomNavigationBar: _DashboardBottomBar(
        currentIndex: _selectedIndex,
        items: [for (final tab in tabs) (item: tab.item, label: tab.label)],
        onTap: _onNavItemTapped,
      ),
    );
  }

  Widget _buildWebShell(List<_NavTab> tabs) {
    final hasTabs = tabs.isNotEmpty;
    final selectedIndex = hasTabs
        ? _selectedIndex.clamp(0, tabs.length - 1)
        : 0;
    if (hasTabs && selectedIndex != _selectedIndex) {
      _selectedIndex = selectedIndex;
    }
    final current = hasTabs ? tabs[selectedIndex] : null;
    _activeSlug ??= current?.slug;

    return LayoutBuilder(
      builder: (context, constraints) {
        final useSidebar = constraints.maxWidth >= 760;
        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: current?.slug == MenuSlug.dashboard
              ? const Color(0xFFF6F4EE)
              : Colors.white,
          drawer: useSidebar
              ? null
              : Drawer(
                  width: constraints.maxWidth > 420
                      ? 320
                      : constraints.maxWidth * 0.88,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.horizontal(
                      right: Radius.circular(22),
                    ),
                  ),
                  child: _webSidebar(tabs, closeDrawer: true),
                ),
          body: Row(
            children: [
              if (useSidebar)
                SizedBox(
                  width: constraints.maxWidth >= 1120 ? 264 : 232,
                  child: _webSidebar(tabs),
                ),
              Expanded(
                child: Column(
                  children: [
                    _WebTopBar(
                      title: current?.label ?? 'Costeira',
                      showMenuButton: !useSidebar,
                      onMenu: () => _scaffoldKey.currentState?.openDrawer(),
                      onNotifications: () =>
                          Modular.to.pushNamed(AppRoutes.notifications),
                    ),
                    Expanded(
                      child: hasTabs
                          ? PageView(
                              controller: _pageController,
                              physics: const NeverScrollableScrollPhysics(),
                              onPageChanged: (page) {
                                setState(() {
                                  _selectedIndex = page;
                                  _activeSlug = tabs[page].slug;
                                });
                              },
                              children: [for (final tab in tabs) _pageFor(tab)],
                            )
                          : _emptyNavigationContent(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _webSidebar(List<_NavTab> tabs, {bool closeDrawer = false}) {
    return _WebSidebar(
      menus: _menusController,
      tabs: tabs,
      currentIndex: tabs.isEmpty ? 0 : _selectedIndex.clamp(0, tabs.length - 1),
      onSelect: (index) {
        if (closeDrawer) {
          Navigator.of(context).pop();
        }
        _onNavItemTapped(index);
      },
      onMovement: (item) {
        if (closeDrawer) {
          Navigator.of(context).pop();
        }
        MenuActionResolver.open(
          context,
          item,
          surface: MenuSurface.movimentacoes,
        );
      },
    );
  }

  Widget _emptyNavigationContent() {
    return Center(
      child: _menusController.loaded
          ? const Text(
              'Nenhum menu de navegação disponível.',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF8A8A8A),
              ),
            )
          : const CircularProgressIndicator(),
    );
  }

  Widget _movementsDrawer() {
    return _MovementsDrawer(
      menus: _menusController,
      onOpen: (item) {
        Navigator.of(context).pop();
        MenuActionResolver.open(
          context,
          item,
          surface: MenuSurface.movimentacoes,
        );
      },
    );
  }

  Widget _emptyNavScaffold() {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF6F4EE),
      endDrawer: _movementsDrawer(),
      appBar: AppBar(
        backgroundColor: MyColors.colorPrimary,
        title: const Text(
          'Costeira',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Montserrat',
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Movimentações',
            icon: SvgPicture.asset(
              'icon/arrow-left-right.svg',
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),
        ],
      ),
      body: Center(
        child: _menusController.loaded
            ? const Text(
                'Nenhum menu de navegação disponível.',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8A8A8A),
                ),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }

  Widget _pageFor(_NavTab tab) {
    return switch (tab.slug) {
      MenuSlug.dashboard =>
        kIsWeb ? const DashboardWebPage() : const Dashboard(),
      MenuSlug.fazendas =>
        kIsWeb ? const FazendasWebPage() : const FazendasPage(),
      MenuSlug.animais => const AnimalsPage(),
      MenuSlug.movimentacoes => const Movimentacoes(),
      MenuSlug.manejos => const ManejosAnimaisPage(),
      MenuSlug.perfil => kIsWeb ? const ProfileWebPage() : const Menu(),
      _ => ModulePlaceholderPage(
        title: tab.label,
        item: tab.item,
        message: 'Em breve.',
      ),
    };
  }

  void _onNavItemTapped(int index) {
    final tabs = _tabs;
    if (index < 0 || index >= tabs.length) {
      return;
    }
    setState(() {
      _selectedIndex = index;
      _activeSlug = tabs[index].slug;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }
}

class _NavTab {
  const _NavTab({required this.slug, required this.label, this.item});

  final String slug;
  final String label;
  final AppMenuEntity? item;
}

class _WebTopBar extends StatelessWidget {
  const _WebTopBar({
    required this.title,
    required this.showMenuButton,
    required this.onMenu,
    required this.onNotifications,
  });

  final String title;
  final bool showMenuButton;
  final VoidCallback onMenu;
  final VoidCallback onNotifications;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 0,
      child: Container(
        height: 72,
        padding: EdgeInsets.symmetric(horizontal: showMenuButton ? 12 : 28),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFE7E4DD))),
        ),
        child: Row(
          children: [
            if (showMenuButton) ...[
              IconButton(
                tooltip: 'Abrir menu',
                onPressed: onMenu,
                icon: const Icon(Icons.menu_rounded),
              ),
              const SizedBox(width: 4),
            ],
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF252525),
                ),
              ),
            ),
            IconButton(
              tooltip: 'Notificações',
              onPressed: onNotifications,
              icon: SvgPicture.asset(
                'icon/noti.svg',
                width: 22,
                height: 22,
                colorFilter: const ColorFilter.mode(
                  MyColors.colorPrimary,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WebSidebar extends StatelessWidget {
  const _WebSidebar({
    required this.menus,
    required this.tabs,
    required this.currentIndex,
    required this.onSelect,
    required this.onMovement,
  });

  final AppMenusController menus;
  final List<_NavTab> tabs;
  final int currentIndex;
  final ValueChanged<int> onSelect;
  final ValueChanged<AppMenuEntity> onMovement;

  @override
  Widget build(BuildContext context) {
    AppMenuEntity? profile;
    var movementRendered = false;
    final navigation = <Widget>[];

    for (final item in menus.navigationMenu) {
      final slug = MenuActionResolver.slugOf(item);
      if (slug == MenuSlug.perfil) {
        profile = item;
        continue;
      }
      if (slug == MenuSlug.movimentacoes) {
        movementRendered = true;
        navigation.add(
          _WebMovementGroup(
            item: item,
            movements: menus.movementMenu,
            onOpen: onMovement,
          ),
        );
        continue;
      }
      final index = tabs.indexWhere((tab) => identical(tab.item, item));
      if (index < 0) {
        continue;
      }
      navigation.add(
        _WebNavigationTile(
          item: item,
          label: item.name,
          selected: index == currentIndex,
          onTap: () => onSelect(index),
        ),
      );
    }

    if (!movementRendered && menus.movementMenu.isNotEmpty) {
      navigation.add(
        _WebMovementGroup(movements: menus.movementMenu, onOpen: onMovement),
      );
    }

    final profileIndex = profile == null
        ? -1
        : tabs.indexWhere((tab) => identical(tab.item, profile));

    return ColoredBox(
      color: Colors.white,
      child: SafeArea(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            border: Border(right: BorderSide(color: Color(0xFFE7E4DD))),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
                child: Image.asset(
                  'images/logosplash.png',
                  height: 68,
                  width: 190,
                  fit: BoxFit.contain,
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
                  children: [
                    for (var index = 0; index < navigation.length; index++) ...[
                      navigation[index],
                      if (index < navigation.length - 1)
                        const SizedBox(height: 5),
                    ],
                  ],
                ),
              ),
              if (profile != null && profileIndex >= 0) ...[
                const Divider(height: 1, color: Color(0xFFE7E4DD)),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: _WebNavigationTile(
                    item: profile,
                    label: profile.name,
                    selected: profileIndex == currentIndex,
                    onTap: () => onSelect(profileIndex),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _WebNavigationTile extends StatelessWidget {
  const _WebNavigationTile({
    required this.item,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final AppMenuEntity item;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? const Color(0xFF00823A) : const Color(0xFF666666);
    final icon = MenuIcon.maybe(item: item, size: 21, color: color);
    return Material(
      color: selected ? const Color(0x1400823A) : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
          child: Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Center(
                  child:
                      icon ??
                      Icon(Icons.circle_outlined, size: 19, color: color),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WebMovementGroup extends StatelessWidget {
  const _WebMovementGroup({
    required this.movements,
    required this.onOpen,
    this.item,
  });

  final AppMenuEntity? item;
  final List<AppMenuEntity> movements;
  final ValueChanged<AppMenuEntity> onOpen;

  @override
  Widget build(BuildContext context) {
    final icon = MenuIcon.maybe(
      item: item,
      size: 21,
      color: const Color(0xFF5E6E64),
    );
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 13),
        childrenPadding: const EdgeInsets.fromLTRB(13, 0, 4, 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        leading: SizedBox(
          width: 24,
          height: 24,
          child: Center(
            child:
                icon ??
                SvgPicture.asset(
                  'icon/arrow-left-right.svg',
                  width: 20,
                  height: 20,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF666666),
                    BlendMode.srcIn,
                  ),
                ),
          ),
        ),
        title: Text(
          item?.name ?? 'Movimentações',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF666666),
          ),
        ),
        children: movements.isEmpty
            ? const [
                Padding(
                  padding: EdgeInsets.fromLTRB(35, 5, 8, 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Nenhuma movimentação disponível.',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 11,
                        color: Color(0xFF8A8A8A),
                      ),
                    ),
                  ),
                ),
              ]
            : [
                for (final movement in movements)
                  _WebMovementTile(
                    item: movement,
                    onTap: () => onOpen(movement),
                  ),
              ],
      ),
    );
  }
}

class _WebMovementTile extends StatelessWidget {
  const _WebMovementTile({required this.item, required this.onTap});

  final AppMenuEntity item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final icon = MenuIcon.maybe(
      item: item,
      size: 17,
      color: MyColors.colorPrimary,
    );
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Row(
          children: [
            SizedBox(width: 20, child: icon),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                item.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF444444),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardBottomBar extends StatelessWidget {
  const _DashboardBottomBar({
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  final int currentIndex;
  final List<({AppMenuEntity? item, String label})> items;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 12,
      shadowColor: const Color(0x33000000),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: _BottomBarItem(
                    item: items[i].item,
                    label: items[i].label,
                    selected: currentIndex == i,
                    onTap: () => onTap(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomBarItem extends StatelessWidget {
  const _BottomBarItem({
    required this.label,
    required this.selected,
    required this.onTap,
    this.item,
  });

  final AppMenuEntity? item;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? MyColors.colorPrimary : const Color(0xFF9A9A9A);
    final icon = MenuIcon.maybe(item: item, size: 22, color: color);

    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null)
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: selected ? const Color(0x1400823A) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: icon,
            )
          else
            const SizedBox(height: 4),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 11,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

typedef NavigationScreen = MainNavigationPage;

class _MovementsDrawer extends StatelessWidget {
  const _MovementsDrawer({required this.menus, required this.onOpen});

  final AppMenusController menus;
  final ValueChanged<AppMenuEntity> onOpen;

  @override
  Widget build(BuildContext context) {
    final items = menus.movementMenu;
    final width = MediaQuery.sizeOf(context).width;
    return Drawer(
      width: width > 420 ? 360 : width * 0.86,
      backgroundColor: const Color(0xFFF6F4EE),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(left: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Movimentações',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F3D2A),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Registros da fazenda',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF6B6B6B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 24, 20, 20),
                child: Text(
                  'Nenhuma movimentação disponível.',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF8A8A8A),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _MovementTile(item: item, onTap: () => onOpen(item));
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MovementTile extends StatelessWidget {
  const _MovementTile({required this.item, required this.onTap});

  final AppMenuEntity item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final icon = MenuIcon.maybe(
      item: item,
      size: 18,
      color: MyColors.colorPrimary,
    );
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              if (icon != null) ...[
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0x1400823A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: icon,
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  item.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF313131),
                  ),
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF8A8A8A)),
            ],
          ),
        ),
      ),
    );
  }
}
