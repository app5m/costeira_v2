import 'dart:async';

import 'package:costeira/app/app_routes.dart';
import 'package:costeira/core/common/get_list/domain/entities/app_menu_entity.dart';
import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/core/components/web_dialog_frame.dart';
import 'package:costeira/core/menus/app_menus_controller.dart';
import 'package:costeira/core/menus/menu_access.dart';
import 'package:costeira/core/menus/menu_action_resolver.dart';
import 'package:costeira/core/menus/menu_icon.dart';
import 'package:costeira/core/menus/menu_slug.dart';
import 'package:costeira/core/offline/cache/form_dependencies_cache_service.dart';
import 'package:costeira/core/storage/sub_user_payload.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/features/account/presentation/web/profile_web_page.dart';
import 'package:costeira/features/account/repositories/account_repository.dart';
import 'package:costeira/features/admin_clientes/presentation/pages/selecionar_cliente_page.dart';
import 'package:costeira/features/animals/presentation/pages/animals_page.dart';
import 'package:costeira/features/animals/presentation/web/animals_web_page.dart';
import 'package:costeira/features/base/pages/module_placeholder_page.dart';
import 'package:costeira/features/dashboard/presentation/pages/dashboard.dart';
import 'package:costeira/features/dashboard/presentation/web/dashboard_web_page.dart';
import 'package:costeira/features/dashboard/presentation/widgets/dashboard_quick_actions.dart';
import 'package:costeira/features/fazendas/presentation/pages/fazendas_page.dart';
import 'package:costeira/features/fazendas/presentation/web/fazendas_web_page.dart';
import 'package:costeira/features/fazendas/domain/usecases/resolve_current_farm_id.dart';
import 'package:costeira/features/manejos_animais/presentation/pages/manejos_animais_page.dart';
import 'package:costeira/features/manejos_animais/presentation/web/manejos_web_page.dart';
import 'package:costeira/features/movimentacoes/compras/presentation/web/compras_web_page.dart';
import 'package:costeira/features/movimentacoes/vendas/presentation/web/vendas_web_page.dart';
import 'package:costeira/features/movimentacoes/movimentacoes.dart';
import 'package:costeira/features/notifications/presentation/pages/notification_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
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
  int _shellGeracao = 0;
  bool _aguardandoGrupo = true;
  bool _escolherCliente = false;
  final PageController _pageController = PageController(initialPage: 0);
  late final AppMenusController _menusController;
  Timer? _pollTimer;
  String _lastHandledSignature = '';
  String? _activeSlug;
  String? _activeWebMovementSlug;
  String? _activeWebMovementTitle;
  _WebSidebarSection _webSidebarSection = _WebSidebarSection.navigation;
  String _userDisplayName = '';
  DashboardWebToolbarData? _dashboardToolbarData;

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
      if (mounted) {
        setState(() => _aguardandoGrupo = false);
      }
      return;
    }
    _userDisplayName = user.name.trim().isNotEmpty
        ? user.name.trim()
        : (user.nickname ?? '').trim();
    if (kIsWeb) {
      _activeSlug = await SessionStorage.getWebActiveMenuSlug();
      final section = await SessionStorage.getWebSidebarSection();
      _webSidebarSection = section == _WebSidebarSection.movements.name
          ? _WebSidebarSection.movements
          : _WebSidebarSection.navigation;
    }
    await _loadSubUser(user.id);
    final session = await SessionStorage.getUserSession();
    if (!mounted || session == null) {
      if (mounted) {
        setState(() => _aguardandoGrupo = false);
      }
      return;
    }
    _userDisplayName = session.name.trim().isNotEmpty
        ? session.name.trim()
        : (session.nickname ?? '').trim();
    if (session.isAdmin &&
        (session.managedClientId == null || session.managedClientId! <= 0)) {
      setState(() {
        _aguardandoGrupo = false;
        _escolherCliente = true;
      });
      return;
    }
    if (kIsWeb) {
      await _prepareWebFarmContext(session.id);
    }
    if (!mounted) return;
    setState(() => _aguardandoGrupo = false);
    unawaited(_menusController.load(force: true));
    unawaited(
      Modular.get<FormDependenciesCacheService>().preloadEssentialLists(),
    );
  }

  Future<void> _aplicarCliente() async {
    if (kIsWeb) {
      final session = await SessionStorage.getUserSession();
      if (session != null) {
        await _prepareWebFarmContext(session.id);
      }
    }
    if (!mounted) return;
    setState(() {
      _escolherCliente = false;
      _aguardandoGrupo = false;
      _shellGeracao++;
      _selectedIndex = 0;
      _activeSlug = null;
      _activeWebMovementSlug = null;
      _activeWebMovementTitle = null;
      _webSidebarSection = _WebSidebarSection.navigation;
    });
    if (kIsWeb) {
      await SessionStorage.clearWebActiveMenuSlug();
      await SessionStorage.saveWebSidebarSection(
        _WebSidebarSection.navigation.name,
      );
    }
    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }
    await _menusController.load(force: true);
    unawaited(
      Modular.get<FormDependenciesCacheService>().preloadEssentialLists(),
    );
  }

  Future<void> _trocarCliente() async {
    final trocou = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const SelecionarClientePage()),
    );
    if (trocou == true && mounted) {
      await _aplicarCliente();
    }
  }

  Future<void> _loadSubUser(int userId) async {
    try {
      await Modular.get<AccountRepository>().fetchProfile(userId: userId);
    } catch (_) {}
  }

  Future<void> _prepareWebFarmContext(int sessionUserId) async {
    if (!kIsWeb) return;
    try {
      await Modular.get<ResolveCurrentFarmId>()(
        userId: sessionAccountUserId(sessionUserId),
      );
    } catch (_) {
      // A tela continua disponível e poderá tentar novamente pelo dashboard.
    }
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
        _syncPageController(updatedIndex);
      }
    } else if (_selectedIndex >= tabs.length) {
      _selectedIndex = 0;
      _syncPageController(0);
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
    _rememberActiveSlug(tabs[target].slug);
    _syncPageController(target);
    return changed || dashboardIndex >= 0;
  }

  void _syncPageController(int index) {
    if (_pageController.hasClients) {
      _pageController.jumpToPage(index);
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_pageController.hasClients) {
        return;
      }
      _pageController.jumpToPage(index);
    });
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
    if (_aguardandoGrupo) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_escolherCliente) {
      return SelecionarClientePage(
        obrigatorio: true,
        onEscolhido: () => unawaited(_aplicarCliente()),
      );
    }
    final tabs = _tabs;
    if (kIsWeb) {
      return _buildWebShell(tabs);
    }
    if (tabs.isEmpty) {
      return _emptyNavScaffold();
    }

    final current = tabs[_selectedIndex.clamp(0, tabs.length - 1)];
    if (_activeSlug == null) {
      _rememberActiveSlug(current.slug);
    }

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
          if (SessionStorage.cachedIdGrupo == 1)
            IconButton(
              tooltip: 'Clientes',
              onPressed: _trocarCliente,
              icon: const Icon(LucideIcons.users, color: Colors.white),
            ),
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
            onPressed: () => unawaited(_openNotifications()),
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
            _rememberActiveSlug(tabs[page].slug);
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
    if (_activeSlug == null && current != null) {
      _rememberActiveSlug(current.slug);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final useSidebar = constraints.maxWidth >= 760;
        final showingWebMovement = _activeWebMovementSlug != null;
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
                      title: showingWebMovement
                          ? _activeWebMovementTitle ?? 'Movimentações'
                          : current?.slug == MenuSlug.dashboard
                          ? _dashboardGreeting
                          : current?.label ?? 'Costeira',
                      subtitle:
                          !showingWebMovement &&
                              current?.slug == MenuSlug.dashboard
                          ? 'Bem-vindo ao Costeira'
                          : null,
                      showMenuButton: !useSidebar,
                      controls:
                          !showingWebMovement &&
                              current?.slug == MenuSlug.dashboard &&
                              _dashboardToolbarData != null
                          ? DashboardWebToolbar(data: _dashboardToolbarData!)
                          : null,
                      onMenu: () => _scaffoldKey.currentState?.openDrawer(),
                      onNotifications: () => unawaited(_openNotifications()),
                    ),
                    Expanded(
                      child: _activeWebMovementSlug == MenuSlug.compras
                          ? ComprasWebPage(
                              key: ValueKey(
                                '$_shellGeracao-${MenuSlug.compras}',
                              ),
                            )
                          : _activeWebMovementSlug == MenuSlug.vendas
                          ? VendasWebPage(
                              key: ValueKey(
                                '$_shellGeracao-${MenuSlug.vendas}',
                              ),
                            )
                          : hasTabs
                          ? PageView(
                              controller: _pageController,
                              physics: const NeverScrollableScrollPhysics(),
                              onPageChanged: (page) {
                                setState(() {
                                  _selectedIndex = page;
                                  _rememberActiveSlug(tabs[page].slug);
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

  String get _dashboardGreeting {
    if (_userDisplayName.isEmpty) {
      return 'Olá!';
    }
    final firstName = _userDisplayName.split(RegExp(r'\s+')).first;
    return 'Olá, $firstName!';
  }

  Widget _webSidebar(List<_NavTab> tabs, {bool closeDrawer = false}) {
    return _WebSidebar(
      menus: _menusController,
      tabs: tabs,
      currentIndex: tabs.isEmpty ? 0 : _selectedIndex.clamp(0, tabs.length - 1),
      activeMovementSlug: _activeWebMovementSlug,
      section: _webSidebarSection,
      onSectionChanged: _setWebSidebarSection,
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
        if (_openWebMovement(item)) {
          return;
        }
        MenuActionResolver.open(
          context,
          item,
          surface: MenuSurface.movimentacoes,
        );
      },
    );
  }

  bool _openWebMovement(AppMenuEntity item) {
    if (!kIsWeb) return false;
    final slug = MenuActionResolver.slugOf(item);
    if (slug != MenuSlug.compras && slug != MenuSlug.vendas) return false;
    setState(() {
      _activeWebMovementSlug = slug;
      _activeWebMovementTitle = item.name;
      _webSidebarSection = _WebSidebarSection.movements;
    });
    unawaited(
      SessionStorage.saveWebSidebarSection(_WebSidebarSection.movements.name),
    );
    return true;
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

  Future<void> _openNotifications() async {
    if (!kIsWeb) {
      await Modular.to.pushNamed(AppRoutes.notifications);
      return;
    }
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const WebDialogFrame(
        title: 'Notificações',
        width: 720,
        maxHeight: 720,
        sizeMode: WebDialogSizeMode.constrained,
        scrollableBody: false,
        child: NotificationsPage(embedded: true),
      ),
    );
  }

  void _rememberActiveSlug(String slug) {
    _activeSlug = slug;
    if (kIsWeb) {
      unawaited(SessionStorage.saveWebActiveMenuSlug(slug));
    }
  }

  void _setWebSidebarSection(_WebSidebarSection section) {
    if (_webSidebarSection == section) {
      return;
    }
    setState(() => _webSidebarSection = section);
    unawaited(SessionStorage.saveWebSidebarSection(section.name));
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
    final chave = ValueKey('$_shellGeracao-${tab.slug}');
    return switch (tab.slug) {
      MenuSlug.dashboard =>
        kIsWeb
            ? DashboardWebPage(
                key: chave,
                onWebContextChanged: _onFarmChanged,
                onToolbarChanged: (data) {
                  if (!mounted || data == null) return;
                  setState(() => _dashboardToolbarData = data);
                },
              )
            : Dashboard(key: chave),
      MenuSlug.fazendas =>
        kIsWeb
            ? FazendasWebPage(key: chave, onFarmChanged: _onFarmChanged)
            : FazendasPage(key: chave),
      MenuSlug.animais =>
        kIsWeb ? AnimalsWebPage(key: chave) : AnimalsPage(key: chave),
      MenuSlug.movimentacoes => Movimentacoes(key: chave),
      MenuSlug.manejos =>
        kIsWeb ? ManejosWebPage(key: chave) : ManejosAnimaisPage(key: chave),
      MenuSlug.perfil => kIsWeb ? ProfileWebPage(key: chave) : Menu(key: chave),
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
      _activeWebMovementSlug = null;
      _activeWebMovementTitle = null;
      _selectedIndex = index;
      _rememberActiveSlug(tabs[index].slug);
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  Future<void> _onFarmChanged() async {
    if (!mounted) return;
    setState(() {
      _shellGeracao++;
      _dashboardToolbarData = null;
    });
    await Future.wait([
      _menusController.refresh(),
      Modular.get<FormDependenciesCacheService>().preloadEssentialLists(
        force: true,
      ),
    ]);
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
    this.controls,
    this.subtitle,
  });

  final String title;
  final bool showMenuButton;
  final VoidCallback onMenu;
  final VoidCallback onNotifications;
  final Widget? controls;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final hasControls = controls != null;
        final inline = hasControls && constraints.maxWidth >= 900;
        final horizontalPadding = showMenuButton ? 12.0 : 28.0;
        final titleRow = Row(
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
              child: subtitle == null
                  ? Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF173F2C),
                      ),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF173F2C),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF7A817B),
                          ),
                        ),
                      ],
                    ),
            ),
            if (inline) ...[
              SizedBox(
                width: (constraints.maxWidth * .64).clamp(590.0, 720.0),
                child: controls!,
              ),
              const SizedBox(width: 12),
            ],
            _NotificationButton(onPressed: onNotifications),
          ],
        );

        return Material(
          color: const Color(0xFFFAF9F5),
          elevation: 0,
          child: Container(
            height: hasControls && !inline ? 112 : 64,
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFD9DDD3))),
            ),
            child: hasControls && !inline
                ? Column(
                    children: [
                      SizedBox(height: 58, child: titleRow),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: SizedBox(
                            width: double.infinity,
                            child: controls,
                          ),
                        ),
                      ),
                    ],
                  )
                : titleRow,
          ),
        );
      },
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFD9DDD3)),
      ),
      child: IconButton(
        tooltip: 'Notificações',
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        icon: SvgPicture.asset(
          'icon/noti.svg',
          width: 19,
          height: 19,
          colorFilter: const ColorFilter.mode(
            MyColors.colorPrimary,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}

enum _WebSidebarSection { navigation, movements }

class _WebSidebar extends StatelessWidget {
  const _WebSidebar({
    required this.menus,
    required this.tabs,
    required this.currentIndex,
    required this.activeMovementSlug,
    required this.section,
    required this.onSectionChanged,
    required this.onSelect,
    required this.onMovement,
  });

  final AppMenusController menus;
  final List<_NavTab> tabs;
  final int currentIndex;
  final String? activeMovementSlug;
  final _WebSidebarSection section;
  final ValueChanged<_WebSidebarSection> onSectionChanged;
  final ValueChanged<int> onSelect;
  final ValueChanged<AppMenuEntity> onMovement;

  @override
  Widget build(BuildContext context) {
    AppMenuEntity? profile;
    final navigation = <Widget>[];

    for (final item in menus.navigationMenu) {
      final slug = MenuActionResolver.slugOf(item);
      if (slug == MenuSlug.perfil) {
        profile = item;
        continue;
      }
      if (slug == MenuSlug.movimentacoes) {
        continue;
      }
      final index = tabs.indexWhere((tab) => tab.slug == slug);
      if (index < 0) {
        continue;
      }
      navigation.add(
        _WebNavigationTile(
          item: item,
          label: item.name,
          selected: activeMovementSlug == null && index == currentIndex,
          onTap: () => onSelect(index),
        ),
      );
    }

    final profileIndex = profile == null
        ? -1
        : tabs.indexWhere(
            (tab) => tab.slug == MenuActionResolver.slugOf(profile!),
          );
    final movements = menus.movementMenu;
    final visibleItems = section == _WebSidebarSection.navigation
        ? navigation
        : [
            for (final item in movements)
              _WebMovementGroup(
                item: item,
                activeSlug: activeMovementSlug,
                onOpen: onMovement,
              ),
          ];

    return ColoredBox(
      color: const Color(0xFFF3F1E9),
      child: SafeArea(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            border: Border(right: BorderSide(color: Color(0xFFD5D9D0))),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                child: SizedBox(
                  height: 100,
                  width: double.infinity,
                  child: ClipRect(
                    child: Transform.scale(
                      scale: 1.12,
                      child: Image.asset(
                        'images/logosplash.png',
                        width: double.infinity,
                        height: 100,
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: _WebSidebarSwitcher(
                  selected: section,
                  onChanged: onSectionChanged,
                ),
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: visibleItems.isEmpty
                      ? _WebSidebarEmptyState(
                          key: ValueKey(section),
                          message: section == _WebSidebarSection.movements
                              ? 'Nenhuma movimentação disponível.'
                              : 'Nenhuma página disponível.',
                        )
                      : ListView.separated(
                          key: ValueKey(section),
                          padding: const EdgeInsets.fromLTRB(10, 4, 10, 16),
                          itemCount: visibleItems.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 5),
                          itemBuilder: (_, index) => visibleItems[index],
                        ),
                ),
              ),
              if (profile != null && profileIndex >= 0) ...[
                const Divider(height: 1, color: Color(0xFFD5D9D0)),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: _WebNavigationTile(
                    item: profile,
                    label: profile.name,
                    selected:
                        activeMovementSlug == null &&
                        profileIndex == currentIndex,
                    onTap: () {
                      if (section != _WebSidebarSection.navigation) {
                        onSectionChanged(_WebSidebarSection.navigation);
                      }
                      onSelect(profileIndex);
                    },
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

class _WebSidebarSwitcher extends StatelessWidget {
  const _WebSidebarSwitcher({required this.selected, required this.onChanged});

  final _WebSidebarSection selected;
  final ValueChanged<_WebSidebarSection> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFE5E4DD),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: _WebSidebarSwitcherItem(
              label: 'Navegação',
              selected: selected == _WebSidebarSection.navigation,
              onTap: () => onChanged(_WebSidebarSection.navigation),
            ),
          ),
          Expanded(
            child: _WebSidebarSwitcherItem(
              label: 'Movimentações',
              selected: selected == _WebSidebarSection.movements,
              onTap: () => onChanged(_WebSidebarSection.movements),
            ),
          ),
        ],
      ),
    );
  }
}

class _WebSidebarSwitcherItem extends StatelessWidget {
  const _WebSidebarSwitcherItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? MyColors.colorPrimary : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Center(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : const Color(0xFF5F665F),
            ),
          ),
        ),
      ),
    );
  }
}

