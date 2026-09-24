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
import 'package:costeira/features/animals/presentation/pages/animals_page.dart';
import 'package:costeira/features/base/pages/module_placeholder_page.dart';
import 'package:costeira/features/dashboard/presentation/pages/dashboard.dart';
import 'package:costeira/features/dashboard/presentation/widgets/dashboard_quick_actions.dart';
import 'package:costeira/features/fazendas/presentation/pages/fazendas_page.dart';
import 'package:costeira/features/movimentacoes/movimentacoes.dart';
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

  int _selectedIndex = 0;
  final PageController _pageController = PageController(initialPage: 0);
  late final AppMenusController _menusController;
  Timer? _pollTimer;
  String _lastHandledSignature = '';

  static const _fallbackItems = [
    _NavTab(slug: MenuSlug.dashboard, label: 'Dashboard'),
    _NavTab(slug: MenuSlug.fazendas, label: 'Fazendas'),
    _NavTab(slug: MenuSlug.animais, label: 'Animais'),
    _NavTab(slug: MenuSlug.manejos, label: 'Manejos'),
    _NavTab(slug: MenuSlug.perfil, label: 'Perfil'),
  ];

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
    unawaited(_menusController.load(force: true));
    unawaited(
      Modular.get<FormDependenciesCacheService>().preloadEssentialLists(),
    );
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

    final currentSlug = tabs.isEmpty
        ? null
        : tabs[_selectedIndex.clamp(0, tabs.length - 1)].slug;
    final access = MenuAccess.fromMenus(
      navigation: _menusController.navigationMenu,
      profile: _menusController.profileMenu,
      dashboard: _menusController.dashboardMenu,
    );

    if (currentSlug != null &&
        _menusController.navigationMenu.isNotEmpty &&
        !access.allowsNavSlug(currentSlug)) {
      kicked = _goToDashboardTab(tabs);
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
    final dashboardIndex = tabs.indexWhere(
      (tab) => tab.slug == MenuSlug.dashboard,
    );
    final target = dashboardIndex >= 0 ? dashboardIndex : 0;
    final changed = _selectedIndex != target;
    _selectedIndex = target;
    if (_pageController.hasClients) {
      _pageController.jumpToPage(target);
    }
    return changed || dashboardIndex >= 0;
  }

  List<_NavTab> get _tabs {
    final items = _menusController.navigationMenu;
    if (items.isEmpty) {
      return _fallbackItems;
    }
    return [
      for (final item in items)
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
    final current = tabs[_selectedIndex.clamp(0, tabs.length - 1)];

    return Scaffold(
      backgroundColor: current.slug == MenuSlug.dashboard
          ? const Color(0xFFF6F4EE)
          : Colors.white,
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
          setState(() => _selectedIndex = page);
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

  Widget _pageFor(_NavTab tab) {
    return switch (tab.slug) {
      MenuSlug.dashboard => const Dashboard(),
      MenuSlug.fazendas => const FazendasPage(),
      MenuSlug.animais => const AnimalsPage(),
      MenuSlug.movimentacoes => const Movimentacoes(),
      MenuSlug.manejos => ModulePlaceholderPage(
        title: tab.label,
        item: tab.item,
        message:
            'Em breve. Use o botão + do Dashboard para registrar um manejo.',
      ),
      MenuSlug.perfil => const Menu(),
      _ => ModulePlaceholderPage(
        title: tab.label,
        item: tab.item,
        message: 'Em breve.',
      ),
    };
  }

  void _onNavItemTapped(int index) {
    setState(() => _selectedIndex = index);
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