class _WebSidebarEmptyState extends StatelessWidget {
  const _WebSidebarEmptyState({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF8A8A8A),
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
      color: selected ? const Color(0xFFE1E9E0) : Colors.transparent,
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: selected ? const Color(0xFFB8C9BB) : Colors.transparent,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              SizedBox(
                width: 23,
                height: 23,
                child: Center(
                  child:
                      icon ??
                      Icon(Icons.circle_outlined, size: 18, color: color),
                ),
              ),
              const SizedBox(width: 11),
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
    required this.item,
    required this.activeSlug,
    required this.onOpen,
    this.depth = 0,
  });

  final AppMenuEntity item;
  final String? activeSlug;
  final ValueChanged<AppMenuEntity> onOpen;
  final int depth;

  @override
  Widget build(BuildContext context) {
    if (item.children.isEmpty) {
      return _WebMovementTile(
        item: item,
        selected: MenuActionResolver.slugOf(item) == activeSlug,
        depth: depth,
        onTap: () => onOpen(item),
      );
    }

    final icon = MenuIcon.maybe(
      item: item,
      size: 21,
      color: const Color(0xFF5E6E64),
    );
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.only(left: 13 + (depth * 10), right: 9),
        childrenPadding: const EdgeInsets.only(bottom: 6),
        initiallyExpanded: depth == 0,
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
          item.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF666666),
          ),
        ),
        children: [
          for (final child in item.children)
            _WebMovementGroup(
              item: child,
              activeSlug: activeSlug,
              depth: depth + 1,
              onOpen: onOpen,
            ),
        ],
      ),
    );
  }
}

class _WebMovementTile extends StatelessWidget {
  const _WebMovementTile({
    required this.item,
    required this.selected,
    required this.onTap,
    this.depth = 0,
  });

  final AppMenuEntity item;
  final bool selected;
  final VoidCallback onTap;
  final int depth;

  @override
  Widget build(BuildContext context) {
    final tile = _WebNavigationTile(
      item: item,
      label: item.name,
      selected: selected,
      onTap: onTap,
    );
    if (depth == 0) {
      return tile;
    }
    return Padding(
      padding: EdgeInsets.only(left: depth * 10),
      child: tile,
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
